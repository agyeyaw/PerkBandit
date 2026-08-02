//
//  CreditCardVisual.swift
//  PerkBandit
//

import SwiftUI

struct MockCard: Identifiable, Hashable {
    static func == (lhs: MockCard, rhs: MockCard) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: UUID
    let name: String
    let issuer: String
    let lastFour: String
    let balance: Double
    let networkMark: String
    let accentColor: Color
    let gradientColors: [Color]

    // Maps each mockCardCatalog ID to a MockCard with issuer-accurate visuals
    static let catalogCards: [String: MockCard] = [
        "chase-sapphire-preferred": MockCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Sapphire Preferred",
            issuer: "Chase",
            lastFour: "4821",
            balance: 2347.89,
            networkMark: "VISA",
            accentColor: Color(red: 0.1, green: 0.2, blue: 0.6),
            gradientColors: [Color(red: 0.05, green: 0.10, blue: 0.40), Color(red: 0.02, green: 0.05, blue: 0.25)]
        ),
        "chase-sapphire-reserve": MockCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            name: "Sapphire Reserve",
            issuer: "Chase",
            lastFour: "9103",
            balance: 5120.00,
            networkMark: "VISA",
            accentColor: Color(red: 0.15, green: 0.18, blue: 0.35),
            gradientColors: [Color(red: 0.08, green: 0.10, blue: 0.28), Color(red: 0.03, green: 0.04, blue: 0.15)]
        ),
        "chase-freedom-unlimited": MockCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            name: "Freedom Unlimited",
            issuer: "Chase",
            lastFour: "7256",
            balance: 891.42,
            networkMark: "VISA",
            accentColor: Color.blue,
            gradientColors: [Color(red: 0.10, green: 0.25, blue: 0.55), Color(red: 0.05, green: 0.15, blue: 0.35)]
        ),
        "amex-platinum": MockCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            name: "Platinum Card",
            issuer: "Amex",
            lastFour: "3390",
            balance: 8750.00,
            networkMark: "AMEX",
            accentColor: Color(red: 0.75, green: 0.75, blue: 0.78),
            gradientColors: [Color(red: 0.45, green: 0.45, blue: 0.48), Color(red: 0.25, green: 0.25, blue: 0.28)]
        ),
        "amex-gold": MockCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            name: "Gold Card",
            issuer: "Amex",
            lastFour: "6617",
            balance: 3415.60,
            networkMark: "AMEX",
            accentColor: Color(red: 0.85, green: 0.70, blue: 0.30),
            gradientColors: [Color(red: 0.75, green: 0.60, blue: 0.20), Color(red: 0.55, green: 0.42, blue: 0.12)]
        ),
        "amex-blue-cash-preferred": MockCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
            name: "Blue Cash Preferred",
            issuer: "Amex",
            lastFour: "1088",
            balance: 420.15,
            networkMark: "AMEX",
            accentColor: Color.cyan,
            gradientColors: [Color(red: 0.05, green: 0.25, blue: 0.50), Color(red: 0.02, green: 0.15, blue: 0.32)]
        ),
        "citi-double-cash": MockCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
            name: "Double Cash",
            issuer: "Citi",
            lastFour: "5432",
            balance: 156.30,
            networkMark: "MC",
            accentColor: Color.blue,
            gradientColors: [Color(red: 0.05, green: 0.20, blue: 0.45), Color(red: 0.02, green: 0.10, blue: 0.28)]
        ),
        "citi-premier": MockCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
            name: "Premier Card",
            issuer: "Citi",
            lastFour: "7153",
            balance: 2100.00,
            networkMark: "MC",
            accentColor: Color(red: 0.15, green: 0.25, blue: 0.55),
            gradientColors: [Color(red: 0.10, green: 0.15, blue: 0.40), Color(red: 0.05, green: 0.08, blue: 0.25)]
        ),
        "capital-one-venture": MockCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!,
            name: "Venture Rewards",
            issuer: "Capital One",
            lastFour: "9204",
            balance: 1840.50,
            networkMark: "VISA",
            accentColor: Color.red,
            gradientColors: [Color(red: 0.30, green: 0.08, blue: 0.08), Color(red: 0.18, green: 0.04, blue: 0.04)]
        ),
        "capital-one-savor": MockCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000000A")!,
            name: "Savor Cash Rewards",
            issuer: "Capital One",
            lastFour: "8341",
            balance: 675.20,
            networkMark: "MC",
            accentColor: Color.orange,
            gradientColors: [Color(red: 0.28, green: 0.15, blue: 0.05), Color(red: 0.18, green: 0.08, blue: 0.02)]
        ),
    ]

    static func forCatalogIDs(_ ids: [String]) -> [MockCard] {
        ids.compactMap { catalogCards[$0] }
    }

    static let samples: [MockCard] = [
        MockCard(
            id: UUID(),
            name: "Rewards Plus",
            issuer: "Summit Bank",
            lastFour: "4821",
            balance: 2347.89,
            networkMark: "VISA",
            accentColor: Color.teal,
            gradientColors: [Color(red: 0.05, green: 0.30, blue: 0.35), Color(red: 0.02, green: 0.18, blue: 0.22)]
        ),
        MockCard(
            id: UUID(),
            name: "Cash Back",
            issuer: "Harbor Financial",
            lastFour: "7153",
            balance: 891.42,
            networkMark: "MC",
            accentColor: Color.indigo,
            gradientColors: [Color(red: 0.20, green: 0.15, blue: 0.45), Color(red: 0.10, green: 0.08, blue: 0.28)]
        ),
        MockCard(
            id: UUID(),
            name: "Travel Elite",
            issuer: "Crest Union",
            lastFour: "3390",
            balance: 5120.00,
            networkMark: "AMEX",
            accentColor: Color.orange,
            gradientColors: [Color(red: 0.28, green: 0.25, blue: 0.22), Color(red: 0.15, green: 0.14, blue: 0.12)]
        ),
        MockCard(
            id: UUID(),
            name: "Platinum Edge",
            issuer: "Apex Credit",
            lastFour: "9204",
            balance: 3415.60,
            networkMark: "VISA",
            accentColor: Color.purple,
            gradientColors: [Color(red: 0.30, green: 0.10, blue: 0.35), Color(red: 0.18, green: 0.05, blue: 0.22)]
        ),
        MockCard(
            id: UUID(),
            name: "Everyday Card",
            issuer: "Pine Street Bank",
            lastFour: "6617",
            balance: 420.15,
            networkMark: "MC",
            accentColor: Color.green,
            gradientColors: [Color(red: 0.08, green: 0.32, blue: 0.18), Color(red: 0.04, green: 0.20, blue: 0.10)]
        ),
        MockCard(
            id: UUID(),
            name: "Student Rewards",
            issuer: "Nova Financial",
            lastFour: "1088",
            balance: 156.30,
            networkMark: "VISA",
            accentColor: Color.cyan,
            gradientColors: [Color(red: 0.05, green: 0.25, blue: 0.40), Color(red: 0.02, green: 0.15, blue: 0.25)]
        ),
        MockCard(
            id: UUID(),
            name: "Business Pro",
            issuer: "Meridian Bank",
            lastFour: "5432",
            balance: 8750.00,
            networkMark: "AMEX",
            accentColor: Color.red,
            gradientColors: [Color(red: 0.35, green: 0.08, blue: 0.08), Color(red: 0.22, green: 0.04, blue: 0.04)]
        ),
    ]
}

struct CreditCardVisual: View {
    let card: MockCard

    private let aspectRatio: CGFloat = 85.6 / 53.98

    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: card.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Accent shine overlay
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(card.accentColor.opacity(0.4), lineWidth: 1)

            // Card content
            VStack(alignment: .leading, spacing: 0) {
                // Top row: name + issuer
                Text(card.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(card.issuer)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                // Card number
                Text("•••• \(card.lastFour)")
                    .font(.title3.weight(.medium).monospaced())
                    .foregroundStyle(.white.opacity(0.9))
                    .tracking(2)

                Spacer()

                // Bottom row: network mark
                HStack {
                    Spacer()
                    Text(card.networkMark)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(16)
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.name), \(card.issuer), ending in \(card.lastFour), balance \(card.balance.formatted(.currency(code: "USD")))")
    }
}

#Preview {
    CreditCardVisual(card: MockCard.samples[0])
        .frame(width: 300)
        .padding()
        .background(Color.black)
}
