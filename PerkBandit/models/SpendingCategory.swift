//
//  SpendingCategory.swift
//  PerkBandit
//

import Foundation

enum SpendingCategory: String, CaseIterable, Identifiable {
    case dining, groceries, gas, travel, hotels, flights, streaming, drugstores, onlineShopping, other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dining: return "Dining"
        case .groceries: return "Groceries"
        case .gas: return "Gas"
        case .travel: return "Travel"
        case .hotels: return "Hotels"
        case .flights: return "Flights"
        case .streaming: return "Streaming"
        case .drugstores: return "Drugstores"
        case .onlineShopping: return "Online Shopping"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .dining: return "fork.knife"
        case .groceries: return "cart.fill"
        case .gas: return "fuelpump.fill"
        case .travel: return "airplane"
        case .hotels: return "building.2.fill"
        case .flights: return "airplane.departure"
        case .streaming: return "play.tv.fill"
        case .drugstores: return "cross.case.fill"
        case .onlineShopping: return "bag.fill"
        case .other: return "creditcard.fill"
        }
    }

    var keywords: [String] {
        switch self {
        case .dining: return ["dining", "restaurant"]
        case .groceries: return ["supermarket", "grocery"]
        case .gas: return ["gas station"]
        case .travel: return ["travel"]
        case .hotels: return ["hotel"]
        case .flights: return ["flight", "airline"]
        case .streaming: return ["streaming"]
        case .drugstores: return ["drugstore", "drug store"]
        case .onlineShopping: return ["online"]
        case .other: return ["everything"]
        }
    }

    func matches(rule: RewardRule) -> Bool {
        let lower = rule.category.lowercased()

        if self == .other {
            return lower.hasPrefix("everything")
        }

        // Exclude portal-only travel rules from general travel category
        if self == .travel && lower.contains("via ") {
            return false
        }

        return keywords.contains { lower.contains($0) }
    }

    static func parseMultiplier(_ s: String) -> Double {
        let cleaned = s.trimmingCharacters(in: .whitespaces)
        // Match leading numeric value: "4x", "6%", "1.5%", "2 pts/$1"
        guard let match = cleaned.range(of: #"[\d]+\.?\d*"#, options: .regularExpression) else {
            return 0
        }
        return Double(cleaned[match]) ?? 0
    }
}
