//
//  HomeView.swift
//  PerkBandit
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    var onViewCards: () -> Void = {}

    @EnvironmentObject var cardStore: CardStore
    @EnvironmentObject var authManager: AuthManager
    @State private var showNotifications = false
    @State private var showProfile = false
    @State private var hasCardDataOverride: Bool? = nil

    private var hasCardData: Bool {
        hasCardDataOverride ?? cardStore.isUserSelected
    }

    private var firstName: String {
        authManager.user?.displayName ?? "there"
    }

    private var greetingText: String {
        "Hi, \(firstName)"
    }

    var body: some View {
        ZStack {
            // Navy blue full page background
            LinearGradient(
                colors: [
                    Color(red: 12/255, green: 16/255, blue: 32/255),
                    Color(red: 20/255, green: 26/255, blue: 48/255),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Greeting, notification bell, and Scout (on navy background)
                    HomeHeroView(
                        greetingText: greetingText,
                        opportunityCount: cardStore.recommendations.count,
                        opportunityValue: cardStore.recommendations.compactMap { $0.estimatedValue }.reduce(0, +),
                        showNotifications: $showNotifications,
                        showProfile: $showProfile
                    )

                    // Card recommendation on navy
                    if hasCardData, let top = cardStore.recommendations.first {
                        RecommendationHeroCard(recommendation: top, cardStore: cardStore)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                    } else {
                        CardRecommendationCard(onViewCards: onViewCards)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                    }


                    // White content area starts below
                    VStack(alignment: .leading, spacing: 20) {
                        // Credits expiring + Bonus progress cards
                        HStack(spacing: 12) {
                            creditsExpiringCard
                            bonusProgressCard
                        }

                        // More Opportunities header
                        HStack {
                            Text("More Opportunities")
                                .font(.title3.weight(.bold))
                            Spacer()
                            Button {
                                // See all action
                            } label: {
                                Text("See all")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(PBTheme.accent)
                            }
                        }

                        // Opportunity rows
                        VStack(spacing: 0) {
                            let moreRecs = Array(cardStore.recommendations.dropFirst().prefix(3))
                            if moreRecs.isEmpty {
                                OpportunityRow(
                                    icon: "checkmark.circle.fill",
                                    iconColor: PBTheme.positive,
                                    title: "No urgent actions",
                                    subtitle: "All benefits are on track",
                                    trailingText: "",
                                    trailingColor: .clear
                                )
                            } else {
                                ForEach(Array(moreRecs.enumerated()), id: \.element.id) { index, rec in
                                    RecommendationRow(recommendation: rec)
                                    if index < moreRecs.count - 1 {
                                        Divider().padding(.leading, 52)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemBackground))
                        )

                        // Value captured
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Value captured")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.secondary)
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("$684.32")
                                        .font(.title2.weight(.bold))
                                    Text("this year")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("+$49.29")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(PBTheme.positive)
                                Text("this month")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemBackground))
                        )

                        // DEBUG: Toggle card data state override
                        Toggle(isOn: Binding(
                            get: { hasCardData },
                            set: { hasCardDataOverride = $0 }
                        )) {
                            Text("Has Card Data")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.gray)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 24,
                            topTrailingRadius: 24
                        )
                        .fill(Color(red: 245/255, green: 246/255, blue: 250/255))
                        .shadow(color: .black.opacity(0.15), radius: 12, y: -4)
                    )
                }
            }
        }
        .overlay {
            if showNotifications {
                NotificationsView(isPresented: $showNotifications)
                    .transition(.move(edge: .top))
                    .zIndex(1)
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(authManager)
        }
    }

    // MARK: - Credits Expiring Card

    private var creditsExpiringCard: some View {
        let expiring = cardStore.expiringBenefits
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("Credits expiring")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if let first = expiring.first {
                Text(first.credit.description)
                    .font(.subheadline.weight(.bold))
                Text(first.benefit.expiryText ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                    Text("$\(Int(first.credit.perPeriodAmount)) at risk")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.red)
                }
            } else {
                Text("All clear!")
                    .font(.subheadline.weight(.bold))
                Text("No credits expiring soon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }

    // MARK: - Bonus Progress Card

    private var bonusProgressCard: some View {
        let activeBonus = cardStore.cards.first { $0.welcomeBonus?.isTracking == true }
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "star.circle.fill")
                    .font(.caption)
                    .foregroundStyle(PBTheme.accent)
                Text("Bonus progress")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if let card = activeBonus, let bonus = card.welcomeBonus,
               let target = bonus.targetSpend, target > 0 {
                let current = bonus.currentSpend ?? 0
                let remaining = max(0, target - current)
                let progress = min(1.0, current / target)
                let cardName = card.definition?.name ?? "Card"

                Text("\(cardName) bonus")
                    .font(.subheadline.weight(.bold))
                Text("$\(Int(remaining)) left")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                GeometryReader { barGeo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                        Capsule()
                            .fill(PBTheme.accent)
                            .frame(width: barGeo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)

                Text("$\(Int(current)) / $\(Int(target))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("No active bonus")
                    .font(.subheadline.weight(.bold))
                Text("Set one up in your card details")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }

}

// MARK: - Top Hero Component

struct HomeHeroView: View {
    let greetingText: String
    let opportunityCount: Int
    let opportunityValue: Decimal
    @Binding var showNotifications: Bool
    @Binding var showProfile: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Greeting and notification bell
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greetingText)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("Welcome Back!")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)

                    if opportunityCount > 0 {
                        (Text("You have ")
                            .foregroundStyle(.white.opacity(0.6))
                        + Text("\(opportunityCount)")
                            .foregroundStyle(PBTheme.accent)
                            .fontWeight(.semibold)
                        + Text(" opportunity\(opportunityCount == 1 ? "" : "s") worth an estimated ")
                            .foregroundStyle(.white.opacity(0.6))
                        + Text("$\(NSDecimalNumber(decimal: opportunityValue).stringValue)")
                            .foregroundStyle(PBTheme.accent)
                            .fontWeight(.semibold)
                        + Text(" today.")
                            .foregroundStyle(.white.opacity(0.6)))
                            .font(.subheadline)
                    } else {
                        Text("All your benefits are on track!")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showNotifications = true
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(8)

                            Circle()
                                .fill(PBTheme.accent)
                                .frame(width: 8, height: 8)
                                .offset(x: -2, y: 6)
                        }
                    }

                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(8)
                    }
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 4)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Card Recommendation Component

struct CardRecommendationCard: View {
    var onViewCards: () -> Void = {}

    var body: some View {
        HStack(spacing: 16) {
            // Card illustration
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 40/255, green: 48/255, blue: 72/255))
                    .frame(width: 56, height: 40)
                    .rotationEffect(.degrees(-8))
                    .offset(x: -4, y: 4)

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 55/255, green: 65/255, blue: 95/255))
                    .frame(width: 56, height: 40)
                    .rotationEffect(.degrees(4))
                    .offset(x: 4, y: -2)

                Circle()
                    .fill(PBTheme.accent.opacity(0.3))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "magnifyingglass")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(PBTheme.accent)
                    )
                    .offset(x: 16, y: 12)
            }
            .frame(width: 80, height: 64)

            // Text + actions
            VStack(alignment: .leading, spacing: 8) {
                Text("No Best Card Right Now")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)

                Text("Tell Scout where you're shopping to find the best card. You can also add or update your cards for more personalized recommendations.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(3)

                HStack(spacing: 12) {
                    Button {
                        // Ask Scout action
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "message.fill")
                                .font(.caption2)
                            Text("Ask Scout")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(PBTheme.accent))
                    }

                    Button {
                        onViewCards()
                    } label: {
                        HStack(spacing: 2) {
                            Text("View Cards")
                                .font(.caption.weight(.medium))
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                        }
                        .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 24/255, green: 30/255, blue: 52/255))
        )
    }
}

// MARK: - Recommendation Hero Card

struct RecommendationHeroCard: View {
    let recommendation: Recommendation
    let cardStore: CardStore
    @State private var showExplanation = false

    private var cardDef: CreditCard? {
        guard let defID = recommendation.cardDefinitionID else { return nil }
        return catalogCard(for: defID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Label
            HStack(spacing: 6) {
                Image(systemName: "shield.checkered")
                    .font(.caption2)
                    .foregroundStyle(PBTheme.accent)
                Text("Scout's Best Opportunity")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
            }

            // Card image + recommendation text
            HStack(spacing: 14) {
                if let def = cardDef {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [def.gradientStart.color, def.gradientEnd.color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 48)
                        .overlay(
                            Text(def.network)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white.opacity(0.8))
                            , alignment: .bottomTrailing
                        )
                        .padding(.trailing, 2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text(recommendation.subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(2)
                }
            }

            // Value estimate
            if let value = recommendation.estimatedValue {
                VStack(alignment: .leading, spacing: 4) {
                    Text("+$\(NSDecimalNumber(decimal: value).intValue)")
                        .font(.title.weight(.bold))
                        .foregroundStyle(PBTheme.positive)

                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundStyle(PBTheme.accent)
                        Text("Estimated value at risk")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }

            // Explanation
            if showExplanation {
                Text(recommendation.explanation)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.white.opacity(0.06))
                    )
            }

            // Action pills
            HStack(spacing: 10) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showExplanation.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.caption2)
                        Text("Why this?")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 24/255, green: 30/255, blue: 52/255))
        )
    }
}

// MARK: - Recommendation Row

struct RecommendationRow: View {
    let recommendation: Recommendation

    private var color: Color {
        switch recommendation.iconColor {
        case "red": return .red
        case "orange": return .orange
        case "blue": return PBTheme.accent
        case "purple": return .purple
        default: return .orange
        }
    }

    var body: some View {
        OpportunityRow(
            icon: recommendation.icon,
            iconColor: color,
            title: recommendation.title,
            subtitle: recommendation.subtitle,
            trailingText: recommendation.urgency.label,
            trailingColor: color
        )
    }
}


// MARK: - Opportunity Row

struct OpportunityRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let trailingText: String
    let trailingColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(iconColor.opacity(0.12))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(iconColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(trailingText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(trailingColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            ZStack {
                PBTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.white.opacity(0.6))

                    if let name = authManager.user?.displayName {
                        Text(name)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                    }

                    if let email = authManager.user?.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Spacer()

                    Button(role: .destructive) {
                        authManager.signOut()
                        dismiss()
                    } label: {
                        Text("Sign Out")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.red.opacity(0.12))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .padding(.top, 40)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CardStore())
        .environmentObject(AuthManager())
}
