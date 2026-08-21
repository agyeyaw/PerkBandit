//
//  RecommendationEngine.swift
//  PerkBandit
//

import Foundation

// MARK: - Recommendation Preferences

enum RecommendationPreference: String, CaseIterable {
    case maximizeCashback = "Maximize cashback"
    case maximizeTravelPoints = "Maximize travel points"
    case prioritizeWelcomeBonuses = "Prioritize welcome bonuses"
    case useCreditsBeforeExpiry = "Use credits before they expire"
    case keepSimple = "Keep recommendations simple"

    init?(from string: String) { self.init(rawValue: string) }
}

// MARK: - Engine

enum OpportunityEngine {

    static func generateOpportunities(cards: [UserCard], now: Date = Date()) -> [Opportunity] {
        var results: [Opportunity] = []
        results += expiringBenefitOpportunities(cards: cards, now: now)
        results += welcomeBonusOpportunities(cards: cards, now: now)
        results += activationOpportunities(cards: cards)
        results += annualFeeOpportunities(cards: cards, now: now)
        results += needsConfirmationOpportunities(cards: cards)
        return results.sorted { ($0.type.priority, $0.urgency) < ($1.type.priority, $1.urgency) }
    }

    // MARK: - Priority 1: Expiring Benefits

    private static func expiringBenefitOpportunities(cards: [UserCard], now: Date) -> [Opportunity] {
        cards.flatMap { userCard -> [Opportunity] in
            guard let def = userCard.definition else { return [] }
            return userCard.benefitStates.compactMap { state -> Opportunity? in
                guard state.status != .used,
                      let days = state.daysUntilExpiry,
                      days >= 0, days <= 7,
                      let credit = def.statementCredits.first(where: { $0.description == state.id })
                else { return nil }

                let urgency: OpportunityUrgency
                if days <= 1 { urgency = .critical }
                else if days <= 3 { urgency = .high }
                else { urgency = .medium }

                let cardName = def.name
                return Opportunity(
                    id: "expiring-\(userCard.id)-\(state.id)",
                    type: .expiringBenefit,
                    title: "\(credit.description) — \(state.expiryText ?? "expiring soon")",
                    subtitle: "\(cardName) · $\(Int(credit.perPeriodAmount)) remaining",
                    estimatedValue: Decimal(credit.perPeriodAmount),
                    urgency: urgency,
                    cardDefinitionID: userCard.cardDefinitionID,
                    userCardID: userCard.id,
                    explanation: "Your \(credit.description) on the \(cardName) is expiring soon. Use it before you lose $\(Int(credit.perPeriodAmount)) in value.",
                    icon: iconForBenefit(credit.description),
                    iconColor: urgency == .critical ? "red" : "orange",
                    expirationDate: state.periodEnd,
                    confidence: .estimated,
                    progress: nil,
                    benefitID: state.id
                )
            }
        }
    }

    // MARK: - Priority 2: Welcome Bonus

    private static func welcomeBonusOpportunities(cards: [UserCard], now: Date) -> [Opportunity] {
        let cal = Calendar.current
        return cards.compactMap { userCard -> Opportunity? in
            guard let bonus = userCard.welcomeBonus,
                  bonus.isTracking == true,
                  let target = bonus.targetSpend, target > 0
            else { return nil }

            let current = bonus.currentSpend ?? 0
            let remaining = target - current
            guard remaining > 0 else { return nil }

            let def = userCard.definition
            let cardName = def?.name ?? "Card"

            let urgency: OpportunityUrgency
            var explanation: String

            if let deadline = bonus.deadline {
                let daysLeft = cal.dateComponents([.day], from: now, to: deadline).day ?? 0
                guard daysLeft >= 0 else { return nil }

                // Calculate pace: expected fraction vs actual fraction
                let totalDays = max(1, cal.dateComponents([.day], from: userCard.dateAdded, to: deadline).day ?? 90)
                let elapsed = max(0, totalDays - daysLeft)
                let expectedFraction = Double(elapsed) / Double(totalDays)
                let actualFraction = current / target

                if daysLeft <= 7 {
                    urgency = .critical
                } else if actualFraction < expectedFraction - 0.10 {
                    urgency = .high
                } else {
                    urgency = .medium
                }

                explanation = "You need to spend $\(Int(remaining)) more on your \(cardName) in \(daysLeft) days to earn your welcome bonus."
            } else {
                urgency = .medium
                explanation = "You still need $\(Int(remaining)) in spend on your \(cardName) to earn your welcome bonus."
            }

            let bonusDesc = bonus.bonusDescription ?? "welcome bonus"
            let spendProgress = min(1.0, current / target)
            return Opportunity(
                id: "bonus-\(userCard.id)",
                type: .welcomeBonus,
                title: "\(cardName) — $\(Int(remaining)) to go",
                subtitle: bonusDesc,
                estimatedValue: nil,
                urgency: urgency,
                cardDefinitionID: userCard.cardDefinitionID,
                userCardID: userCard.id,
                explanation: explanation,
                icon: "star.circle.fill",
                iconColor: urgency == .critical ? "red" : "purple",
                expirationDate: bonus.deadline,
                confidence: .estimated,
                progress: spendProgress,
                benefitID: nil
            )
        }
    }

    // MARK: - Priority 3: Category Activation

    private static func activationOpportunities(cards: [UserCard]) -> [Opportunity] {
        cards.compactMap { userCard -> Opportunity? in
            guard let def = userCard.definition,
                  let activation = def.activationRequired,
                  userCard.activatedThisPeriod != true
            else { return nil }

            return Opportunity(
                id: "activation-\(userCard.id)",
                type: .categoryActivation,
                title: "\(def.name) — \(activation)",
                subtitle: "\(def.issuer) · Action needed",
                estimatedValue: nil,
                urgency: .medium,
                cardDefinitionID: userCard.cardDefinitionID,
                userCardID: userCard.id,
                explanation: "Your \(def.name) requires you to \(activation.lowercased()) to earn bonus rewards.",
                icon: "bolt.circle.fill",
                iconColor: "blue",
                expirationDate: nil,
                confidence: .verified,
                progress: nil,
                benefitID: nil
            )
        }
    }

    // MARK: - Priority 4: Annual Fee Review

    private static func annualFeeOpportunities(cards: [UserCard], now: Date) -> [Opportunity] {
        let cal = Calendar.current
        return cards.compactMap { userCard -> Opportunity? in
            guard let renewalDate = userCard.renewalDate,
                  let def = userCard.definition
            else { return nil }

            let daysUntil = cal.dateComponents([.day], from: now, to: renewalDate).day ?? 0
            guard daysUntil >= 0, daysUntil <= 30 else { return nil }

            // Parse annual fee — extract first number
            let feeString = def.annualFee
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
            let feeAmount: Double
            if let range = feeString.range(of: #"[0-9]+"#, options: .regularExpression) {
                feeAmount = Double(feeString[range]) ?? 0
            } else {
                feeAmount = 0
            }

            // "$0 intro, then $95" → first number is 0, skip
            guard feeAmount > 0 else { return nil }

            let urgency: OpportunityUrgency = daysUntil <= 7 ? .high : .medium

            return Opportunity(
                id: "fee-\(userCard.id)",
                type: .annualFeeReview,
                title: "\(def.name) — $\(Int(feeAmount)) fee in \(daysUntil) days",
                subtitle: "\(def.issuer) · Review your card value",
                estimatedValue: Decimal(feeAmount),
                urgency: urgency,
                cardDefinitionID: userCard.cardDefinitionID,
                userCardID: userCard.id,
                explanation: "Your \(def.name) annual fee of $\(Int(feeAmount)) renews in \(daysUntil) days. Make sure you're getting enough value to justify keeping it.",
                icon: "dollarsign.circle.fill",
                iconColor: "orange",
                expirationDate: renewalDate,
                confidence: .estimated,
                progress: nil,
                benefitID: nil
            )
        }
    }

    // MARK: - Priority 5: Needs Confirmation

    private static func needsConfirmationOpportunities(cards: [UserCard]) -> [Opportunity] {
        cards.flatMap { userCard -> [Opportunity] in
            guard let def = userCard.definition else { return [] }
            return userCard.benefitStates.compactMap { state -> Opportunity? in
                guard state.status == .notSure,
                      let credit = def.statementCredits.first(where: { $0.description == state.id })
                else { return nil }

                return Opportunity(
                    id: "confirm-\(userCard.id)-\(state.id)",
                    type: .needsConfirmation,
                    title: "\(credit.description) not confirmed",
                    subtitle: "\(def.name) · Needs confirmation",
                    estimatedValue: Decimal(credit.perPeriodAmount),
                    urgency: .low,
                    cardDefinitionID: userCard.cardDefinitionID,
                    userCardID: userCard.id,
                    explanation: "You marked your \(credit.description) on the \(def.name) as \"not sure\". Confirm whether you've used it so PerkBandit can give you accurate recommendations.",
                    icon: iconForBenefit(credit.description),
                    iconColor: "orange",
                    expirationDate: state.periodEnd,
                    confidence: .inferred,
                    progress: nil,
                    benefitID: state.id
                )
            }
        }
    }

    // MARK: - Estimated Value Captured

    static func estimatedValueCaptured(cards: [UserCard]) -> (thisYear: Decimal, thisMonth: Decimal)? {
        let cal = Calendar.current
        let now = Date()
        let currentYear = cal.component(.year, from: now)
        let currentMonth = cal.component(.month, from: now)

        var yearTotal: Decimal = 0
        var monthTotal: Decimal = 0

        for userCard in cards {
            guard let def = userCard.definition else { continue }
            for state in userCard.benefitStates {
                guard state.status == .used,
                      let credit = def.statementCredits.first(where: { $0.description == state.id })
                else { continue }

                let amount = Decimal(credit.perPeriodAmount)
                yearTotal += amount

                // Count toward this month if the period end is in the current month
                if let periodEnd = state.periodEnd {
                    let endMonth = cal.component(.month, from: periodEnd)
                    let endYear = cal.component(.year, from: periodEnd)
                    if endYear == currentYear && endMonth == currentMonth {
                        monthTotal += amount
                    }
                } else {
                    // No period end — assume current month
                    monthTotal += amount
                }
            }
        }

        guard yearTotal > 0 else { return nil }
        return (thisYear: yearTotal, thisMonth: monthTotal)
    }

    // MARK: - Best Card for Category

    struct CardRewardMatch: Identifiable {
        let id: String
        let cardDefinitionID: String
        let cardName: String
        let issuer: String
        let matchedRule: RewardRule
        let effectiveMultiplier: Double
        let explanation: String
        var preferenceNote: String?
    }

    static func bestCards(
        for category: SpendingCategory,
        cards: [UserCard],
        preferences: Set<RecommendationPreference> = []
    ) -> [CardRewardMatch] {
        var matches: [CardRewardMatch] = []

        for userCard in cards {
            guard let def = userCard.definition else { continue }

            // Find the best matching rule: prefer category-specific over catch-all
            var bestRule: RewardRule?
            var isCategoryMatch = false

            for rule in def.rewardRules {
                if category.matches(rule: rule) && category != .other {
                    // Direct category match
                    let multiplier = SpendingCategory.parseMultiplier(rule.multiplier)
                    let currentBest = bestRule.map { SpendingCategory.parseMultiplier($0.multiplier) } ?? 0
                    if multiplier > currentBest || !isCategoryMatch {
                        bestRule = rule
                        isCategoryMatch = true
                    }
                } else if !isCategoryMatch {
                    // Fall back to "everything" catch-all
                    let lower = rule.category.lowercased()
                    if lower.hasPrefix("everything") {
                        let multiplier = SpendingCategory.parseMultiplier(rule.multiplier)
                        let currentBest = bestRule.map { SpendingCategory.parseMultiplier($0.multiplier) } ?? 0
                        if multiplier > currentBest {
                            bestRule = rule
                        }
                    }
                }
            }

            guard let rule = bestRule else { continue }
            let multiplier = SpendingCategory.parseMultiplier(rule.multiplier)

            let explanation: String
            if isCategoryMatch {
                explanation = "Earns \(rule.multiplier) on \(rule.category.lowercased()) purchases."
            } else {
                explanation = "Earns \(rule.multiplier) on all purchases (no bonus for \(category.label.lowercased()))."
            }

            matches.append(CardRewardMatch(
                id: userCard.id,
                cardDefinitionID: userCard.cardDefinitionID,
                cardName: "\(def.issuer) \(def.name)",
                issuer: def.issuer,
                matchedRule: rule,
                effectiveMultiplier: multiplier,
                explanation: explanation
            ))
        }

        // Sort by multiplier first
        var sorted = matches.sorted { $0.effectiveMultiplier > $1.effectiveMultiplier }

        // Apply preference-based re-ranking
        applyPreferenceModifiers(to: &sorted, category: category, cards: cards, preferences: preferences)

        return sorted
    }

    // MARK: - Preference Modifiers

    private static func applyPreferenceModifiers(
        to matches: inout [CardRewardMatch],
        category: SpendingCategory,
        cards: [UserCard],
        preferences: Set<RecommendationPreference>
    ) {
        guard !matches.isEmpty else { return }

        // "Prioritize welcome bonuses" — promote cards with active welcome bonus tracking
        if preferences.contains(.prioritizeWelcomeBonuses) {
            if let bonusIdx = matches.firstIndex(where: { match in
                guard let userCard = cards.first(where: { $0.id == match.id }),
                      let bonus = userCard.welcomeBonus,
                      bonus.isTracking,
                      let target = bonus.targetSpend,
                      let current = bonus.currentSpend,
                      target - current > 0
                else { return false }
                return true
            }), bonusIdx != 0 {
                let promoted = matches[bonusIdx]
                let topCard = matches[0]
                matches.remove(at: bonusIdx)
                matches.insert(promoted, at: 0)
                matches[0].preferenceNote = "Although \(topCard.cardName) earns more on \(category.label.lowercased()), you're currently working toward your \(promoted.cardName) welcome bonus."
            }
        }

        // "Use credits before they expire" — promote cards with expiring benefits relevant to category
        if preferences.contains(.useCreditsBeforeExpiry) {
            if let expiringIdx = matches.firstIndex(where: { match in
                guard let userCard = cards.first(where: { $0.id == match.id }),
                      let def = userCard.definition
                else { return false }
                return userCard.benefitStates.contains { state in
                    guard state.status != .used,
                          let days = state.daysUntilExpiry,
                          days >= 0, days <= 7,
                          let credit = def.statementCredits.first(where: { $0.description == state.id })
                    else { return false }
                    // Check if the credit is relevant to this spending category
                    let creditLower = credit.description.lowercased()
                    return category.keywords.contains { creditLower.contains($0) }
                }
            }) {
                let userCard = cards.first(where: { $0.id == matches[expiringIdx].id })!
                let def = userCard.definition!
                let expiringCredit = userCard.benefitStates.first { state in
                    guard state.status != .used,
                          let days = state.daysUntilExpiry,
                          days >= 0, days <= 7,
                          let credit = def.statementCredits.first(where: { $0.description == state.id })
                    else { return false }
                    let creditLower = credit.description.lowercased()
                    return category.keywords.contains { creditLower.contains($0) }
                }

                if expiringIdx != 0 {
                    let promoted = matches[expiringIdx]
                    matches.remove(at: expiringIdx)
                    matches.insert(promoted, at: 0)
                }
                if let creditName = expiringCredit?.id {
                    matches[0].preferenceNote = "Your \(creditName) on \(matches[0].cardName) expires soon — use this card to apply it."
                }
            }
        }

        // "Maximize cashback" / "Maximize travel points" — no re-ranking needed, just explanation text
        if matches[0].preferenceNote == nil {
            if preferences.contains(.maximizeCashback) {
                matches[0].preferenceNote = "Best cashback rate for \(category.label.lowercased())."
            } else if preferences.contains(.maximizeTravelPoints) {
                matches[0].preferenceNote = "Best points rate for \(category.label.lowercased())."
            }
        }
    }

    // MARK: - Helpers

    static func iconForBenefit(_ description: String) -> String {
        let lower = description.lowercased()
        if lower.contains("uber") { return "car.fill" }
        if lower.contains("dining") { return "fork.knife" }
        if lower.contains("travel") { return "airplane" }
        if lower.contains("hotel") { return "building.2" }
        if lower.contains("streaming") || lower.contains("entertainment") || lower.contains("digital") { return "play.tv" }
        if lower.contains("saks") { return "bag.fill" }
        if lower.contains("airline") { return "airplane.departure" }
        if lower.contains("dunkin") { return "cup.and.saucer.fill" }
        if lower.contains("lululemon") { return "figure.run" }
        if lower.contains("clear") { return "person.badge.shield.checkmark.fill" }
        if lower.contains("walmart") { return "cart.fill" }
        if lower.contains("resy") { return "fork.knife" }
        return "creditcard.fill"
    }
}
