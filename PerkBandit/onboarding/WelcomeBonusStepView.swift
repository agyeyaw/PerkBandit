//
//  WelcomeBonusStepView.swift
//  PerkBandit
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct WelcomeBonusStepView: View {
    @Binding var selectedCards: [String]
    @Binding var cardBonusStatuses: [String: String]
    @Binding var cardBonusDetails: [String: WelcomeBonusDetail]
    let onAdvance: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Are you working toward a welcome bonus?")
                            .font(.system(size: 24, weight: .bold))
                        Text("Scout can help you hit your spending targets on time.")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    ForEach(selectedCards, id: \.self) { cardId in
                        if let card = cardCatalog.first(where: { $0.id == cardId }) {
                            BonusCardSection(
                                card: card,
                                status: Binding(
                                    get: { cardBonusStatuses[cardId] ?? "" },
                                    set: { cardBonusStatuses[cardId] = $0 }
                                ),
                                detail: Binding(
                                    get: { cardBonusDetails[cardId] ?? WelcomeBonusDetail() },
                                    set: { cardBonusDetails[cardId] = $0 }
                                )
                            )
                        }
                    }

                    Text("Scout will calculate how much you need to spend each month to stay on track.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 20)
            }

            Button(action: onAdvance) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(navyColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 12)
        }
    }
}

// MARK: - Per-Card Section

private struct BonusCardSection: View {
    let card: CreditCard
    @Binding var status: String
    @Binding var detail: WelcomeBonusDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card header
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(navyColor)
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
            }

            // Three option buttons
            HStack(spacing: 8) {
                BonusOptionButton(label: "Yes", isSelected: status == "yes") {
                    status = "yes"
                }
                BonusOptionButton(label: "Not right now", isSelected: status == "notNow") {
                    status = "notNow"
                }
                BonusOptionButton(label: "I'm not sure", isSelected: status == "notSure") {
                    status = "notSure"
                }
            }

            // Expanded detail form when "Yes"
            if status == "yes" {
                VStack(spacing: 12) {
                    BonusField(label: "Spending requirement", placeholder: "$4,000", text: $detail.spendingRequirement)
                    BonusField(label: "Amount spent so far", placeholder: "$2,800", text: $detail.amountSpent)
                    BonusField(label: "Deadline", placeholder: "September 30", text: $detail.deadline)
                    BonusField(label: "Bonus reward", placeholder: "60,000 points", text: $detail.bonusReward)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 1))
    }
}

private struct BonusOptionButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? navyColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

private struct BonusField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray4), lineWidth: 1))
        }
    }
}
