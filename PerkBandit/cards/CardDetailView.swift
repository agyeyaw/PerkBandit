//
//  CardDetailView.swift
//  PerkBandit
//

import SwiftUI

struct CardDetailView: View {
    let card: CreditCard
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
                Color(red: 202/255, green: 202/255, blue: 202/255)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Card container
                        CreditCardVisual(card: card)
                            .frame(width: 288)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.white.opacity(0.6))
                            )
                            .padding(.top, 8)

                        // Manually Tracked section
                        manuallyTrackedSection

                        // Action circles
                        HStack(spacing: 32) {
                            actionButton(icon: "star.fill", label: "Benefits")
                            actionButton(icon: "gift.fill", label: "Welcome Bonus")
                            actionButton(icon: "chart.bar.fill", label: "Value")
                        }

                        // Card details
                        cardDetailsSection

                        // Rewards section
                        rewardsSection

                        // Credits & Benefits section
                        if !card.statementCredits.isEmpty {
                            creditsSection
                        }

                        // Activation requirements
                        if let activation = card.activationRequired {
                            activationSection(activation)
                        }

                        // Exclusions
                        if !card.exclusions.isEmpty {
                            exclusionsSection
                        }

                        // Connect button
                        connectToAutomateButton

                        // View Official Terms
                        if let url = URL(string: card.sourceURL) {
                            Link(destination: url) {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc.text")
                                        .font(.subheadline)
                                    Text("View Official Terms")
                                        .font(.subheadline.weight(.medium))
                                }
                                .foregroundStyle(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                            }
                            .padding(.horizontal)
                        }

                        Spacer()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Card Details")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.black)
                }
            }
            .toolbar(.hidden, for: .tabBar)
    }

    private var manuallyTrackedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
                Text("Manually Tracked")
                    .font(.headline.weight(.semibold))
                Spacer()
                Button("Edit") {}
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.white.opacity(0.5)))
                    .foregroundStyle(.black)
            }

            Text("You're in control")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.6))
        )
        .padding(.horizontal)
    }

    private var cardDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            infoRow(label: "Annual Fee", value: card.annualFee)
            infoRow(label: "Network", value: card.network)

            HStack(alignment: .top) {
                Text("Verified")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(card.lastVerified)
                        .font(.subheadline)
                    Text("PerkBandit Catalog")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.6))
        )
        .padding(.horizontal)
    }

    private var rewardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rewards")
                .font(.headline.weight(.semibold))

            ForEach(card.rewardRules, id: \.self) { rule in
                HStack(alignment: .top) {
                    Text(rule.multiplier)
                        .font(.subheadline.weight(.bold))
                        .frame(width: 50, alignment: .leading)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(rule.category)
                            .font(.subheadline)
                        if let cap = rule.capDescription {
                            Text(cap)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.6))
        )
        .padding(.horizontal)
    }

    private var creditsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Credits & Benefits")
                .font(.headline.weight(.semibold))

            ForEach(card.statementCredits, id: \.self) { credit in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(credit.description)
                            .font(.subheadline.weight(.medium))
                        if let notes = credit.notes {
                            Text(notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Text(credit.amount)
                        .font(.subheadline.weight(.semibold))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.6))
        )
        .padding(.horizontal)
    }

    private func activationSection(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Activation Required")
                    .font(.subheadline.weight(.semibold))
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.6))
        )
        .padding(.horizontal)
    }

    private var exclusionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exclusions")
                .font(.subheadline.weight(.semibold))
            ForEach(card.exclusions, id: \.self) { exclusion in
                HStack(alignment: .top, spacing: 6) {
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(exclusion)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.6))
        )
        .padding(.horizontal)
    }

    private var connectToAutomateButton: some View {
        Button {} label: {
            Text("Connect to Automate")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Capsule().fill(.black))
                .foregroundStyle(.white)
        }
        .padding(.horizontal)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }

    private func actionButton(icon: String, label: String) -> some View {
        NavigationLink(value: label) {
            VStack(spacing: 8) {
                Circle()
                    .fill(.white.opacity(0.7))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundStyle(.black)
                    )

                Text(label)
                    .font(.caption)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 70)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CardDetailView(card: cardCatalog[0])
    }
}
