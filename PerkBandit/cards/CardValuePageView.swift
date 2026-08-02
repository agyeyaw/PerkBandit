//
//  CardValuePageView.swift
//  PerkBandit
//

import SwiftUI

// MARK: - Models

private struct MockCardValue {
    let estimatedRewards: Double = 336.00
    let creditsUsed: Double = 120.00
    let annualFee: Double = 95.00
    let otherFees: Double = 76.50
    var netValue: Double { estimatedRewards + creditsUsed - annualFee - otherFees }
}

private enum ValueTimeRange: String, CaseIterable {
    case thisMonth = "This Month"
    case thisYear = "This Year"
    case allTime = "All Time"
}

// MARK: - View

struct CardValuePageView: View {
    @State private var selectedRange: ValueTimeRange = .thisYear
    private let value = MockCardValue()

    var body: some View {
        PBSubPageContainer(title: "Card Value") {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Period picker
                        periodPicker
                            .padding(.top, 8)

                        // Net value hero
                        netValueSection

                        // Breakdown
                        breakdownSection
                    }
                    .padding(.bottom, 16)
                }

                PBBottomButton(title: "View Details")
            }
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        HStack {
            Spacer()
            Menu {
                ForEach(ValueTimeRange.allCases, id: \.self) { range in
                    Button(range.rawValue) {
                        selectedRange = range
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedRange.rawValue)
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.semibold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().fill(PBTheme.cardBackground))
                .foregroundStyle(.white)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Net Value

    private var netValueSection: some View {
        PBSectionCard {
            VStack(spacing: 6) {
                Text("Estimated Net Value")
                    .font(.caption)
                    .foregroundStyle(PBTheme.subtitleGray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("+$\(String(format: "%.2f", value.netValue))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(PBTheme.positive)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Breakdown

    private var breakdownSection: some View {
        PBSectionCard {
            VStack(spacing: 0) {
                valueRow(label: "Estimated Rewards", amount: value.estimatedRewards, isPositive: true)
                rowDivider
                valueRow(label: "Credits You Marked Used", amount: value.creditsUsed, isPositive: true)
                rowDivider
                valueRow(label: "Annual Fee", amount: value.annualFee, isPositive: false)
                rowDivider
                valueRow(label: "Other Fees", amount: value.otherFees, isPositive: false)
            }
        }
    }

    private func valueRow(label: String, amount: Double, isPositive: Bool) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(PBTheme.subtitleGray)
            Spacer()
            Text("\(isPositive ? "+" : "-")$\(String(format: "%.2f", amount))")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isPositive ? PBTheme.positive : PBTheme.negative)
        }
        .padding(.vertical, 12)
    }

    private var rowDivider: some View {
        Divider().background(Color.white.opacity(0.1))
    }
}

#Preview {
    NavigationStack {
        CardValuePageView()
    }
}
