//
//  WelcomeBonusPageView.swift
//  PerkBandit
//

import SwiftUI

// MARK: - Model

private struct MockWelcomeBonus {
    let targetSpend: Double = 4000
    let currentSpend: Double = 2800
    let deadlineDate: Date = Calendar.current.date(byAdding: .day, value: 52, to: Date()) ?? Date()
    let manuallyTracked: Bool = true
    let tips: [String] = [
        "Pay bills with this card (utilities, subscriptions)",
        "Use for everyday purchases like groceries and gas",
        "Consider prepaying upcoming expenses"
    ]

    var percentComplete: Double { currentSpend / targetSpend }
    var amountRemaining: Double { targetSpend - currentSpend }

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: deadlineDate).day ?? 0
    }

    var monthsRemaining: Double {
        Double(daysRemaining) / 30.0
    }

    var monthlyPace: Double {
        guard monthsRemaining > 0 else { return amountRemaining }
        return amountRemaining / monthsRemaining
    }

    var isOnTrack: Bool { monthlyPace <= 800 }
}

// MARK: - View

struct WelcomeBonusPageView: View {
    private let bonus = MockWelcomeBonus()

    var body: some View {
        PBSubPageContainer(title: "Welcome Bonus") {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Spend target header
                        spendTargetSection
                            .padding(.top, 8)

                        // Progress section
                        progressSection

                        // Timeline info
                        timelineSection

                        // Monthly pace
                        paceSection

                        // Tips
                        tipsSection
                    }
                    .padding(.bottom, 16)
                }

                PBBottomButton(title: "Update Progress")
            }
        }
    }

    // MARK: - Spend Target

    private var spendTargetSection: some View {
        PBSectionCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spend $\(Int(bonus.targetSpend).formatted()) in 3 months")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("to earn your welcome bonus")
                        .font(.caption)
                        .foregroundStyle(PBTheme.subtitleGray)
                }
                Spacer()
                if bonus.manuallyTracked {
                    Text("Manually Tracked")
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(PBTheme.accent.opacity(0.2)))
                        .foregroundStyle(PBTheme.accent)
                }
            }
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        PBSectionCard {
            VStack(spacing: 14) {
                // Amount text
                HStack(alignment: .firstTextBaseline) {
                    Text("$\(Int(bonus.currentSpend).formatted())")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("/ $\(Int(bonus.targetSpend).formatted())")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(PBTheme.subtitleGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Progress bar
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
                            .frame(width: geo.size.width * bonus.percentComplete)
                    }
                    .frame(height: 12)
                }

                HStack {
                    Spacer()
                    Text("\(Int(bonus.percentComplete * 100))%")
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
                    Text("\(bonus.daysRemaining) days")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Divider().background(Color.white.opacity(0.1))

                HStack {
                    Label("Deadline", systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(PBTheme.subtitleGray)
                    Spacer()
                    Text(bonus.deadlineDate, style: .date)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
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

                Text("$\(Int(bonus.monthlyPace)) / month")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                HStack(spacing: 6) {
                    Image(systemName: bonus.isOnTrack ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(bonus.isOnTrack ? PBTheme.positive : PBTheme.negative)
                    Text(bonus.isOnTrack ? "You're on track!" : "You may need to increase spending")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(bonus.isOnTrack ? PBTheme.positive : PBTheme.negative)
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

                ForEach(bonus.tips, id: \.self) { tip in
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

#Preview {
    NavigationStack {
        WelcomeBonusPageView()
    }
}
