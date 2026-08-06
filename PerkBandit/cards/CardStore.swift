//
//  CardStore.swift
//  PerkBandit
//

import Foundation
import Combine

class CardStore: ObservableObject {
    @Published var cards: [CreditCard]
    @Published var isUserSelected: Bool

    private static let idMigrations: [String: String] = [
        "citi-premier": "citi-strata-premier",
    ]

    init() {
        var savedIDs = UserDefaults.standard.stringArray(forKey: "userSelectedCardIDs") ?? []

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
            UserDefaults.standard.set(savedIDs, forKey: "userSelectedCardIDs")
        }

        let mapped = savedIDs.compactMap { catalogCard(for: $0) }
        if mapped.isEmpty {
            cards = Array(cardCatalog.prefix(5))
            isUserSelected = false
        } else {
            cards = mapped
            isUserSelected = true
        }
    }

    func reload() {
        let savedIDs = UserDefaults.standard.stringArray(forKey: "userSelectedCardIDs") ?? []
        let mapped = savedIDs.compactMap { catalogCard(for: $0) }
        if mapped.isEmpty {
            cards = Array(cardCatalog.prefix(5))
            isUserSelected = false
        } else {
            cards = mapped
            isUserSelected = true
        }
    }
}
