//
//  ManualExplanationStepView.swift
//  PerkBandit
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct ManualExplanationStepView: View {
    let onContinueManually: () -> Void
    let onConnectAccount: () -> Void
    let onExploreSample: () -> Void

    private let availableNow = [
        "Best-card recommendations",
        "Benefit calendar",
        "Expiration reminders",
        "Welcome-bonus tracking",
        "Estimated value generated",
    ]

    private let automatedAfterSyncing = [
        "Transaction imports",
        "Benefit-use detection",
        "Updated balances",
        "Automatic bonus progress",
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You're ready to start manually")
                            .font(.system(size: 24, weight: .bold))
                        Text("PerkBandit works without connecting a bank. You can sync accounts later to automate balances, transactions, and benefit tracking.")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    // Available now section
                    VStack(spacing: 0) {
                        SectionHeader(icon: "checkmark.circle.fill", title: "Available now", color: .green)

                        ForEach(availableNow, id: \.self) { feature in
                            FeatureRow(label: feature)
                            if feature != availableNow.last {
                                Divider().padding(.leading, 52)
                            }
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 1))

                    // Automated after syncing section
                    VStack(spacing: 0) {
                        SectionHeader(icon: "arrow.triangle.2.circlepath", title: "Automated after syncing", color: .secondary)

                        ForEach(automatedAfterSyncing, id: \.self) { feature in
                            FeatureRow(label: feature)
                            if feature != automatedAfterSyncing.last {
                                Divider().padding(.leading, 52)
                            }
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 1))
                }
                .padding(.horizontal, 20)
            }

            VStack(spacing: 12) {
                Button(action: onContinueManually) {
                    Text("Continue Manually")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(navyColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button(action: onConnectAccount) {
                    Text("Connect an Account")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }

                Button(action: onExploreSample) {
                    Text("Explore with sample cards")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 12)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

private struct SectionHeader: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 28)
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
    }
}

private struct FeatureRow: View {
    let label: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "circle.fill")
                .font(.system(size: 5))
                .foregroundColor(.secondary)
                .frame(width: 28)
            Text(label)
                .font(.system(size: 15))
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
    }
}
