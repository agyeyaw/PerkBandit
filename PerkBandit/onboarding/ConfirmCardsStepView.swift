//
//  ConfirmCardsStepView.swift
//  PerkBandit
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct ConfirmCardsStepView: View {
    @Binding var selectedCards: [String]
    let onAdvance: () -> Void
    let onAddMore: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Does everything look right?")
                            .font(.system(size: 28, weight: .bold))

                        Text("PerkBandit will use these cards to find rewards, benefits, and the best card for each purchase.")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    // Card list
                    VStack(spacing: 0) {
                        ForEach(selectedCards, id: \.self) { cardId in
                            if let card = catalogCard(for: cardId) {
                                ConfirmCardRow(
                                    card: card,
                                    onRemove: {
                                        withAnimation {
                                            selectedCards.removeAll { $0 == cardId }
                                        }
                                    }
                                )

                                if cardId != selectedCards.last {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.systemGray6))
                    )

                    // Add another card button
                    Button(action: onAddMore) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            Text("Add another card")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(navyColor)
                    }
                }
                .padding(.horizontal, 20)
            }

            // Continue button
            Button(action: onAdvance) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(selectedCards.isEmpty ? Color.gray : navyColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selectedCards.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 12)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Card Row

private struct ConfirmCardRow: View {
    let card: CreditCard
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Card icon
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 24/255, green: 32/255, blue: 51/255))
                .frame(width: 40, height: 28)
                .overlay(
                    Text(String(card.issuer.prefix(2)).uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(card.name)
                    .font(.system(size: 16, weight: .medium))
                Text(card.issuer)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.gray.opacity(0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
