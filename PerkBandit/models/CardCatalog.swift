//
//  CardCatalog.swift
//  PerkBandit
//

import SwiftUI

struct CardColor: Hashable {
    let r: Double, g: Double, b: Double
    var color: Color { Color(red: r, green: g, blue: b) }
}

struct RewardRule: Hashable {
    let category: String
    let multiplier: String
    let capDescription: String?
}

struct StatementCredit: Hashable {
    let description: String
    let amount: String
    let notes: String?
}

struct CreditCard: Identifiable, Hashable {
    let id: String
    let name: String
    let issuer: String

    let annualFee: String
    let rewardRules: [RewardRule]
    let statementCredits: [StatementCredit]
    let activationRequired: String?
    let exclusions: [String]
    let sourceURL: String
    let lastVerified: String

    let network: String
    let accentColor: CardColor
    let gradientStart: CardColor
    let gradientEnd: CardColor
    let lastFour: String

    static func == (lhs: CreditCard, rhs: CreditCard) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private func stableLastFour(from id: String) -> String {
    var hash: UInt64 = 5381
    for byte in id.utf8 {
        hash = hash &* 33 &+ UInt64(byte)
    }
    let digits = hash % 10000
    return String(format: "%04d", digits)
}

func catalogCard(for id: String) -> CreditCard? {
    cardCatalog.first { $0.id == id }
}

let cardCatalog: [CreditCard] = [
    // MARK: - Chase
    CreditCard(
        id: "chase-sapphire-preferred",
        name: "Sapphire Preferred",
        issuer: "Chase",
        annualFee: "$95",
        rewardRules: [
            RewardRule(category: "Travel via Chase Travel", multiplier: "5x", capDescription: nil),
            RewardRule(category: "Dining", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Online grocery", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Streaming", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1x", capDescription: nil),
        ],
        statementCredits: [
            StatementCredit(description: "Hotel credit", amount: "$50/year", notes: "Via Chase Travel"),
        ],
        activationRequired: nil,
        exclusions: ["Target, Walmart, and wholesale clubs excluded from dining"],
        sourceURL: "https://creditcards.chase.com/rewards-credit-cards/sapphire/preferred",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.1, g: 0.2, b: 0.6),
        gradientStart: CardColor(r: 0.05, g: 0.10, b: 0.40),
        gradientEnd: CardColor(r: 0.02, g: 0.05, b: 0.25),
        lastFour: stableLastFour(from: "chase-sapphire-preferred")
    ),
    CreditCard(
        id: "chase-sapphire-reserve",
        name: "Sapphire Reserve",
        issuer: "Chase",
        annualFee: "$550",
        rewardRules: [
            RewardRule(category: "Travel via Chase Travel", multiplier: "10x", capDescription: nil),
            RewardRule(category: "Dining", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Travel", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1x", capDescription: nil),
        ],
        statementCredits: [
            StatementCredit(description: "Travel credit", amount: "$300/year", notes: nil),
        ],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://creditcards.chase.com/rewards-credit-cards/sapphire/reserve",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.15, g: 0.18, b: 0.35),
        gradientStart: CardColor(r: 0.08, g: 0.10, b: 0.28),
        gradientEnd: CardColor(r: 0.03, g: 0.04, b: 0.15),
        lastFour: stableLastFour(from: "chase-sapphire-reserve")
    ),
    CreditCard(
        id: "chase-freedom-unlimited",
        name: "Freedom Unlimited",
        issuer: "Chase",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "Travel via Chase Travel", multiplier: "5x", capDescription: nil),
            RewardRule(category: "Dining", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Drugstores", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1.5%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://creditcards.chase.com/cash-back-credit-cards/freedom/unlimited",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.15, g: 0.35, b: 0.70),
        gradientStart: CardColor(r: 0.10, g: 0.25, b: 0.55),
        gradientEnd: CardColor(r: 0.05, g: 0.15, b: 0.35),
        lastFour: stableLastFour(from: "chase-freedom-unlimited")
    ),
    CreditCard(
        id: "chase-freedom-flex",
        name: "Freedom Flex",
        issuer: "Chase",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "Quarterly bonus categories", multiplier: "5%", capDescription: "Up to $1,500/quarter"),
            RewardRule(category: "Travel via Chase Travel", multiplier: "5x", capDescription: nil),
            RewardRule(category: "Dining", multiplier: "3%", capDescription: nil),
            RewardRule(category: "Drugstores", multiplier: "3%", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: "Enroll in quarterly categories",
        exclusions: [],
        sourceURL: "https://creditcards.chase.com/cash-back-credit-cards/freedom/flex",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.10, g: 0.30, b: 0.65),
        gradientStart: CardColor(r: 0.06, g: 0.20, b: 0.50),
        gradientEnd: CardColor(r: 0.03, g: 0.10, b: 0.30),
        lastFour: stableLastFour(from: "chase-freedom-flex")
    ),
    CreditCard(
        id: "chase-ink-preferred",
        name: "Ink Business Preferred",
        issuer: "Chase",
        annualFee: "$95",
        rewardRules: [
            RewardRule(category: "Travel, shipping, internet, phone, advertising", multiplier: "3x", capDescription: "First $150,000/year"),
            RewardRule(category: "Everything else", multiplier: "1x", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://creditcards.chase.com/business-credit-cards/ink/business-preferred",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.12, g: 0.15, b: 0.40),
        gradientStart: CardColor(r: 0.08, g: 0.10, b: 0.30),
        gradientEnd: CardColor(r: 0.04, g: 0.05, b: 0.18),
        lastFour: stableLastFour(from: "chase-ink-preferred")
    ),

    // MARK: - Amex
    CreditCard(
        id: "amex-gold",
        name: "Gold Card",
        issuer: "Amex",
        annualFee: "$250",
        rewardRules: [
            RewardRule(category: "Restaurants worldwide", multiplier: "4x", capDescription: nil),
            RewardRule(category: "U.S. supermarkets", multiplier: "4x", capDescription: "Up to $25,000/year"),
            RewardRule(category: "Flights booked via Amex Travel or directly with airlines", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1x", capDescription: nil),
        ],
        statementCredits: [
            StatementCredit(description: "Dining credit", amount: "$120/year", notes: "Up to $10/month at select restaurants"),
            StatementCredit(description: "Uber Cash", amount: "$120/year", notes: "Up to $10/month"),
        ],
        activationRequired: nil,
        exclusions: ["Superstores (Walmart, Target) excluded from supermarket category"],
        sourceURL: "https://www.americanexpress.com/us/credit-cards/card/gold-card/",
        lastVerified: "2026-08-01",
        network: "AMEX",
        accentColor: CardColor(r: 0.85, g: 0.70, b: 0.30),
        gradientStart: CardColor(r: 0.75, g: 0.60, b: 0.20),
        gradientEnd: CardColor(r: 0.55, g: 0.42, b: 0.12),
        lastFour: stableLastFour(from: "amex-gold")
    ),
    CreditCard(
        id: "amex-platinum",
        name: "Platinum Card",
        issuer: "Amex",
        annualFee: "$695",
        rewardRules: [
            RewardRule(category: "Flights booked via Amex Travel", multiplier: "5x", capDescription: nil),
            RewardRule(category: "Flights booked directly with airlines", multiplier: "5x", capDescription: nil),
            RewardRule(category: "Prepaid hotels via Amex Travel", multiplier: "5x", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1x", capDescription: nil),
        ],
        statementCredits: [
            StatementCredit(description: "Airline fee credit", amount: "$200/year", notes: "Incidental fees on selected airline"),
            StatementCredit(description: "Hotel credit", amount: "$200/year", notes: "Via Amex Travel"),
            StatementCredit(description: "Digital entertainment", amount: "$240/year", notes: "Up to $20/month"),
            StatementCredit(description: "Uber Cash", amount: "$200/year", notes: "$15/month + $20 December"),
            StatementCredit(description: "Saks Fifth Avenue", amount: "$100/year", notes: "Up to $50 semiannually"),
        ],
        activationRequired: "Select airline for fee credit",
        exclusions: [],
        sourceURL: "https://www.americanexpress.com/us/credit-cards/card/platinum/",
        lastVerified: "2026-08-01",
        network: "AMEX",
        accentColor: CardColor(r: 0.75, g: 0.75, b: 0.78),
        gradientStart: CardColor(r: 0.45, g: 0.45, b: 0.48),
        gradientEnd: CardColor(r: 0.25, g: 0.25, b: 0.28),
        lastFour: stableLastFour(from: "amex-platinum")
    ),
    CreditCard(
        id: "amex-blue-cash-preferred",
        name: "Blue Cash Preferred",
        issuer: "Amex",
        annualFee: "$0 intro, then $95",
        rewardRules: [
            RewardRule(category: "U.S. supermarkets", multiplier: "6%", capDescription: "Up to $6,000/year"),
            RewardRule(category: "Streaming", multiplier: "6%", capDescription: nil),
            RewardRule(category: "U.S. gas stations", multiplier: "3%", capDescription: nil),
            RewardRule(category: "Transit", multiplier: "3%", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: ["Superstores (Walmart, Target) excluded from supermarket category"],
        sourceURL: "https://www.americanexpress.com/us/credit-cards/card/blue-cash-preferred/",
        lastVerified: "2026-08-01",
        network: "AMEX",
        accentColor: CardColor(r: 0.10, g: 0.40, b: 0.70),
        gradientStart: CardColor(r: 0.05, g: 0.25, b: 0.50),
        gradientEnd: CardColor(r: 0.02, g: 0.15, b: 0.32),
        lastFour: stableLastFour(from: "amex-blue-cash-preferred")
    ),
    CreditCard(
        id: "amex-blue-cash-everyday",
        name: "Blue Cash Everyday",
        issuer: "Amex",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "U.S. supermarkets", multiplier: "3%", capDescription: "Up to $6,000/year"),
            RewardRule(category: "U.S. online retail purchases", multiplier: "3%", capDescription: nil),
            RewardRule(category: "U.S. gas stations", multiplier: "3%", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: ["Superstores excluded from supermarket category"],
        sourceURL: "https://www.americanexpress.com/us/credit-cards/card/blue-cash-everyday/",
        lastVerified: "2026-08-01",
        network: "AMEX",
        accentColor: CardColor(r: 0.20, g: 0.50, b: 0.75),
        gradientStart: CardColor(r: 0.10, g: 0.35, b: 0.55),
        gradientEnd: CardColor(r: 0.05, g: 0.20, b: 0.35),
        lastFour: stableLastFour(from: "amex-blue-cash-everyday")
    ),
    CreditCard(
        id: "amex-business-gold",
        name: "Business Gold",
        issuer: "Amex",
        annualFee: "$375",
        rewardRules: [
            RewardRule(category: "Top 2 spending categories each month", multiplier: "4x", capDescription: "Up to $150,000/year across both"),
            RewardRule(category: "Everything else", multiplier: "1x", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: ["Categories: airfare, advertising, gas, shipping, computing, restaurants"],
        sourceURL: "https://www.americanexpress.com/us/credit-cards/business/business-credit-cards/american-express-business-gold-card-amex/",
        lastVerified: "2026-08-01",
        network: "AMEX",
        accentColor: CardColor(r: 0.80, g: 0.65, b: 0.25),
        gradientStart: CardColor(r: 0.65, g: 0.50, b: 0.15),
        gradientEnd: CardColor(r: 0.45, g: 0.35, b: 0.10),
        lastFour: stableLastFour(from: "amex-business-gold")
    ),

    // MARK: - Capital One
    CreditCard(
        id: "capital-one-venture",
        name: "Venture Rewards",
        issuer: "Capital One",
        annualFee: "$95",
        rewardRules: [
            RewardRule(category: "Hotels & rental cars via Capital One Travel", multiplier: "5x", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "2x", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://www.capitalone.com/credit-cards/venture/",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.55, g: 0.15, b: 0.15),
        gradientStart: CardColor(r: 0.30, g: 0.08, b: 0.08),
        gradientEnd: CardColor(r: 0.18, g: 0.04, b: 0.04),
        lastFour: stableLastFour(from: "capital-one-venture")
    ),
    CreditCard(
        id: "capital-one-venture-x",
        name: "Venture X",
        issuer: "Capital One",
        annualFee: "$395",
        rewardRules: [
            RewardRule(category: "Hotels & rental cars via Capital One Travel", multiplier: "10x", capDescription: nil),
            RewardRule(category: "Flights via Capital One Travel", multiplier: "5x", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "2x", capDescription: nil),
        ],
        statementCredits: [
            StatementCredit(description: "Travel credit", amount: "$300/year", notes: "Via Capital One Travel"),
        ],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://www.capitalone.com/credit-cards/venture-x/",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.20, g: 0.20, b: 0.22),
        gradientStart: CardColor(r: 0.12, g: 0.12, b: 0.14),
        gradientEnd: CardColor(r: 0.05, g: 0.05, b: 0.07),
        lastFour: stableLastFour(from: "capital-one-venture-x")
    ),
    CreditCard(
        id: "capital-one-savor-one",
        name: "SavorOne",
        issuer: "Capital One",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "Dining", multiplier: "3%", capDescription: nil),
            RewardRule(category: "Entertainment", multiplier: "3%", capDescription: nil),
            RewardRule(category: "Streaming", multiplier: "3%", capDescription: nil),
            RewardRule(category: "Grocery stores", multiplier: "3%", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://www.capitalone.com/credit-cards/savorone-dining-rewards/",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.45, g: 0.55, b: 0.35),
        gradientStart: CardColor(r: 0.20, g: 0.30, b: 0.15),
        gradientEnd: CardColor(r: 0.10, g: 0.18, b: 0.08),
        lastFour: stableLastFour(from: "capital-one-savor-one")
    ),
    CreditCard(
        id: "capital-one-quicksilver",
        name: "Quicksilver",
        issuer: "Capital One",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "Everything", multiplier: "1.5%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://www.capitalone.com/credit-cards/quicksilver/",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.40, g: 0.45, b: 0.50),
        gradientStart: CardColor(r: 0.25, g: 0.28, b: 0.32),
        gradientEnd: CardColor(r: 0.12, g: 0.14, b: 0.18),
        lastFour: stableLastFour(from: "capital-one-quicksilver")
    ),
    CreditCard(
        id: "capital-one-savor",
        name: "Savor",
        issuer: "Capital One",
        annualFee: "$95",
        rewardRules: [
            RewardRule(category: "Dining", multiplier: "4%", capDescription: nil),
            RewardRule(category: "Entertainment", multiplier: "4%", capDescription: nil),
            RewardRule(category: "Streaming", multiplier: "4%", capDescription: nil),
            RewardRule(category: "Grocery stores", multiplier: "3%", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://www.capitalone.com/credit-cards/savor-dining-rewards/",
        lastVerified: "2026-08-01",
        network: "MC",
        accentColor: CardColor(r: 0.60, g: 0.35, b: 0.15),
        gradientStart: CardColor(r: 0.28, g: 0.15, b: 0.05),
        gradientEnd: CardColor(r: 0.18, g: 0.08, b: 0.02),
        lastFour: stableLastFour(from: "capital-one-savor")
    ),

    // MARK: - Citi
    CreditCard(
        id: "citi-strata-premier",
        name: "Strata Premier",
        issuer: "Citi",
        annualFee: "$95",
        rewardRules: [
            RewardRule(category: "Flights", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Hotels", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Restaurants", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Supermarkets", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Gas stations", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1x", capDescription: nil),
        ],
        statementCredits: [
            StatementCredit(description: "Hotel credit", amount: "$100/year", notes: "Via thankyou.com"),
        ],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://www.citi.com/credit-cards/citi-strata-premier-credit-card",
        lastVerified: "2026-08-01",
        network: "MC",
        accentColor: CardColor(r: 0.15, g: 0.25, b: 0.55),
        gradientStart: CardColor(r: 0.10, g: 0.15, b: 0.40),
        gradientEnd: CardColor(r: 0.05, g: 0.08, b: 0.25),
        lastFour: stableLastFour(from: "citi-strata-premier")
    ),
    CreditCard(
        id: "citi-double-cash",
        name: "Double Cash",
        issuer: "Citi",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "Everything", multiplier: "2%", capDescription: "1% on purchase + 1% on payment"),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://www.citi.com/credit-cards/citi-double-cash-credit-card",
        lastVerified: "2026-08-01",
        network: "MC",
        accentColor: CardColor(r: 0.20, g: 0.35, b: 0.60),
        gradientStart: CardColor(r: 0.05, g: 0.20, b: 0.45),
        gradientEnd: CardColor(r: 0.02, g: 0.10, b: 0.28),
        lastFour: stableLastFour(from: "citi-double-cash")
    ),
    CreditCard(
        id: "citi-custom-cash",
        name: "Custom Cash",
        issuer: "Citi",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "Top eligible spend category each cycle", multiplier: "5%", capDescription: "Up to $500/cycle"),
            RewardRule(category: "Everything else", multiplier: "1%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: ["Auto-selects top category from: restaurants, gas, grocery, travel, transit, streaming, drugstores, fitness, home improvement, live entertainment"],
        sourceURL: "https://www.citi.com/credit-cards/citi-custom-cash-credit-card",
        lastVerified: "2026-08-01",
        network: "MC",
        accentColor: CardColor(r: 0.30, g: 0.45, b: 0.55),
        gradientStart: CardColor(r: 0.15, g: 0.28, b: 0.38),
        gradientEnd: CardColor(r: 0.08, g: 0.15, b: 0.22),
        lastFour: stableLastFour(from: "citi-custom-cash")
    ),

    // MARK: - Discover
    CreditCard(
        id: "discover-it-cash-back",
        name: "Discover it Cash Back",
        issuer: "Discover",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "Quarterly rotating categories", multiplier: "5%", capDescription: "Up to $1,500/quarter"),
            RewardRule(category: "Everything else", multiplier: "1%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: "Enroll in quarterly categories",
        exclusions: [],
        sourceURL: "https://www.discover.com/credit-cards/cash-back/it-card.html",
        lastVerified: "2026-08-01",
        network: "DISC",
        accentColor: CardColor(r: 0.85, g: 0.50, b: 0.15),
        gradientStart: CardColor(r: 0.70, g: 0.38, b: 0.08),
        gradientEnd: CardColor(r: 0.50, g: 0.25, b: 0.05),
        lastFour: stableLastFour(from: "discover-it-cash-back")
    ),

    // MARK: - Wells Fargo
    CreditCard(
        id: "wells-fargo-active-cash",
        name: "Active Cash",
        issuer: "Wells Fargo",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "Everything", multiplier: "2%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://creditcards.wellsfargo.com/active-cash-credit-card",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.70, g: 0.15, b: 0.15),
        gradientStart: CardColor(r: 0.55, g: 0.10, b: 0.10),
        gradientEnd: CardColor(r: 0.35, g: 0.05, b: 0.05),
        lastFour: stableLastFour(from: "wells-fargo-active-cash")
    ),
    CreditCard(
        id: "wells-fargo-autograph",
        name: "Autograph",
        issuer: "Wells Fargo",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "Restaurants", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Travel", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Gas stations", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Transit", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Streaming", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Phone plans", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1x", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://creditcards.wellsfargo.com/autograph-visa-credit-card",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.60, g: 0.20, b: 0.20),
        gradientStart: CardColor(r: 0.40, g: 0.12, b: 0.12),
        gradientEnd: CardColor(r: 0.25, g: 0.06, b: 0.06),
        lastFour: stableLastFour(from: "wells-fargo-autograph")
    ),
    CreditCard(
        id: "wells-fargo-autograph-journey",
        name: "Autograph Journey",
        issuer: "Wells Fargo",
        annualFee: "$95",
        rewardRules: [
            RewardRule(category: "Hotels", multiplier: "5x", capDescription: nil),
            RewardRule(category: "Airlines", multiplier: "4x", capDescription: nil),
            RewardRule(category: "Restaurants", multiplier: "3x", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1x", capDescription: nil),
        ],
        statementCredits: [
            StatementCredit(description: "Airline credit", amount: "$50/year", notes: "On selected airline purchases"),
        ],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://creditcards.wellsfargo.com/autograph-journey-visa-credit-card",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.50, g: 0.22, b: 0.22),
        gradientStart: CardColor(r: 0.35, g: 0.14, b: 0.14),
        gradientEnd: CardColor(r: 0.20, g: 0.08, b: 0.08),
        lastFour: stableLastFour(from: "wells-fargo-autograph-journey")
    ),

    // MARK: - Bank of America
    CreditCard(
        id: "bofa-customized-cash",
        name: "Customized Cash Rewards",
        issuer: "Bank of America",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "Choice category", multiplier: "3%", capDescription: "Up to $2,500/quarter"),
            RewardRule(category: "Grocery & wholesale clubs", multiplier: "2%", capDescription: "Up to $2,500/quarter"),
            RewardRule(category: "Everything else", multiplier: "1%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: "Select your 3% category online",
        exclusions: ["Choice categories: gas, online shopping, dining, travel, drug stores, home improvement"],
        sourceURL: "https://www.bankofamerica.com/credit-cards/products/customized-cash-rewards-credit-card/",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.70, g: 0.15, b: 0.20),
        gradientStart: CardColor(r: 0.50, g: 0.08, b: 0.12),
        gradientEnd: CardColor(r: 0.30, g: 0.04, b: 0.06),
        lastFour: stableLastFour(from: "bofa-customized-cash")
    ),
    CreditCard(
        id: "bofa-premium-rewards",
        name: "Premium Rewards",
        issuer: "Bank of America",
        annualFee: "$95",
        rewardRules: [
            RewardRule(category: "Travel", multiplier: "2 pts/$1", capDescription: nil),
            RewardRule(category: "Dining", multiplier: "2 pts/$1", capDescription: nil),
            RewardRule(category: "Everything else", multiplier: "1.5 pts/$1", capDescription: nil),
        ],
        statementCredits: [
            StatementCredit(description: "Airline incidental credit", amount: "$100/year", notes: "TSA PreCheck/Global Entry every 4 years"),
        ],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://www.bankofamerica.com/credit-cards/products/premium-rewards-credit-card/",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.55, g: 0.18, b: 0.22),
        gradientStart: CardColor(r: 0.38, g: 0.10, b: 0.14),
        gradientEnd: CardColor(r: 0.22, g: 0.05, b: 0.08),
        lastFour: stableLastFour(from: "bofa-premium-rewards")
    ),
    CreditCard(
        id: "bofa-unlimited-cash",
        name: "Unlimited Cash Rewards",
        issuer: "Bank of America",
        annualFee: "$0",
        rewardRules: [
            RewardRule(category: "Everything", multiplier: "1.5%", capDescription: nil),
        ],
        statementCredits: [],
        activationRequired: nil,
        exclusions: [],
        sourceURL: "https://www.bankofamerica.com/credit-cards/products/unlimited-cash-back-credit-card/",
        lastVerified: "2026-08-01",
        network: "VISA",
        accentColor: CardColor(r: 0.65, g: 0.20, b: 0.22),
        gradientStart: CardColor(r: 0.45, g: 0.10, b: 0.12),
        gradientEnd: CardColor(r: 0.28, g: 0.05, b: 0.07),
        lastFour: stableLastFour(from: "bofa-unlimited-cash")
    ),
]
