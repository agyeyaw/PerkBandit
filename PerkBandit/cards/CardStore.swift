//
//  CardStore.swift
//  PerkBandit
//

import Foundation
import Combine

class CardStore: ObservableObject {
    @Published var cards: [MockCard]
    @Published var isUserSelected: Bool

    init() {
        let savedIDs = UserDefaults.standard.stringArray(forKey: "userSelectedCardIDs") ?? []
        let mapped = MockCard.forCatalogIDs(savedIDs)
        if mapped.isEmpty {
            cards = MockCard.samples
            isUserSelected = false
        } else {
            cards = mapped
            isUserSelected = true
        }
    }

    func reload() {
        let savedIDs = UserDefaults.standard.stringArray(forKey: "userSelectedCardIDs") ?? []
        let mapped = MockCard.forCatalogIDs(savedIDs)
        if mapped.isEmpty {
            cards = MockCard.samples
            isUserSelected = false
        } else {
            cards = mapped
            isUserSelected = true
        }
    }
}
