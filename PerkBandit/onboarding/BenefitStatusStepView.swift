//
//  BenefitStatusStepView.swift
//  PerkBandit
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct BenefitStatusStepView: View {
    let setupMethod: SetupMethod?
    let selectedCards: [String]
    @Binding var benefitStatuses: [String: String]
    let onAdvance: () -> Void

    private var realBenefits: [String] {
        selectedCards.flatMap { cardId in
            catalogCard(for: cardId)?.statementCredits.map(\.description) ?? []
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if setupMethod == .connect {
                syncedUserView
            } else {
                manualUserView
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
            .padding(.bottom, 0)
            .padding(.top, 12)

            Button(action: onAdvance) {
                Text("Skip for now")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Synced User

    private var syncedUserView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Help Scout understand your benefits")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Scout will look for benefit usage automatically. You can confirm anything uncertain later.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Manual User

    private var manualUserView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Help Scout understand your benefits")
                            .font(.system(size: 24, weight: .bold))
                        Text("Mark anything you've already used this month or year.")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    if realBenefits.isEmpty {
                        Text("None of your selected cards have statement credits to track.")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(realBenefits, id: \.self) { benefit in
                                BenefitRow(
                                    benefit: benefit,
                                    status: Binding(
                                        get: { benefitStatuses[benefit] ?? "available" },
                                        set: { benefitStatuses[benefit] = $0 }
                                    )
                                )

                                if benefit != realBenefits.last {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.systemGray6))
                        )
                    }

                    Text("You can review the rest later.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Benefit Row

private struct BenefitRow: View {
    let benefit: String
    @Binding var status: String

    private let options = [
        ("Available", "available"),
        ("Already used", "used"),
        ("Not sure", "notSure"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(benefit)
                .font(.system(size: 16, weight: .medium))

            HStack(spacing: 6) {
                ForEach(options, id: \.1) { label, value in
                    Button {
                        status = value
                    } label: {
                        Text(label)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(status == value ? navyColor : Color.white)
                            .foregroundColor(status == value ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(status == value ? navyColor : Color(.systemGray4), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
