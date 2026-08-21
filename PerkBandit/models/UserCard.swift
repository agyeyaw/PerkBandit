//
//  UserCard.swift
//  PerkBandit
//

import Foundation

// How the card's transactions are tracked
enum TrackingMode: String, Codable {
    case manual
    case linked  // future Plaid
}

// User's state for a single statement credit / benefit
struct UserBenefitState: Codable, Identifiable {
    var id: String              // matches StatementCredit.description from catalog
    var status: BenefitUsageStatus
    var amountUsed: Double?
    var lastResetDate: Date?
    var periodStart: Date?
    var periodEnd: Date?

    var daysUntilExpiry: Int? {
        guard let end = periodEnd else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: end).day
    }

    var isExpiringSoon: Bool {
        guard status != .used, let days = daysUntilExpiry else { return false }
        return days >= 0 && days <= 7
    }

    var expiryText: String? {
        guard let days = daysUntilExpiry else { return nil }
        if days < 0 { return "Expired" }
        if days == 0 { return "Expires today" }
        if days == 1 { return "Expires tomorrow" }
        return "Expires in \(days) days"
    }

    var needsReset: Bool {
        guard let end = periodEnd else { return false }
        return Date() > end
    }

    static func currentPeriod(for frequency: BenefitFrequency, asOf date: Date = Date()) -> (start: Date, end: Date) {
        let cal = Calendar.current
        switch frequency {
        case .monthly:
            let start = cal.date(from: cal.dateComponents([.year, .month], from: date))!
            let end = cal.date(byAdding: DateComponents(month: 1, day: -1), to: start)!
            return (start, end)
        case .quarterly:
            let month = cal.component(.month, from: date)
            let year = cal.component(.year, from: date)
            let qStart = ((month - 1) / 3) * 3 + 1  // 1, 4, 7, or 10
            let start = cal.date(from: DateComponents(year: year, month: qStart, day: 1))!
            let end = cal.date(byAdding: DateComponents(month: 3, day: -1), to: start)!
            return (start, end)
        case .semiannual:
            let month = cal.component(.month, from: date)
            let year = cal.component(.year, from: date)
            let periodMonth = month <= 6 ? 1 : 7
            let start = cal.date(from: DateComponents(year: year, month: periodMonth, day: 1))!
            let end = cal.date(byAdding: DateComponents(month: 6, day: -1), to: start)!
            return (start, end)
        case .annual, .oneTime:
            let year = cal.component(.year, from: date)
            let start = cal.date(from: DateComponents(year: year, month: 1, day: 1))!
            let end = cal.date(from: DateComponents(year: year, month: 12, day: 31))!
            return (start, end)
        }
    }

    static func initialStates(for credits: [StatementCredit], asOf date: Date = Date()) -> [UserBenefitState] {
        credits.map { credit in
            let period = currentPeriod(for: credit.frequency, asOf: date)
            return UserBenefitState(
                id: credit.description,
                status: .notSure,
                periodStart: period.start,
                periodEnd: period.end
            )
        }
    }

    mutating func resetForNewPeriod(frequency: BenefitFrequency) {
        status = .available
        amountUsed = nil
        let period = Self.currentPeriod(for: frequency)
        periodStart = period.start
        periodEnd = period.end
        lastResetDate = Date()
    }
}

enum BenefitUsageStatus: String, Codable {
    case available, used, notSure
}

// User's welcome bonus tracking for one card
struct WelcomeBonus: Codable {
    var isTracking: Bool
    var targetSpend: Double?
    var currentSpend: Double?
    var deadline: Date?
    var bonusDescription: String?
}

// The user's personal copy of a card
struct UserCard: Identifiable, Codable {
    let id: String                     // unique per user-card instance (UUID string)
    let cardDefinitionID: String       // FK → CreditCard.id in card catalog
    var trackingMode: TrackingMode

    var dateAdded: Date
    var dateOpened: Date?
    var renewalDate: Date?
    var benefitStates: [UserBenefitState]
    var welcomeBonus: WelcomeBonus?
    var activatedThisPeriod: Bool?

    // Resolve to catalog definition
    var definition: CreditCard? {
        catalogCard(for: cardDefinitionID)
    }
}

extension UserCard {
    /// Create a minimal UserCard from a catalog card ID
    static func fromCatalog(id: String, trackingMode: TrackingMode = .manual) -> UserCard {
        let credits = catalogCard(for: id)?.statementCredits ?? []
        return UserCard(
            id: UUID().uuidString,
            cardDefinitionID: id,
            trackingMode: trackingMode,
            dateAdded: Date(),
            benefitStates: UserBenefitState.initialStates(for: credits)
        )
    }

    /// Create from a full CreditCard object
    static func fromCatalog(_ card: CreditCard, trackingMode: TrackingMode = .manual) -> UserCard {
        fromCatalog(id: card.id, trackingMode: trackingMode)
    }
}
