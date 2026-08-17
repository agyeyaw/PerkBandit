//
//  CardDetailView.swift
//  PerkBandit

import SwiftUI

struct CardDetailView: View {
    let userCardID: String
    @EnvironmentObject var cardStore: CardStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var selectedTab: Int = 0
    @State private var selectedBenefitFilter: String = "All"
    @State private var showUpdateSheet = false
    @State private var showSetupSheet = false
    @State private var selectedValueRange: String = "This Year"

    private let tabs = ["Card Details", "Benefits", "Welcome Bonuses", "Value"]
    private let benefitFilters = ["All", "Available", "Used", "Expiring"]
    private let valueRanges = ["This Month", "This Year", "All Time"]

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
                VStack(spacing: 0) {
                    tabBar
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    ScrollView {
                        VStack(spacing: 16) {
                            // Card visual (always visible)
                            CreditCardVisual(card: card)
                                .padding(.horizontal)

                        // Tracking status
                        trackingSection(userCard)

                        // Tab content
                        switch selectedTab {
                        case 0:
                            cardDetailsTabContent(card, userCard: userCard)
                        case 1:
                            benefitsTabContent(card, userCard: userCard)
                        case 2:
                            welcomeBonusTabContent(card, userCard: userCard)
                        case 3:
                            valueTabContent()
                        default:
                            EmptyView()
                        }

                        Spacer()
                    }
                }
                }
            }
        }
        .alert("Remove Card?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                cardStore.removeCard(userCardID: userCardID)
                dismiss()
            }
        } message: {
            Text("This card and its tracked benefits will be removed.")
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
                Text(tabs[selectedTab])
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.black)
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, title in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    Text(title)
                        .font(.caption.weight(selectedTab == index ? .bold : .medium))
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedTab == index
                                ? Capsule().fill(PBTheme.accent)
                                : Capsule().fill(Color.clear)
                        )
                        .foregroundStyle(selectedTab == index ? .white : .gray)
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.white.opacity(0.6))
        )
        .padding(.horizontal)
    }

    // MARK: - Tracking Section

    private func trackingSection(_ userCard: UserCard) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(userCard.trackingMode == .linked ? "Synced Automatically" : "Manually Tracked")
                    .font(.subheadline.weight(.semibold))
                Text("Added \(userCard.dateAdded.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Edit") {}
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Capsule().fill(.white.opacity(0.5)))
                .foregroundStyle(.black)
        }
        .padding()
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 20,
                topTrailingRadius: 20,
                style: .continuous
            )
            .fill(.white.opacity(0.6))
        )
        .padding(.trailing)
    }

    // MARK: - Tab 0: Card Details

    private func cardDetailsTabContent(_ card: CreditCard, userCard: UserCard) -> some View {
        VStack(spacing: 16) {
            // Card details
            cardDetailsSection(card, userCard: userCard)

            // Rewards section
            rewardsSection(card)

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

            // Remove Card
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                    Text("Remove Card")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Tab 1: Benefits

    private func benefitsTabContent(_ card: CreditCard, userCard: UserCard) -> some View {
        let paired: [(state: UserBenefitState, credit: StatementCredit)] = userCard.benefitStates.compactMap { state in
            guard let credit = card.statementCredits.first(where: { $0.description == state.id }) else { return nil }
            return (state, credit)
        }

        let filtered: [(state: UserBenefitState, credit: StatementCredit)] = {
            switch selectedBenefitFilter {
            case "Available": return paired.filter { $0.state.status == .available }
            case "Used": return paired.filter { $0.state.status == .used }
            case "Expiring": return paired.filter { $0.state.isExpiringSoon }
            default: return paired
            }
        }()

        return VStack(spacing: 12) {
            // Filter pills
            HStack(spacing: 8) {
                ForEach(benefitFilters, id: \.self) { filter in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedBenefitFilter = filter
                        }
                    } label: {
                        Text(filter)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule().fill(selectedBenefitFilter == filter ? PBTheme.accent : .white.opacity(0.6))
                            )
                            .foregroundStyle(selectedBenefitFilter == filter ? .white : .gray)
                    }
                }
            }

            if filtered.isEmpty {
                Text(paired.isEmpty ? "No benefits for this card" : "No benefits match this filter")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 40)
            } else {
                ForEach(filtered, id: \.state.id) { pair in
                    benefitRowLight(pair.state, pair.credit, userCard: userCard)
                }
            }
        }
        .padding(.horizontal)
    }

    private func benefitRowLight(_ state: UserBenefitState, _ credit: StatementCredit, userCard: UserCard) -> some View {
        Button {
            cardStore.toggleBenefitStatus(
                userCardID: userCard.id,
                benefitID: state.id
            )
        } label: {
            HStack(spacing: 14) {
                Circle()
                    .fill(PBTheme.accent.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: iconForBenefit(credit.description))
                            .font(.system(size: 18))
                            .foregroundStyle(PBTheme.accent)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(credit.description)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.black)
                    Text("\(credit.frequency.label) · \(credit.amount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    benefitStatusPill(state)
                    if state.isExpiringSoon, let text = state.expiryText {
                        Text(text)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white.opacity(0.6))
            )
        }
        .buttonStyle(.plain)
    }

    private func benefitStatusPill(_ state: UserBenefitState) -> some View {
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

    // MARK: - Tab 2: Welcome Bonuses

    private func welcomeBonusTabContent(_ card: CreditCard, userCard: UserCard) -> some View {
        let bonus = userCard.welcomeBonus
        let isTracking = bonus?.isTracking == true
        let targetSpend = bonus?.targetSpend ?? 0
        let currentSpend = bonus?.currentSpend ?? 0
        let percentComplete = targetSpend > 0 ? min(1.0, currentSpend / targetSpend) : 0
        let amountRemaining = max(0, targetSpend - currentSpend)
        let daysRemaining: Int? = {
            guard let deadline = bonus?.deadline else { return nil }
            return Calendar.current.dateComponents([.day], from: Date(), to: deadline).day
        }()
        let monthsRemaining: Double? = {
            guard let days = daysRemaining else { return nil }
            return Double(days) / 30.0
        }()
        let monthlyPace: Double? = {
            guard let months = monthsRemaining, months > 0 else { return nil }
            return amountRemaining / months
        }()
        let isOnTrack: Bool = {
            guard let pace = monthlyPace else { return true }
            return pace <= targetSpend * 0.4
        }()

        return VStack(spacing: 16) {
            if isTracking {
                // Spend target
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            if let desc = bonus?.bonusDescription, !desc.isEmpty {
                                Text("Spend $\(Int(targetSpend).formatted()) to earn \(desc)")
                                    .font(.subheadline.weight(.semibold))
                            } else {
                                Text("Spend $\(Int(targetSpend).formatted())")
                                    .font(.subheadline.weight(.semibold))
                            }
                            Text("to earn your welcome bonus")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white.opacity(0.6))
                )
                .padding(.horizontal)

                // Progress
                VStack(spacing: 14) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("$\(Int(currentSpend).formatted())")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Text("/ $\(Int(targetSpend).formatted())")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.06))
                            .frame(height: 12)

                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [PBTheme.accent, PBTheme.positive],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * percentComplete)
                        }
                        .frame(height: 12)
                    }

                    HStack {
                        Spacer()
                        Text("\(Int(percentComplete * 100))%")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(PBTheme.positive)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white.opacity(0.6))
                )
                .padding(.horizontal)

                // Timeline
                VStack(spacing: 12) {
                    HStack {
                        Label("Time Remaining", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if let days = daysRemaining {
                            Text("\(days) days")
                                .font(.subheadline.weight(.semibold))
                        } else {
                            Text("No deadline set")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    HStack {
                        Label("Deadline", systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if let deadline = bonus?.deadline {
                            Text(deadline, style: .date)
                                .font(.subheadline.weight(.semibold))
                        } else {
                            Text("—")
                                .font(.subheadline.weight(.semibold))
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

                // Pace
                if let pace = monthlyPace {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Required Monthly Pace")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("$\(Int(pace)) / month")
                            .font(.title2.weight(.bold))

                        HStack(spacing: 6) {
                            Image(systemName: isOnTrack ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundStyle(isOnTrack ? PBTheme.positive : PBTheme.negative)
                            Text(isOnTrack ? "You're on track!" : "You may need to increase spending")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(isOnTrack ? PBTheme.positive : PBTheme.negative)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white.opacity(0.6))
                    )
                    .padding(.horizontal)
                }

                // Tips
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tips to reach your goal")
                        .font(.subheadline.weight(.semibold))

                    ForEach([
                        "Pay bills with this card (utilities, subscriptions)",
                        "Use for everyday purchases like groceries and gas",
                        "Consider prepaying upcoming expenses"
                    ], id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundStyle(PBTheme.negative)
                                .padding(.top, 2)
                            Text(tip)
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

                // Update Progress button
                Button {
                    showUpdateSheet = true
                } label: {
                    Text("Update Progress")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(PBTheme.accent))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showUpdateSheet) {
                    UpdateSpendSheet(
                        currentSpend: currentSpend,
                        userCardID: userCard.id
                    )
                    .environmentObject(cardStore)
                }
            } else {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "star.circle")
                        .font(.system(size: 56))
                        .foregroundStyle(PBTheme.accent.opacity(0.5))

                    Text("No Welcome Bonus Tracked")
                        .font(.title3.weight(.bold))

                    Text("Start tracking your \(card.name) welcome bonus to stay on pace and earn your reward.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Button {
                        showSetupSheet = true
                    } label: {
                        Text("Start Tracking")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(PBTheme.accent))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showSetupSheet) {
                        StartTrackingSheet(
                            cardName: card.name,
                            userCardID: userCard.id
                        )
                        .environmentObject(cardStore)
                    }
                }
                .padding(.top, 40)
            }
        }
    }

    // MARK: - Tab 3: Value

    private func valueTabContent() -> some View {
        let value = MockCardValue()

        return VStack(spacing: 16) {
            // Period picker
            HStack {
                Spacer()
                Menu {
                    ForEach(valueRanges, id: \.self) { range in
                        Button(range) {
                            selectedValueRange = range
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedValueRange)
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.down")
                            .font(.caption2.weight(.semibold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(.white.opacity(0.6)))
                    .foregroundStyle(.black)
                }
            }
            .padding(.horizontal)

            // Net value
            VStack(spacing: 6) {
                Text("Estimated Net Value")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("+$\(String(format: "%.2f", value.netValue))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(PBTheme.positive)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white.opacity(0.6))
            )
            .padding(.horizontal)

            // Breakdown
            VStack(spacing: 0) {
                valueRow(label: "Estimated Rewards", amount: value.estimatedRewards, isPositive: true)
                Divider()
                valueRow(label: "Credits You Marked Used", amount: value.creditsUsed, isPositive: true)
                Divider()
                valueRow(label: "Annual Fee", amount: value.annualFee, isPositive: false)
                Divider()
                valueRow(label: "Other Fees", amount: value.otherFees, isPositive: false)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white.opacity(0.6))
            )
            .padding(.horizontal)
        }
    }

    private func valueRow(label: String, amount: Double, isPositive: Bool) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(isPositive ? "+" : "-")$\(String(format: "%.2f", amount))")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isPositive ? PBTheme.positive : PBTheme.negative)
        }
        .padding(.vertical, 12)
    }

    // MARK: - Card Details Section

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
}

// MARK: - Mock Card Value (shared with CardValuePageView)

private struct MockCardValue {
    let estimatedRewards: Double = 336.00
    let creditsUsed: Double = 120.00
    let annualFee: Double = 95.00
    let otherFees: Double = 76.50
    var netValue: Double { estimatedRewards + creditsUsed - annualFee - otherFees }
}

#Preview {
    NavigationStack {
        CardDetailView(userCardID: "preview")
            .environmentObject(CardStore())
    }
}
