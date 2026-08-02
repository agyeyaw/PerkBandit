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
