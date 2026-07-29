//
//  OnboardingState.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import Foundation
import Combine

enum UserOnboardingStep {
    case scoutIntro, goals, setupMethod, manualCards, connectAccounts, demo, notifications, completion
}

enum SetupMethod {
    case manual, connect, demo
}

class OnboardingState: ObservableObject {
    @Published var selectedGoals: Set<String> = []
    @Published var setupMethod: SetupMethod? = nil
    @Published var selectedCards: [String] = []
    @Published var isDemoMode: Bool = false
    @Published var notificationsEnabled: Bool = false
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
    static func markCompleted() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    #if DEBUG
    static func reset() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
    #endif
}
