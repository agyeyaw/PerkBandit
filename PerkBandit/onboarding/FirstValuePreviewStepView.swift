//
//  FirstValuePreviewStepView.swift
//  PerkBandit
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct FirstValuePreviewStepView: View {
    let selectedCards: [String]
    let setupMethod: SetupMethod?
    let onAdvance: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PerkBandit found your first opportunities")
                            .font(.system(size: 24, weight: .bold))

                        Text(sourceLabel)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    OpportunityCard(
                        category: "Best for dining",
                        categoryColor: .orange,
                        icon: "fork.knife",
                        title: diningCardName,
                        subtitle: "Earns 4× points at restaurants"
                    )

                    OpportunityCard(
                        category: "Benefit to check",
                        categoryColor: .purple,
                        icon: "gift.fill",
                        title: "$10 Uber Cash",
                        subtitle: "May still be available this month."
                    )

                    OpportunityCard(
                        category: "Upcoming review",
                        categoryColor: .blue,
                        icon: "calendar.badge.clock",
                        title: "Annual fee in 42 days",
                        subtitle: "Review whether the card is still worth keeping."
                    )
                }
                .padding(.horizontal, 20)
            }

            Button(action: onAdvance) {
                Text("See My Home")
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
        .background(Color.white.ignoresSafeArea())
    }

    private var sourceLabel: String {
        if setupMethod == .manual {
            return "Based on your manually added cards"
        } else {
            return "Based on account data updated just now"
        }
    }

    private var diningCardName: String {
        if selectedCards.contains("amex-gold") {
            return "Amex Gold"
        } else if selectedCards.contains("capital-one-savor") {
            return "Capital One Savor"
        } else {
            return "Amex Gold"
        }
    }
}

private struct OpportunityCard: View {
    let category: String
    let categoryColor: Color
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(categoryColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(categoryColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color(.systemGray6)).frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(navyColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}
