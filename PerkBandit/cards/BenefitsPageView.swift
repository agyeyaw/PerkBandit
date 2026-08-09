//
//  BenefitsPageView.swift
//  PerkBandit
//

import SwiftUI

// MARK: - View

struct BenefitsPageView: View {
    let cardDefinitionID: String
    @EnvironmentObject var cardStore: CardStore
    @State private var selectedFilter: String = "All"
    private let filters = ["All", "Available", "Used", "Expiring"]

    private var userCard: UserCard? {
        cardStore.cards.first { $0.cardDefinitionID == cardDefinitionID }
    }

    private var catalogCard: CreditCard? {
        PerkBandit.catalogCard(for: cardDefinitionID)
    }

    private var pairedBenefits: [(state: UserBenefitState, credit: StatementCredit)] {
        guard let uc = userCard, let def = catalogCard else { return [] }
        return uc.benefitStates.compactMap { state in
            guard let credit = def.statementCredits.first(where: { $0.description == state.id }) else { return nil }
            return (state, credit)
        }
    }

    private var filteredBenefits: [(state: UserBenefitState, credit: StatementCredit)] {
        switch selectedFilter {
        case "Available": return pairedBenefits.filter { $0.state.status == .available }
        case "Used": return pairedBenefits.filter { $0.state.status == .used }
        case "Expiring": return pairedBenefits.filter { $0.state.isExpiringSoon }
        default: return pairedBenefits
        }
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
                        ForEach(filteredBenefits, id: \.state.id) { pair in
                            benefitRow(pair.state, pair.credit)
                                .onTapGesture {
                                    if let uc = userCard {
                                        cardStore.toggleBenefitStatus(
                                            userCardID: uc.id,
                                            benefitID: pair.state.id
                                        )
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)

                    if pairedBenefits.isEmpty {
                        Text("No benefits for this card")
                            .font(.subheadline)
                            .foregroundStyle(PBTheme.subtitleGray)
                            .padding(.top, 40)
                    }
                }
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

    private func benefitRow(_ state: UserBenefitState, _ credit: StatementCredit) -> some View {
        HStack(spacing: 14) {
            // Icon
            Circle()
                .fill(PBTheme.accent.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: iconForBenefit(credit.description))
                        .font(.system(size: 18))
                        .foregroundStyle(PBTheme.accent)
                )

            // Title + frequency
            VStack(alignment: .leading, spacing: 3) {
                Text(credit.description)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("\(credit.frequency.label) · $\(Int(credit.perPeriodAmount))")
                    .font(.caption)
                    .foregroundStyle(PBTheme.subtitleGray)
            }

            Spacer()

            // Status + detail
            VStack(alignment: .trailing, spacing: 4) {
                statusPill(state)
                if state.isExpiringSoon, let text = state.expiryText {
                    Text(text)
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

    private func statusPill(_ state: UserBenefitState) -> some View {
        let (label, color): (String, Color) = {
            if state.isExpiringSoon { return ("Expiring", PBTheme.negative) }
            switch state.status {
            case .available: return ("Available", PBTheme.positive)
            case .used: return ("Used", PBTheme.subtitleGray)
            case .notSure: return ("Not Sure", .orange)
            }
        }()

        return Text(label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(color.opacity(0.2)))
            .foregroundStyle(color)
    }

    private func iconForBenefit(_ description: String) -> String {
        let lower = description.lowercased()
        if lower.contains("uber") { return "car.fill" }
        if lower.contains("dining") { return "fork.knife" }
        if lower.contains("travel") { return "airplane" }
        if lower.contains("hotel") { return "building.2" }
        if lower.contains("streaming") || lower.contains("entertainment") || lower.contains("digital") { return "play.tv" }
        if lower.contains("saks") { return "bag.fill" }
        if lower.contains("airline") { return "airplane.departure" }
        return "creditcard.fill"
    }
}

#Preview {
    NavigationStack {
        BenefitsPageView(cardDefinitionID: "amex-platinum")
            .environmentObject(CardStore())
    }
}
