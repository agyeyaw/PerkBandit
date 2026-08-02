//
//  BenefitsPageView.swift
//  PerkBandit
//

import SwiftUI

// MARK: - Models

enum BenefitStatus: String, CaseIterable {
    case available = "Available"
    case used = "Used"
    case expiring = "Expiring"
}

struct MockBenefit: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let frequency: String
    let status: BenefitStatus
    let detailText: String?
    let amountRemaining: Double?
}

// MARK: - View

struct BenefitsPageView: View {
    @State private var selectedFilter: String = "All"
    private let filters = ["All", "Available", "Used", "Expiring"]

    private let benefits: [MockBenefit] = [
        MockBenefit(title: "Streaming Credit", icon: "play.tv", frequency: "Monthly", status: .available, detailText: "$15 remaining", amountRemaining: 15),
        MockBenefit(title: "Dining Credit", icon: "fork.knife", frequency: "Monthly", status: .available, detailText: "$25 remaining", amountRemaining: 25),
        MockBenefit(title: "Travel Credit", icon: "airplane", frequency: "Annual", status: .used, detailText: nil, amountRemaining: 0),
        MockBenefit(title: "TSA PreCheck", icon: "person.badge.shield.checkmark", frequency: "Every 4 years", status: .used, detailText: nil, amountRemaining: 0),
        MockBenefit(title: "Uber Cash", icon: "car.fill", frequency: "Monthly", status: .expiring, detailText: "Exp. in 5 days", amountRemaining: 15),
        MockBenefit(title: "Hotel Credit", icon: "building.2", frequency: "Annual", status: .available, detailText: "$40 remaining", amountRemaining: 40),
    ]

    private var filteredBenefits: [MockBenefit] {
        if selectedFilter == "All" { return benefits }
        return benefits.filter { $0.status.rawValue == selectedFilter }
    }

    var body: some View {
        PBSubPageContainer(title: "Benefits") {
            VStack(spacing: 0) {
                // Filter pills
                filterBar
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredBenefits) { benefit in
                            benefitRow(benefit)
                        }
                    }
                    .padding(.horizontal)

                    Text("Last confirmed by you 8 days ago")
                        .font(.caption)
                        .foregroundStyle(PBTheme.subtitleGray)
                        .padding(.top, 20)
                        .padding(.bottom, 12)
                }

                PBBottomButton(title: "Update Status")
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(filters, id: \.self) { filter in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedFilter = filter
                    }
                } label: {
                    Text(filter)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            Capsule().fill(selectedFilter == filter ? PBTheme.accent : PBTheme.cardBackground)
                        )
                        .foregroundStyle(selectedFilter == filter ? .white : PBTheme.subtitleGray)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Benefit Row

    private func benefitRow(_ benefit: MockBenefit) -> some View {
        HStack(spacing: 14) {
            // Icon
            Circle()
                .fill(PBTheme.accent.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: benefit.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(PBTheme.accent)
                )

            // Title + frequency
            VStack(alignment: .leading, spacing: 3) {
                Text(benefit.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(benefit.frequency)
                    .font(.caption)
                    .foregroundStyle(PBTheme.subtitleGray)
            }

            Spacer()

            // Status + detail
            VStack(alignment: .trailing, spacing: 4) {
                statusPill(benefit.status)
                if let detail = benefit.detailText {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(PBTheme.subtitleGray)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(PBTheme.cardBackground)
        )
    }

    private func statusPill(_ status: BenefitStatus) -> some View {
        let color: Color = {
            switch status {
            case .available: return PBTheme.positive
            case .used: return PBTheme.subtitleGray
            case .expiring: return PBTheme.negative
            }
        }()

        return Text(status.rawValue)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(color.opacity(0.2)))
            .foregroundStyle(color)
    }
}

#Preview {
    NavigationStack {
        BenefitsPageView()
    }
}
