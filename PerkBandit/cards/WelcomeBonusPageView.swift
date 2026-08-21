//
//  WelcomeBonusPageView.swift
//  PerkBandit
//

import SwiftUI

// MARK: - View

struct WelcomeBonusPageView: View {
    let cardDefinitionID: String
    @EnvironmentObject var cardStore: CardStore

    @State private var showUpdateSheet = false
    @State private var showSetupSheet = false

    private var userCard: UserCard? {
        cardStore.cards.first { $0.cardDefinitionID == cardDefinitionID }
    }

    private var bonus: WelcomeBonus? {
        userCard?.welcomeBonus
    }

    private var cardName: String {
        catalogCard(for: cardDefinitionID)?.name ?? "Card"
    }

    // MARK: - Computed bonus metrics

    private var targetSpend: Double { bonus?.targetSpend ?? 0 }
    private var currentSpend: Double { bonus?.currentSpend ?? 0 }

    private var percentComplete: Double {
        guard targetSpend > 0 else { return 0 }
        return min(1.0, currentSpend / targetSpend)
    }

    private var amountRemaining: Double {
        max(0, targetSpend - currentSpend)
    }

    private var daysRemaining: Int? {
        guard let deadline = bonus?.deadline else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: deadline).day
    }

    private var monthsRemaining: Double? {
        guard let days = daysRemaining else { return nil }
        return Double(days) / 30.0
    }

    private var monthlyPace: Double? {
        guard let months = monthsRemaining, months > 0 else { return nil }
        return amountRemaining / months
    }

    private var isOnTrack: Bool {
        guard let pace = monthlyPace else { return true }
        // Consider on track if monthly pace is at most 40% of target (reasonable monthly budget)
        return pace <= targetSpend * 0.4
    }

    private let tips: [String] = [
        "Pay bills with this card (utilities, subscriptions)",
        "Use for everyday purchases like groceries and gas",
        "Consider prepaying upcoming expenses"
    ]

    var body: some View {
        PBSubPageContainer(title: "Welcome Bonus") {
            if let bonus = bonus, bonus.isTracking {
                trackingBody
            } else {
                emptyState
            }
        }
    }

    // MARK: - Tracking Body

    private var trackingBody: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    spendTargetSection
                        .padding(.top, 8)
                    progressSection
                    timelineSection
                    if monthlyPace != nil {
                        paceSection
                    }
                    tipsSection
                }
                .padding(.bottom, 16)
            }

            PBBottomButton(title: "Update Progress") {
                showUpdateSheet = true
            }
        }
        .sheet(isPresented: $showUpdateSheet) {
            UpdateSpendSheet(
                currentSpend: currentSpend,
                userCardID: userCard?.id ?? ""
            )
            .environmentObject(cardStore)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "star.circle")
                    .font(.system(size: 56))
                    .foregroundStyle(PBTheme.accent.opacity(0.5))

                Text("No Welcome Bonus Tracked")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                Text("Start tracking your \(cardName) welcome bonus to stay on pace and earn your reward.")
                    .font(.subheadline)
                    .foregroundStyle(PBTheme.subtitleGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()

            PBBottomButton(title: "Start Tracking") {
                showSetupSheet = true
            }
        }
        .sheet(isPresented: $showSetupSheet) {
            StartTrackingSheet(
                cardName: cardName,
                userCardID: userCard?.id ?? ""
            )
            .environmentObject(cardStore)
        }
    }

    // MARK: - Spend Target

    private var spendTargetSection: some View {
        PBSectionCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let desc = bonus?.bonusDescription, !desc.isEmpty {
                        Text("Spend $\(Int(targetSpend).formatted()) to earn \(desc)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    } else {
                        Text("Spend $\(Int(targetSpend).formatted())")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    Text("to earn your welcome bonus")
                        .font(.caption)
                        .foregroundStyle(PBTheme.subtitleGray)
                }
                Spacer()
                Text("Manually Tracked")
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(PBTheme.accent.opacity(0.2)))
                    .foregroundStyle(PBTheme.accent)
            }
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        PBSectionCard {
            VStack(spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text("$\(Int(currentSpend).formatted())")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("/ $\(Int(targetSpend).formatted())")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(PBTheme.subtitleGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
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
        }
    }

    // MARK: - Timeline

    private var timelineSection: some View {
        PBSectionCard {
            VStack(spacing: 12) {
                HStack {
                    Label("Time Remaining", systemImage: "clock")
                        .font(.subheadline)
                        .foregroundStyle(PBTheme.subtitleGray)
                    Spacer()
                    if let days = daysRemaining {
                        Text("\(days) days")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    } else {
                        Text("No deadline set")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(PBTheme.subtitleGray)
                    }
                }

                Divider().background(Color.white.opacity(0.1))

                HStack {
                    Label("Deadline", systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(PBTheme.subtitleGray)
                    Spacer()
                    if let deadline = bonus?.deadline {
                        Text(deadline, style: .date)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    } else {
                        Text("—")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(PBTheme.subtitleGray)
                    }
                }
            }
        }
    }

    // MARK: - Pace

    private var paceSection: some View {
        PBSectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Required Monthly Pace")
                    .font(.caption)
                    .foregroundStyle(PBTheme.subtitleGray)

                Text("$\(Int(monthlyPace ?? 0)) / month")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                HStack(spacing: 6) {
                    Image(systemName: isOnTrack ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(isOnTrack ? PBTheme.positive : PBTheme.negative)
                    Text(isOnTrack ? "You're on track!" : "You may need to increase spending")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(isOnTrack ? PBTheme.positive : PBTheme.negative)
                }
            }
        }
    }

    // MARK: - Tips

    private var tipsSection: some View {
        PBSectionCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Tips to reach your goal")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundStyle(PBTheme.negative)
                            .padding(.top, 2)
                        Text(tip)
                            .font(.caption)
                            .foregroundStyle(PBTheme.subtitleGray)
                    }
                }
            }
        }
    }
}

// MARK: - Update Spend Sheet

struct UpdateSpendSheet: View {
    let currentSpend: Double
    let userCardID: String
    @EnvironmentObject var cardStore: CardStore
    @Environment(\.dismiss) private var dismiss

    @State private var spendText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PBTheme.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("How much have you spent so far?")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.top, 24)

                    TextField("$0", text: $spendText)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                        .padding(.horizontal, 32)

                    Spacer()

                    Button {
                        let cleaned = spendText
                            .replacingOccurrences(of: "$", with: "")
                            .replacingOccurrences(of: ",", with: "")
                        if let value = Double(cleaned) {
                            cardStore.updateBonusSpend(userCardID: userCardID, currentSpend: value)
                        }
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(PBTheme.accent))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Update Spend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .onAppear {
            spendText = currentSpend > 0 ? "$\(Int(currentSpend).formatted())" : ""
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Start Tracking Sheet

struct StartTrackingSheet: View {
    let cardName: String
    let userCardID: String
    @EnvironmentObject var cardStore: CardStore
    @Environment(\.dismiss) private var dismiss

    @State private var targetText: String = ""
    @State private var spentText: String = ""
    @State private var deadlineDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    @State private var rewardText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PBTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Track your \(cardName) welcome bonus")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.top, 16)

                        fieldGroup(label: "Spending requirement", placeholder: "$4,000", text: $targetText)
                        fieldGroup(label: "Amount spent so far", placeholder: "$0", text: $spentText)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Deadline")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(PBTheme.subtitleGray)
                            DatePicker("", selection: $deadlineDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }

                        fieldGroup(label: "Bonus reward", placeholder: "60,000 points", text: $rewardText)

                        Spacer(minLength: 32)

                        Button {
                            let target = parseAmount(targetText)
                            let spent = parseAmount(spentText)
                            guard target > 0 else { return }
                            cardStore.startTrackingBonus(
                                userCardID: userCardID,
                                targetSpend: target,
                                currentSpend: spent,
                                deadline: deadlineDate,
                                bonusDescription: rewardText.isEmpty ? nil : rewardText
                            )
                            dismiss()
                        } label: {
                            Text("Start Tracking")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(PBTheme.accent))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Welcome Bonus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
    }

    private func fieldGroup(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(PBTheme.subtitleGray)
            TextField(placeholder, text: text)
                .font(.body)
                .foregroundStyle(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.08))
                )
                .keyboardType(.decimalPad)
        }
    }

    private func parseAmount(_ text: String) -> Double {
        Double(text
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")) ?? 0
    }
}

#Preview {
    NavigationStack {
        WelcomeBonusPageView(cardDefinitionID: "amex-gold")
            .environmentObject(CardStore(catalogService: CardCatalogService()))
    }
}
