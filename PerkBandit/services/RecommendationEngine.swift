//
//  RecommendationEngine.swift
//  PerkBandit
//

import Foundation

// MARK: - Types

enum RecommendationType: Equatable {
    case expiringBenefit
    case welcomeBonusAtRisk
    case activationRequired
    case annualFeeApproaching
    case purchaseRecommendation

    var priority: Int {
        switch self {
        case .expiringBenefit: return 1
        case .welcomeBonusAtRisk: return 2
        case .activationRequired: return 3
        case .annualFeeApproaching: return 4
        case .purchaseRecommendation: return 5
        }
    }
}

enum RecommendationUrgency: Int, Comparable, Equatable {
    case critical = 0
    case high = 1
    case medium = 2
    case low = 3

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .critical: return "Urgent"
        case .high: return "Expiring"
        case .medium: return "Action"
        case .low: return "Info"
        }
    }
}

struct Recommendation: Identifiable, Equatable {
    let id: String
    let type: RecommendationType
    let title: String
    let subtitle: String
    let estimatedValue: Decimal?
    let urgency: RecommendationUrgency
    let cardDefinitionID: String?
    let userCardID: String?
    let explanation: String
    let icon: String
    let iconColor: String
}

// MARK: - Engine

enum RecommendationEngine {

    static func generateRecommendations(cards: [UserCard], now: Date = Date()) -> [Recommendation] {
        var results: [Recommendation] = []
        results += expiringBenefitRecommendations(cards: cards, now: now)
        results += welcomeBonusRecommendations(cards: cards, now: now)
        results += activationRecommendations(cards: cards)
        results += annualFeeRecommendations(cards: cards, now: now)
        return results.sorted { ($0.type.priority, $0.urgency) < ($1.type.priority, $1.urgency) }
    }

    // MARK: - Priority 1: Expiring Benefits

    private static func expiringBenefitRecommendations(cards: [UserCard], now: Date) -> [Recommendation] {
        cards.flatMap { userCard -> [Recommendation] in
            guard let def = userCard.definition else { return [] }
            return userCard.benefitStates.compactMap { state -> Recommendation? in
                guard state.status != .used,
                      let days = state.daysUntilExpiry,
                      days >= 0, days <= 7,
                      let credit = def.statementCredits.first(where: { $0.description == state.id })
                else { return nil }

                let urgency: RecommendationUrgency
                if days <= 1 { urgency = .critical }
                else if days <= 3 { urgency = .high }
                else { urgency = .medium }

                let cardName = def.name
                return Recommendation(
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
                    iconColor: urgency == .critical ? "red" : "orange"
                )
            }
        }
    }

    // MARK: - Priority 2: Welcome Bonus at Risk

    private static func welcomeBonusRecommendations(cards: [UserCard], now: Date) -> [Recommendation] {
        let cal = Calendar.current
        return cards.compactMap { userCard -> Recommendation? in
            guard let bonus = userCard.welcomeBonus,
                  bonus.isTracking == true,
                  let target = bonus.targetSpend, target > 0
            else { return nil }

            let current = bonus.currentSpend ?? 0
            let remaining = target - current
            guard remaining > 0 else { return nil }

            let def = userCard.definition
            let cardName = def?.name ?? "Card"

            let urgency: RecommendationUrgency
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
            return Recommendation(
                id: "bonus-\(userCard.id)",
                type: .welcomeBonusAtRisk,
                title: "\(cardName) — $\(Int(remaining)) to go",
                subtitle: bonusDesc,
                estimatedValue: nil,
                urgency: urgency,
                cardDefinitionID: userCard.cardDefinitionID,
                userCardID: userCard.id,
                explanation: explanation,
                icon: "star.circle.fill",
                iconColor: urgency == .critical ? "red" : "purple"
            )
        }
    }

    // MARK: - Priority 3: Activation Required

    private static func activationRecommendations(cards: [UserCard]) -> [Recommendation] {
        cards.compactMap { userCard -> Recommendation? in
            guard let def = userCard.definition,
                  let activation = def.activationRequired
            else { return nil }

            return Recommendation(
                id: "activation-\(userCard.id)",
                type: .activationRequired,
                title: "\(def.name) — \(activation)",
                subtitle: "\(def.issuer) · Action needed",
                estimatedValue: nil,
                urgency: .medium,
                cardDefinitionID: userCard.cardDefinitionID,
                userCardID: userCard.id,
                explanation: "Your \(def.name) requires you to \(activation.lowercased()) to earn bonus rewards.",
                icon: "bolt.circle.fill",
                iconColor: "blue"
            )
        }
    }

    // MARK: - Priority 4: Annual Fee Approaching

    private static func annualFeeRecommendations(cards: [UserCard], now: Date) -> [Recommendation] {
        let cal = Calendar.current
        return cards.compactMap { userCard -> Recommendation? in
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

            let urgency: RecommendationUrgency = daysUntil <= 7 ? .high : .medium

            return Recommendation(
                id: "fee-\(userCard.id)",
                type: .annualFeeApproaching,
                title: "\(def.name) — $\(Int(feeAmount)) fee in \(daysUntil) days",
                subtitle: "\(def.issuer) · Review your card value",
                estimatedValue: Decimal(feeAmount),
                urgency: urgency,
                cardDefinitionID: userCard.cardDefinitionID,
                userCardID: userCard.id,
                explanation: "Your \(def.name) annual fee of $\(Int(feeAmount)) renews in \(daysUntil) days. Make sure you're getting enough value to justify keeping it.",
                icon: "dollarsign.circle.fill",
                iconColor: "orange"
            )
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
        return "creditcard.fill"
    }
}
