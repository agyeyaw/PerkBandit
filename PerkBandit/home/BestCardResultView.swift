//
//  BestCardResultView.swift
//  PerkBandit
//

import SwiftUI

struct BestCardResultView: View {
    let category: SpendingCategory
    @EnvironmentObject var cardStore: CardStore
    @State private var showAllCards = false

    private var matches: [OpportunityEngine.CardRewardMatch] {
        OpportunityEngine.bestCards(for: category, cards: cardStore.cards, preferences: cardStore.recommendationPrefs)
    }

    private var keepSimple: Bool {
        cardStore.recommendationPrefs.contains(.keepSimple)
    }

    private var hasBonusMatch: Bool {
        guard let top = matches.first else { return false }
        let lower = top.matchedRule.category.lowercased()
        return !lower.hasPrefix("everything")
    }

    var body: some View {
        ZStack {
            Color(red: 245/255, green: 246/255, blue: 250/255)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Category header
                    VStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .font(.largeTitle)
                            .foregroundStyle(PBTheme.accent)

                        Text(category.label)
                            .font(.title2.weight(.bold))
                    }
                    .padding(.top, 12)

                    if matches.isEmpty {
                        emptyState
                    } else {
                        heroCard
                        preferenceCallout
                        if !keepSimple {
                            runnerUp
                            whyThisCard
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(category.label)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        Group {
            if let top = matches.first {
                let cardDef = catalogCard(for: top.cardDefinitionID)

                VStack(alignment: .leading, spacing: 14) {
                    if hasBonusMatch {
                        Text("Best Card")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(PBTheme.accent)
                    } else {
                        Text("Best Fallback")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.orange)
                    }

                    HStack(spacing: 14) {
                        if let def = cardDef {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [def.gradientStart.color, def.gradientEnd.color],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 52)
                                .overlay(
                                    Text(def.network)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.8))
                                    , alignment: .bottomTrailing
                                )
                                .padding(.trailing, 2)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Use \(top.cardName)")
                                .font(.headline.weight(.bold))

                            Text(top.matchedRule.multiplier)
                                .font(.title.weight(.heavy))
                                .foregroundStyle(PBTheme.accent)
                        }
                    }

                    Text(top.explanation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let cap = top.matchedRule.capDescription {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text(cap)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemBackground))
                )
            }
        }
    }

    // MARK: - Preference Callout

    @ViewBuilder
    private var preferenceCallout: some View {
        if let note = matches.first?.preferenceNote {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.subheadline)
                    .foregroundStyle(.blue)

                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.blue.opacity(0.08))
            )
        }
    }

    // MARK: - Runner Up

    @ViewBuilder
    private var runnerUp: some View {
        if matches.count >= 2 {
            let second = matches[1]
            HStack(spacing: 10) {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Runner-up")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text("\(second.cardName) earns \(second.matchedRule.multiplier)")
                        .font(.subheadline.weight(.medium))
                }

                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
            )
        }
    }

    // MARK: - Why This Card

    private var whyThisCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showAllCards.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .font(.subheadline)
                    Text("Why this card?")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Image(systemName: showAllCards ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .foregroundStyle(.primary)
                .padding(14)
            }

            if showAllCards {
                Divider().padding(.leading, 14)

                VStack(spacing: 0) {
                    ForEach(Array(matches.enumerated()), id: \.element.id) { index, match in
                        HStack(spacing: 12) {
                            Text("#\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(index == 0 ? PBTheme.accent : .secondary)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(match.cardName)
                                    .font(.subheadline.weight(.medium))
                                Text(match.explanation)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(match.matchedRule.multiplier)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(index == 0 ? PBTheme.accent : .secondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)

                        if index < matches.count - 1 {
                            Divider().padding(.leading, 54)
                        }
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No cards to compare")
                .font(.headline)

            Text("Add your credit cards to see which one earns the best rewards for \(category.label.lowercased()).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }
}
