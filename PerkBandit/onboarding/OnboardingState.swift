//
//  OnboardingState.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import Foundation
import Combine

enum UserOnboardingStep {
    case nameEntry, goals, setupMethod, manualCards, confirmCards, connectAccounts, demo
    case welcomeBonus, benefitStatus, recommendationPrefs, pointValuation
    case notifications, dataConfidence, firstValue, auth, completion
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
    /// Parse a user-entered deadline string into a Date.
    /// Supports ISO8601 (from DatePicker), "MMMM d", "MMMM d, yyyy", "MMM d, yyyy", "MM/dd/yyyy", "MM/dd".
    private static func parseDeadline(_ text: String) -> Date? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Try ISO8601 first (from DatePicker storage)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: trimmed) { return date }

        // Also try ISO8601 with fractional seconds
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: trimmed) { return date }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let formatsWithYear = ["MMMM d, yyyy", "MMM d, yyyy", "MM/dd/yyyy"]
        for fmt in formatsWithYear {
            formatter.dateFormat = fmt
            if let date = formatter.date(from: trimmed) { return date }
        }

        // Formats without year — assume current year, bump to next year if date is past
        let formatsNoYear = ["MMMM d", "MMM d", "MM/dd"]
        let cal = Calendar.current
        let now = Date()
        let currentYear = cal.component(.year, from: now)
        for fmt in formatsNoYear {
            formatter.dateFormat = fmt
            if var date = formatter.date(from: trimmed) {
                // The parsed date has year 2000; replace with current year
                var comps = cal.dateComponents([.month, .day], from: date)
                comps.year = currentYear
                date = cal.date(from: comps) ?? date
                if date < now {
                    comps.year = currentYear + 1
                    date = cal.date(from: comps) ?? date
                }
                return date
            }
        }

        return nil
    }

    static func markCompleted(
        selectedCards: [String] = [],
        bonusStatuses: [String: String] = [:],
        bonusDetails: [String: WelcomeBonusDetail] = [:],
        benefitStatuses: [String: String] = [:]
    ) {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Build UserCard array from onboarding data
        let userCards: [UserCard] = selectedCards.compactMap { cardId in
            guard catalogCard(for: cardId) != nil else { return nil }
            var uc = UserCard.fromCatalog(id: cardId)

            // Carry over welcome bonus if user said "yes"
            if bonusStatuses[cardId] == "yes", let detail = bonusDetails[cardId] {
                uc.welcomeBonus = WelcomeBonus(
                    isTracking: true,
                    targetSpend: Double(detail.spendingRequirement
                        .replacingOccurrences(of: "$", with: "")
                        .replacingOccurrences(of: ",", with: "")),
                    currentSpend: Double(detail.amountSpent
                        .replacingOccurrences(of: "$", with: "")
                        .replacingOccurrences(of: ",", with: "")),
                    deadline: parseDeadline(detail.deadline),
                    bonusDescription: detail.bonusReward
                )
            }

            // Apply benefit status overrides from onboarding
            for i in uc.benefitStates.indices {
                if let statusStr = benefitStatuses[uc.benefitStates[i].id],
                   let status = BenefitUsageStatus(rawValue: statusStr) {
                    uc.benefitStates[i].status = status
                }
            }

            return uc
        }

        if let data = try? JSONEncoder().encode(userCards) {
            UserDefaults.standard.set(data, forKey: "userCards")
        }

        // Keep legacy key for backward compat during transition
        UserDefaults.standard.set(selectedCards, forKey: "userSelectedCardIDs")
    }
    #if DEBUG
    static func reset() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "userSelectedCardIDs")
        UserDefaults.standard.removeObject(forKey: "userCards")
    }
    #endif
}
