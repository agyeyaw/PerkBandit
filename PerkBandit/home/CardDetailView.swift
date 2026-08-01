//
//  CardDetailView.swift
//  PerkBandit
//

import SwiftUI

struct CardDetailView: View {
    let card: MockCard
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

                        // Connect button
                        connectToAutomateButton

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
            infoRow(label: "Annual Fee", value: "$95")
            infoRow(label: "Renewal Date", value: "Apr 12, 2025")
            infoRow(label: "Benefits (6)", value: "3 available")
            infoRow(label: "Welcome Bonus", value: "$1,200 to go")
            infoRow(label: "Last Confirmed", value: "8 days ago")

            HStack(alignment: .top) {
                Text("Data Source")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("PerkBandit Catalog")
                        .font(.subheadline)
                    Text("Updated Apr 1, 2025")
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
        CardDetailView(card: MockCard.samples[0])
    }
}
