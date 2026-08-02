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

struct CreditCard: Identifiable {
    let id: String
    let name: String
    let issuer: String
}

let mockCardCatalog: [CreditCard] = [
    CreditCard(id: "chase-sapphire-preferred", name: "Sapphire Preferred", issuer: "Chase"),
    CreditCard(id: "chase-sapphire-reserve", name: "Sapphire Reserve", issuer: "Chase"),
    CreditCard(id: "chase-freedom-unlimited", name: "Freedom Unlimited", issuer: "Chase"),
    CreditCard(id: "amex-platinum", name: "Platinum Card", issuer: "Amex"),
    CreditCard(id: "amex-gold", name: "Gold Card", issuer: "Amex"),
    CreditCard(id: "amex-blue-cash-preferred", name: "Blue Cash Preferred", issuer: "Amex"),
    CreditCard(id: "citi-double-cash", name: "Double Cash", issuer: "Citi"),
    CreditCard(id: "citi-premier", name: "Premier Card", issuer: "Citi"),
    CreditCard(id: "capital-one-venture", name: "Venture Rewards", issuer: "Capital One"),
    CreditCard(id: "capital-one-savor", name: "Savor Cash Rewards", issuer: "Capital One"),
]

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
