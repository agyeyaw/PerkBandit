//
//  UserProfileService.swift
//  PerkBandit
//

import FirebaseAuth
import FirebaseFirestore

enum UserProfileService {
    static func saveOnboardingData(_ state: OnboardingState) async {
        guard let user = Auth.auth().currentUser else {
            print("[UserProfileService] No authenticated user — skipping Firestore write.")
            return
        }

        // Update display name
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = state.userName
        do {
            try await changeRequest.commitChanges()
        } catch {
            print("[UserProfileService] Failed to update displayName: \(error.localizedDescription)")
        }

        // Build bonus details as nested maps
        var bonusDetailsMap: [String: [String: String]] = [:]
        for (cardId, detail) in state.cardBonusDetails {
            bonusDetailsMap[cardId] = [
                "spendingRequirement": detail.spendingRequirement,
                "amountSpent": detail.amountSpent,
                "deadline": detail.deadline,
                "bonusReward": detail.bonusReward
            ]
        }

        let data: [String: Any] = [
            "userName": state.userName,
            "email": user.email ?? "",
            "selectedGoals": Array(state.selectedGoals),
            "setupMethod": state.setupMethod.map { "\($0)" } ?? "none",
            "selectedCards": state.selectedCards,
            "isDemoMode": state.isDemoMode,
            "cardBonusStatuses": state.cardBonusStatuses,
            "cardBonusDetails": bonusDetailsMap,
            "benefitStatuses": state.benefitStatuses,
            "recommendationPrefs": Array(state.recommendationPrefs),
            "pointValuation": state.pointValuation,
            "notificationsEnabled": state.notificationsEnabled,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        do {
            try await Firestore.firestore().collection("users").document(user.uid).setData(data, merge: true)
            print("[UserProfileService] Onboarding data saved for uid: \(user.uid)")
        } catch {
            print("[UserProfileService] Firestore write failed: \(error.localizedDescription)")
        }
    }

    static func saveCardState(_ cardData: [[String: Any]]) async {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await Firestore.firestore().collection("users").document(user.uid)
                .setData(["cardState": cardData, "updatedAt": FieldValue.serverTimestamp()], merge: true)
        } catch {
            print("[UserProfileService] Card state sync failed: \(error)")
        }
    }

    static func deleteCard(cardDefinitionID: String) async {
        guard let user = Auth.auth().currentUser else { return }
        do {
            let docRef = Firestore.firestore().collection("users").document(user.uid)
            let doc = try await docRef.getDocument()
            guard var cardState = doc.data()?["cardState"] as? [[String: Any]] else { return }
            cardState.removeAll { ($0["cardDefinitionID"] as? String) == cardDefinitionID }
            try await docRef.setData(["cardState": cardState, "updatedAt": FieldValue.serverTimestamp()], merge: true)
        } catch {
            print("[UserProfileService] Card delete failed: \(error)")
        }
    }

    static func loadPreferences() async -> (prefs: Set<String>, valuation: String)? {
        guard let user = Auth.auth().currentUser else {
            print("[UserProfileService] No authenticated user — skipping Firestore read.")
            return nil
        }

        do {
            let doc = try await Firestore.firestore().collection("users").document(user.uid).getDocument()
            guard let data = doc.data() else { return nil }
            let prefs = Set(data["recommendationPrefs"] as? [String] ?? [])
            let valuation = data["pointValuation"] as? String ?? "perkbandit"
            return (prefs, valuation)
        } catch {
            print("[UserProfileService] Firestore read failed: \(error.localizedDescription)")
            return nil
        }
    }
}
