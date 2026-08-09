//
//  CardDetailView.swift
//  PerkBandit
//

import SwiftUI

struct CardDetailView: View {
    let userCardID: String
    @EnvironmentObject var cardStore: CardStore
    @Environment(\.dismiss) private var dismiss

    private var userCard: UserCard? {
        cardStore.cards.first { $0.id == userCardID }
    }

    private var card: CreditCard? {
        userCard?.definition
    }

    var body: some View {
        ZStack {
            Color(red: 202/255, green: 202/255, blue: 202/255)
                .ignoresSafeArea()

            if let card = card, let userCard = userCard {
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

                        // Tracking section
                        trackingSection(userCard)

                        // Action circles
                        HStack(spacing: 32) {
                            actionButton(icon: "star.fill", label: "Benefits", card: card)
                            actionButton(icon: "gift.fill", label: "Welcome Bonus", card: card)
                            actionButton(icon: "chart.bar.fill", label: "Value", card: card)
                        }

                        // Card details
                        cardDetailsSection(card, userCard: userCard)

                        // Rewards section
                        rewardsSection(card)

                        // Benefits section with live status
                        if !card.statementCredits.isEmpty {
                            benefitsSummarySection(userCard, card: card)
                        }

                        // Welcome bonus summary
                        welcomeBonusSummarySection(userCard, card: card)

                        // Activation requirements
                        if let activation = card.activationRequired {
                            activationSection(activation)
                        }

                        // Exclusions
                        if !card.exclusions.isEmpty {
                            exclusionsSection(card)
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

    // MARK: - Tracking Section

    private func trackingSection(_ userCard: UserCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
                Text(userCard.trackingMode == .linked ? "Auto Tracked" : "Manually Tracked")
                    .font(.headline.weight(.semibold))
                Spacer()
                Button("Edit") {}
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.white.opacity(0.5)))
                    .foregroundStyle(.black)
            }

            Text("Added \(userCard.dateAdded.formatted(date: .abbreviated, time: .omitted))")
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

    // MARK: - Card Details

    private func cardDetailsSection(_ card: CreditCard, userCard: UserCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            infoRow(label: "Annual Fee", value: card.annualFee)
            infoRow(label: "Network", value: card.network)
            infoRow(label: "Tracking", value: userCard.trackingMode == .linked ? "Linked" : "Manual")

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

    // MARK: - Rewards

    private func rewardsSection(_ card: CreditCard) -> some View {
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

    // MARK: - Benefits Summary (inline editing)

    private func benefitsSummarySection(_ userCard: UserCard, card: CreditCard) -> some View {
        let paired: [(state: UserBenefitState, credit: StatementCredit)] = userCard.benefitStates.compactMap { state in
            guard let credit = card.statementCredits.first(where: { $0.description == state.id }) else { return nil }
            return (state, credit)
        }

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Credits & Benefits")
                    .font(.headline.weight(.semibold))
                Spacer()
                let unusedCount = paired.filter { $0.state.status != .used }.count
                if unusedCount > 0 {
                    Text("\(unusedCount) unused")
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.blue.opacity(0.12)))
                        .foregroundStyle(.blue)
                }
            }

            ForEach(paired, id: \.state.id) { pair in
                Button {
                    cardStore.toggleBenefitStatus(
                        userCardID: userCard.id,
                        benefitID: pair.state.id
                    )
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pair.credit.description)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                            Text("\(pair.credit.frequency.label) · \(pair.credit.amount)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        benefitStatusPill(pair.state)
                    }
                }
                .buttonStyle(.plain)

                if pair.state.id != paired.last?.state.id {
                    Divider()
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

    private func benefitStatusPill(_ state: UserBenefitState) -> some View {
        let (label, color): (String, Color) = {
            switch state.status {
            case .available: return ("Available", .green)
            case .used: return ("Used", .gray)
            case .notSure: return ("Not Sure", .orange)
            }
        }()

        return Text(label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(color.opacity(0.15)))
            .foregroundStyle(color)
    }

    // MARK: - Welcome Bonus Summary

    private func welcomeBonusSummarySection(_ userCard: UserCard, card: CreditCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome Bonus")
                .font(.headline.weight(.semibold))

            if let bonus = userCard.welcomeBonus, bonus.isTracking {
                let target = bonus.targetSpend ?? 0
                let current = bonus.currentSpend ?? 0
                let percent = target > 0 ? min(1.0, current / target) : 0
                let remaining = max(0, target - current)

                VStack(spacing: 10) {
                    // Progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.06))
                            .frame(height: 10)

                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .green],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * percent)
                        }
                        .frame(height: 10)
                    }

                    HStack {
                        Text("$\(Int(current).formatted()) / $\(Int(target).formatted())")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(Int(percent * 100))%")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                    }

                    if remaining > 0 {
                        Text("$\(Int(remaining).formatted()) remaining")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let desc = bonus.bonusDescription, !desc.isEmpty {
                        Text("Reward: \(desc)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NavigationLink(value: CardSubPageDestination(pageName: "Welcome Bonus", cardDefinitionID: card.id)) {
                        Text("Update Progress")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No bonus tracked")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    NavigationLink(value: CardSubPageDestination(pageName: "Welcome Bonus", cardDefinitionID: card.id)) {
                        Text("Start tracking →")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.blue)
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

    // MARK: - Activation

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

    // MARK: - Exclusions

    private func exclusionsSection(_ card: CreditCard) -> some View {
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

    // MARK: - Connect Button

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

    // MARK: - Helpers

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

    private func actionButton(icon: String, label: String, card: CreditCard) -> some View {
        NavigationLink(value: CardSubPageDestination(pageName: label, cardDefinitionID: card.id)) {
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
        CardDetailView(userCardID: "preview")
            .environmentObject(CardStore())
    }
}
