//
//  CardStore.swift
//  PerkBandit
//

import Foundation
import Combine

struct ExpiringBenefit: Identifiable {
    var id: String { "\(userCard.id)-\(benefit.id)" }
    let userCard: UserCard
    let benefit: UserBenefitState
    let credit: StatementCredit
}

class CardStore: ObservableObject {
    @Published var cards: [UserCard]
    @Published var isUserSelected: Bool

    // Convenience: resolved catalog cards for views that only need display
    var creditCards: [CreditCard] {
        cards.compactMap { $0.definition }
    }

    var recommendations: [Recommendation] {
        RecommendationEngine.generateRecommendations(cards: cards)
    }

    var expiringBenefits: [ExpiringBenefit] {
        cards.flatMap { userCard in
            guard let def = userCard.definition else { return [ExpiringBenefit]() }
            return userCard.benefitStates.compactMap { state in
                guard state.isExpiringSoon,
                      let credit = def.statementCredits.first(where: { $0.description == state.id })
                else { return nil }
                return ExpiringBenefit(userCard: userCard, benefit: state, credit: credit)
            }
        }
    }

    private static let storageKey = "userCards"
    private static let legacyKey = "userSelectedCardIDs"

    private static let idMigrations: [String: String] = [
        "citi-premier": "citi-strata-premier",
    ]

    init() {
        // Try loading new UserCard format first
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode([UserCard].self, from: data),
           !saved.isEmpty {
            cards = saved
            isUserSelected = true
            backfillBenefitStates()
            resetExpiredBenefits()
            return
        }

        // Fall back to legacy [String] ID migration
        var savedIDs = UserDefaults.standard.stringArray(forKey: Self.legacyKey) ?? []

        // Migrate old IDs
        var didMigrate = false
        savedIDs = savedIDs.map { id in
            if let newID = Self.idMigrations[id] {
                didMigrate = true
                return newID
            }
            return id
        }
        if didMigrate {
            UserDefaults.standard.set(savedIDs, forKey: Self.legacyKey)
        }

        if savedIDs.isEmpty {
            cards = Array(cardCatalog.prefix(5)).map { UserCard.fromCatalog($0) }
            isUserSelected = false
        } else {
            cards = savedIDs.compactMap { id in
                guard catalogCard(for: id) != nil else { return nil }
                return UserCard.fromCatalog(id: id)
            }
            isUserSelected = true
        }
        resetExpiredBenefits()
    }

    func save() {
        if let data = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    func reload() {
        // Try loading new UserCard format first
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode([UserCard].self, from: data),
           !saved.isEmpty {
            cards = saved
            isUserSelected = true
            backfillBenefitStates()
            resetExpiredBenefits()
            return
        }

        // Fall back to legacy key
        let savedIDs = UserDefaults.standard.stringArray(forKey: Self.legacyKey) ?? []
        let mapped = savedIDs.compactMap { id in
            guard catalogCard(for: id) != nil else { return nil as UserCard? }
            return UserCard.fromCatalog(id: id)
        }
        if mapped.isEmpty {
            cards = Array(cardCatalog.prefix(5)).map { UserCard.fromCatalog($0) }
            isUserSelected = false
        } else {
            cards = mapped
            isUserSelected = true
        }
        resetExpiredBenefits()
    }

    // MARK: - Benefit Mutations

    func toggleBenefitStatus(userCardID: String, benefitID: String) {
        guard let ci = cards.firstIndex(where: { $0.id == userCardID }),
              let bi = cards[ci].benefitStates.firstIndex(where: { $0.id == benefitID })
        else { return }
        cards[ci].benefitStates[bi].status = cards[ci].benefitStates[bi].status == .used ? .available : .used
        save()
    }

    func markBenefitUsed(userCardID: String, benefitID: String) {
        guard let ci = cards.firstIndex(where: { $0.id == userCardID }),
              let bi = cards[ci].benefitStates.firstIndex(where: { $0.id == benefitID })
        else { return }
        cards[ci].benefitStates[bi].status = .used
        save()
    }

    func markBenefitAvailable(userCardID: String, benefitID: String) {
        guard let ci = cards.firstIndex(where: { $0.id == userCardID }),
              let bi = cards[ci].benefitStates.firstIndex(where: { $0.id == benefitID })
        else { return }
        cards[ci].benefitStates[bi].status = .available
        save()
    }

    func resetExpiredBenefits() {
        var changed = false
        for ci in cards.indices {
            guard let def = cards[ci].definition else { continue }
            for bi in cards[ci].benefitStates.indices {
                if cards[ci].benefitStates[bi].needsReset,
                   let credit = def.statementCredits.first(where: { $0.description == cards[ci].benefitStates[bi].id }) {
                    cards[ci].benefitStates[bi].resetForNewPeriod(frequency: credit.frequency)
                    changed = true
                }
            }
        }
        if changed { save() }
    }

    // MARK: - Welcome Bonus Mutations

    func updateBonusSpend(userCardID: String, currentSpend: Double) {
        guard let ci = cards.firstIndex(where: { $0.id == userCardID }) else { return }
        cards[ci].welcomeBonus?.currentSpend = currentSpend
        save()
    }

    func startTrackingBonus(userCardID: String, targetSpend: Double, currentSpend: Double, deadline: Date?, bonusDescription: String?) {
        guard let ci = cards.firstIndex(where: { $0.id == userCardID }) else { return }
        cards[ci].welcomeBonus = WelcomeBonus(
            isTracking: true,
            targetSpend: targetSpend,
            currentSpend: currentSpend,
            deadline: deadline,
            bonusDescription: bonusDescription
        )
        save()
    }

    func stopTrackingBonus(userCardID: String) {
        guard let ci = cards.firstIndex(where: { $0.id == userCardID }) else { return }
        cards[ci].welcomeBonus = nil
        save()
    }

    // MARK: - Backfill

    private func backfillBenefitStates() {
        var changed = false
        for ci in cards.indices {
            guard let def = cards[ci].definition else { continue }
            if !def.statementCredits.isEmpty && cards[ci].benefitStates.isEmpty {
                cards[ci].benefitStates = UserBenefitState.initialStates(for: def.statementCredits)
                changed = true
            }
        }
        if changed { save() }
    }
}
