//
//  Opportunity.swift
//  PerkBandit
//

import Foundation

// MARK: - Data Confidence

enum DataConfidence: Int, Comparable, Equatable {
    case verified = 0    // catalog data or user-confirmed
    case estimated = 1   // calculated from user input
    case inferred = 2    // best guess from partial data

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

// MARK: - Opportunity Type

enum OpportunityType: Equatable {
    case expiringBenefit
    case welcomeBonus
    case categoryActivation
    case annualFeeReview
    case cardRecommendation

    var priority: Int {
        switch self {
        case .expiringBenefit: return 1
        case .welcomeBonus: return 2
        case .categoryActivation: return 3
        case .annualFeeReview: return 4
        case .cardRecommendation: return 5
        }
    }
}

// MARK: - Opportunity Urgency

enum OpportunityUrgency: Int, Comparable, Equatable {
    case critical = 0
    case high = 1
    case medium = 2
    case low = 3

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .critical: return "Urgent"
        case .high: return "Expiring"
        case .medium: return "Action"
        case .low: return "Info"
        }
    }
}

// MARK: - Opportunity

struct Opportunity: Identifiable, Equatable {
    let id: String
    let type: OpportunityType
    let title: String
    let subtitle: String
    let estimatedValue: Decimal?
    let urgency: OpportunityUrgency
    let cardDefinitionID: String?
    let userCardID: String?
    let explanation: String
    let icon: String
    let iconColor: String
    let expirationDate: Date?
    let confidence: DataConfidence
    let progress: Double?
    let benefitID: String?
}
