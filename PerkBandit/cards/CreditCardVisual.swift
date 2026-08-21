//
//  CreditCardVisual.swift
//  PerkBandit
//

import SwiftUI

struct CreditCardVisual: View {
    let card: CreditCard

    private let aspectRatio: CGFloat = 85.6 / 53.98

    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [card.gradientStart.color, card.gradientEnd.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Accent shine overlay
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(card.accentColor.color.opacity(0.4), lineWidth: 1)

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
                    Text(card.network)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(16)
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.name), \(card.issuer), ending in \(card.lastFour)")
    }
}

#Preview {
    CreditCardVisual(card: embeddedCardCatalog[0])
        .frame(width: 300)
        .padding()
        .background(Color.black)
}
