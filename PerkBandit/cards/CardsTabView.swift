//
//  CardsTabView.swift
//  PerkBandit
//

import SwiftUI

struct CardSubPageDestination: Hashable {
    let pageName: String
    let cardDefinitionID: String
}

struct CardsTabView: View {
    @EnvironmentObject var cardStore: CardStore
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .topLeading) {
                Color(red: 202/255, green: 202/255, blue: 202/255)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Manage")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(.black)
                                Text("Your Cards")
                                    .font(.system(size: 37, weight: .light))
                                    .foregroundStyle(.gray)
                            }

                            Spacer()

                            VStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white, .black)
                                Text("Add Card")
                                    .font(.caption)
                                    .foregroundStyle(.black)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 20)

                        // Card list
                        LazyVStack(spacing: 12) {
                            ForEach(cardStore.cards) { userCard in
                                if let card = userCard.definition {
                                    Button {
                                        path.append(userCard.id)
                                    } label: {
                                        CardRowView(userCard: userCard, card: card)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.visible, for: .tabBar)
            .navigationDestination(for: String.self) { userCardID in
                CardDetailView(userCardID: userCardID)
            }
            .navigationDestination(for: CardSubPageDestination.self) { dest in
                switch dest.pageName {
                case "Benefits": BenefitsPageView(cardDefinitionID: dest.cardDefinitionID)
                case "Welcome Bonus": WelcomeBonusPageView(cardDefinitionID: dest.cardDefinitionID)
                case "Value": CardValuePageView()
                default: CardSubPageView(title: dest.pageName)
                }
            }
        }
    }
}

// MARK: - Card Row

private struct CardRowView: View {
    let userCard: UserCard
    let card: CreditCard

    private var unusedBenefitsCount: Int {
        userCard.benefitStates.filter { $0.status != .used }.count
    }

    private var isTrackingBonus: Bool {
        userCard.welcomeBonus?.isTracking == true
    }

    private var bonusRemaining: Double? {
        guard isTrackingBonus,
              let target = userCard.welcomeBonus?.targetSpend,
              let current = userCard.welcomeBonus?.currentSpend else { return nil }
        return max(0, target - current)
    }

    private var hasActivation: Bool {
        card.activationRequired != nil
    }

    private var renewalSoon: Bool {
        guard let renewal = userCard.renewalDate else { return false }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: renewal).day ?? 999
        return days >= 0 && days <= 30
    }

    var body: some View {
        HStack(spacing: 14) {
            // Small card visual
            CreditCardVisual(card: card)
                .frame(width: 80)

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(card.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)

                Text(card.issuer)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Status badges
                HStack(spacing: 6) {
                    trackingBadge

                    if !card.statementCredits.isEmpty && unusedBenefitsCount > 0 {
                        statusBadge(
                            "\(unusedBenefitsCount) unused",
                            color: .blue
                        )
                    }
                }

                // Additional status lines
                VStack(alignment: .leading, spacing: 3) {
                    if let remaining = bonusRemaining {
                        Label("Bonus: $\(Int(remaining)) remaining", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }

                    if hasActivation {
                        Label("Category activation needed", systemImage: "exclamationmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }

                    if renewalSoon {
                        Label("Annual fee upcoming", systemImage: "calendar.badge.exclamationmark")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.7))
        )
    }

    private var trackingBadge: some View {
        Text(userCard.trackingMode == .linked ? "Auto" : "Manual")
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(.black.opacity(0.08)))
            .foregroundStyle(.secondary)
    }

    private func statusBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.12)))
            .foregroundStyle(color)
    }
}

#Preview {
    CardsTabView()
        .environmentObject(CardStore())
}
