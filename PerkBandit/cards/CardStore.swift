//
//  CardStore.swift
//  PerkBandit
//

import Foundation
import Combine

class CardStore: ObservableObject {
    @Published var cards: [UserCard]
    @Published var isUserSelected: Bool
    @Published var recommendationPrefs: Set<RecommendationPreference> = []
    @Published var pointValuation: String = "perkbandit"

    var hasCards: Bool { isUserSelected }

    // Convenience: resolved catalog cards for views that only need display
    var creditCards: [CreditCard] {
        cards.compactMap { $0.definition }
    }

    var opportunities: [Opportunity] {
        OpportunityEngine.generateOpportunities(cards: cards)
    }

    private let catalogService: CardCatalogService

    private static let storageKey = "userCards"
    private static let legacyKey = "userSelectedCardIDs"
    private static let prefsKey = "recommendationPrefs"
    private static let valuationKey = "pointValuation"

    private static let idMigrations: [String: String] = [
        "citi-premier": "citi-strata-premier",
    ]

    init(catalogService: CardCatalogService) {
        self.catalogService = catalogService
        // Try loading new UserCard format first
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode([UserCard].self, from: data),
           !saved.isEmpty {
            cards = saved
            isUserSelected = true
            backfillBenefitStates()
            resetExpiredBenefits()
            loadPreferencesFromCache()
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
            cards = Array(catalogService.cards.prefix(5)).map { UserCard.fromCatalog($0) }
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
        syncToFirestore()
    }

    private func syncToFirestore() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(cards),
              let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { return }
        Task {
            await UserProfileService.saveCardState(jsonArray)
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
            loadPreferencesFromCache()
            return
        }

        // Fall back to legacy key
        let savedIDs = UserDefaults.standard.stringArray(forKey: Self.legacyKey) ?? []
        let mapped = savedIDs.compactMap { id in
            guard catalogCard(for: id) != nil else { return nil as UserCard? }
            return UserCard.fromCatalog(id: id)
        }
        if mapped.isEmpty {
            cards = Array(catalogService.cards.prefix(5)).map { UserCard.fromCatalog($0) }
            isUserSelected = false
        } else {
            cards = mapped
            isUserSelected = true
        }
        resetExpiredBenefits()
        loadPreferencesFromCache()
    }

    // MARK: - Preferences

    func loadPreferencesFromCache() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.prefsKey) ?? []
        recommendationPrefs = Set(saved.compactMap { RecommendationPreference(from: $0) })
        pointValuation = UserDefaults.standard.string(forKey: Self.valuationKey) ?? "perkbandit"
    }

    func savePreferences() {
        UserDefaults.standard.set(recommendationPrefs.map(\.rawValue), forKey: Self.prefsKey)
        UserDefaults.standard.set(pointValuation, forKey: Self.valuationKey)
    }

    func loadPreferencesFromFirestore() async {
        guard let result = await UserProfileService.loadPreferences() else { return }
        await MainActor.run {
            self.recommendationPrefs = Set(result.prefs.compactMap { RecommendationPreference(from: $0) })
            self.pointValuation = result.valuation
            self.savePreferences()
        }
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

    // MARK: - Category Activation Mutations

    func markCategoryActivated(userCardID: String) {
        guard let ci = cards.firstIndex(where: { $0.id == userCardID }) else { return }
        cards[ci].activatedThisPeriod = true
        save()
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

    // MARK: - Remove Card

    func removeCard(userCardID: String) {
        cards.removeAll { $0.id == userCardID }
        if cards.isEmpty {
            isUserSelected = false
        }
        save()
    }
}
