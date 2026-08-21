//
//  CardCatalogService.swift
//  PerkBandit
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class CardCatalogService: ObservableObject {
    @Published private(set) var cards: [CreditCard] = embeddedCardCatalog
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: Error?

    private var cardsByID: [String: CreditCard] = cardCatalogIndex

    func card(for id: String) -> CreditCard? { cardsByID[id] }

    func fetchCatalog() async {
        isLoading = true
        lastError = nil

        do {
            let snapshot = try await Firestore.firestore()
                .collection("cardCatalog")
                .getDocuments()

            let fetched: [CreditCard] = snapshot.documents.compactMap { doc in
                try? doc.data(as: CreditCard.self)
            }

            if !fetched.isEmpty {
                cards = fetched
                cardsByID = Dictionary(uniqueKeysWithValues: fetched.map { ($0.id, $0) })
                cardCatalogIndex = cardsByID
            }
        } catch {
            lastError = error
            // Keep embedded fallback — cards and cardCatalogIndex unchanged
        }

        isLoading = false
    }

    #if DEBUG
    static func seedFirestoreCatalog() async {
        let db = Firestore.firestore()
        for card in embeddedCardCatalog {
            do {
                try db.collection("cardCatalog").document(card.id).setData(from: card)
            } catch {
                print("[Seed] Failed: \(card.id) — \(error)")
            }
        }
        print("[Seed] Done: \(embeddedCardCatalog.count) cards")
    }
    #endif
}
