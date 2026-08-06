//
//  OnboardingState.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import Foundation
import Combine

enum UserOnboardingStep {
    case scoutIntro, nameEntry, goals, setupMethod, manualCards, confirmCards, connectAccounts, demo
    case welcomeBonus, benefitStatus, recommendationPrefs, pointValuation
    case notifications, dataConfidence, firstValue, completion
}

enum SetupMethod {
    case manual, connect, demo
}

struct WelcomeBonusDetail {
    var spendingRequirement: String = ""
    var amountSpent: String = ""
    var deadline: String = ""
    var bonusReward: String = ""
}

class OnboardingState: ObservableObject {
    @Published var userName: String = ""
    @Published var selectedGoals: Set<String> = []
    @Published var setupMethod: SetupMethod? = nil
    @Published var selectedCards: [String] = []
    @Published var isDemoMode: Bool = false
    @Published var notificationsEnabled: Bool = false

    // Welcome bonus
    @Published var cardBonusStatuses: [String: String] = [:]       // cardId → "yes"/"notNow"/"notSure"
    @Published var cardBonusDetails: [String: WelcomeBonusDetail] = [:]

    // Benefit status
    @Published var benefitStatuses: [String: String] = [:]         // benefit name → "available"/"used"/"notSure"

    // Recommendation preferences
    @Published var recommendationPrefs: Set<String> = []

    // Point valuation
    @Published var pointValuation: String = "perkbandit"           // "perkbandit" / "cashback" / "custom"
}

enum OnboardingPersistence {
    static func markCompleted(selectedCards: [String] = []) {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(selectedCards, forKey: "userSelectedCardIDs")
    }
    #if DEBUG
    static func reset() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "userSelectedCardIDs")
    }
    #endif
}
