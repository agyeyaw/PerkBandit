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
    @State private var showCategoryPicker = false
    @State private var selectedOpportunity: Opportunity?
    @State private var showAddCard = false
    @State private var showHowItWorks = false

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
                let opportunities = cardStore.opportunities

                VStack(spacing: 0) {
                    // Greeting, notification bell, and profile (on navy background)
                    HomeHeroView(
                        greetingText: greetingText,
                        opportunityCount: opportunities.count,
                        hasCards: cardStore.hasCards,
                        showNotifications: $showNotifications,
                        showProfile: $showProfile
                    )

                    if cardStore.hasCards {
                        cardAwareBody(opportunities: opportunities)
                    } else {
                        zeroCardBody
                    }
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
        .sheet(isPresented: $showCategoryPicker) {
            SpendingCategorySheet()
                .environmentObject(cardStore)
        }
        .sheet(item: $selectedOpportunity) { opp in
            OpportunityActionSheet(opportunity: opp)
                .environmentObject(cardStore)
        }
        .sheet(isPresented: $showAddCard) {
            AddCardSheet()
                .environmentObject(cardStore)
        }
        .sheet(isPresented: $showHowItWorks) {
            HowItWorksView()
        }
    }

    // MARK: - Card-Aware Body

    @ViewBuilder
    private func cardAwareBody(opportunities: [Opportunity]) -> some View {
        // "Where are you shopping?" button
        Button {
            showCategoryPicker = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.subheadline.weight(.semibold))
                Text("Where are you shopping?")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Capsule().fill(PBTheme.accent))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)

        // Opportunity hero card
        if let top = opportunities.first {
            OpportunityHeroCard(opportunity: top, cardStore: cardStore)
                .onTapGesture { selectedOpportunity = top }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        } else {
            CardRecommendationCard(onViewCards: onViewCards)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }

        // White content area
        VStack(alignment: .leading, spacing: 20) {
            // Small opportunity cards (#2 and #3)
            let smallOpps = Array(opportunities.dropFirst().prefix(2))
            if !smallOpps.isEmpty {
                HStack(spacing: 12) {
                    ForEach(smallOpps) { opp in
                        OpportunitySmallCard(opportunity: opp)
                            .onTapGesture { selectedOpportunity = opp }
                    }
                    if smallOpps.count == 1 {
                        Spacer().frame(maxWidth: .infinity)
                    }
                }
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
                let moreOpps = Array(opportunities.dropFirst(3).prefix(3))
                if moreOpps.isEmpty {
                    OpportunityRow(
                        icon: "checkmark.circle.fill",
                        iconColor: PBTheme.positive,
                        title: "No urgent actions",
                        subtitle: "All benefits are on track",
                        trailingText: "",
                        trailingColor: .clear
                    )
                } else {
                    ForEach(Array(moreOpps.enumerated()), id: \.element.id) { index, opp in
                        Button {
                            selectedOpportunity = opp
                        } label: {
                            OpportunityListRow(opportunity: opp)
                        }
                        .buttonStyle(.plain)
                        if index < moreOpps.count - 1 {
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

            // Your Credits section
            let allCredits: [(userCardID: String, cardName: String, state: UserBenefitState, credit: StatementCredit)] = cardStore.cards.flatMap { userCard -> [(String, String, UserBenefitState, StatementCredit)] in
                guard let def = userCard.definition else { return [] }
                return userCard.benefitStates.compactMap { state in
                    guard state.status != .used,
                          let credit = def.statementCredits.first(where: { $0.description == state.id })
                    else { return nil }
                    return (userCard.id, def.name, state, credit)
                }
            }

            if !allCredits.isEmpty {
                HStack {
                    Text("Your Credits")
                        .font(.title3.weight(.bold))
                    Spacer()
                    Text("\(allCredits.count) unused")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(PBTheme.accent)
                }

                VStack(spacing: 0) {
                    ForEach(Array(allCredits.enumerated()), id: \.element.state.id) { index, item in
                        Button {
                            cardStore.toggleBenefitStatus(
                                userCardID: item.userCardID,
                                benefitID: item.state.id
                            )
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.blue.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: OpportunityEngine.iconForBenefit(item.credit.description))
                                            .font(.caption)
                                            .foregroundStyle(.blue)
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.credit.description)
                                        .font(.subheadline.weight(.medium))
                                    Text("\(item.cardName) · \(item.credit.frequency.label)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("$\(Int(item.credit.perPeriodAmount))")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.green)
                                    Text(item.state.status == .available ? "Available" : "Not Sure")
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(item.state.status == .available ? .green : .orange)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)

                        if index < allCredits.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 500)
        .background(
            VStack(spacing: 0) {
                UnevenRoundedRectangle(
                    topLeadingRadius: 24,
                    topTrailingRadius: 24
                )
                .fill(Color(red: 245/255, green: 246/255, blue: 250/255))
                .shadow(color: .black.opacity(0.15), radius: 12, y: -4)

                Rectangle()
                    .fill(Color(red: 245/255, green: 246/255, blue: 250/255))
            }
        )
    }

    // MARK: - Zero-Card Body

    @ViewBuilder
    private var zeroCardBody: some View {
        // "Add Your First Card" CTA
        Button {
            showAddCard = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                Text("Add Your First Card")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Capsule().fill(PBTheme.accent))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)

        // Zero-card hero card
        CardRecommendationCard(onViewCards: { showAddCard = true })
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

        // White content area — Get Started
        VStack(alignment: .leading, spacing: 20) {
            Text("Get Started")
                .font(.title3.weight(.bold))

            VStack(spacing: 0) {
                Button { showAddCard = true } label: {
                    getStartedRow(
                        icon: "creditcard.fill",
                        iconColor: PBTheme.accent,
                        title: "Add your first card",
                        subtitle: "Get personalized recommendations, benefit tracking, and reminders."
                    )
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 52)

                Button { showHowItWorks = true } label: {
                    getStartedRow(
                        icon: "lightbulb.fill",
                        iconColor: .orange,
                        title: "See how PerkBandit works",
                        subtitle: "Preview how card recommendations and opportunities work."
                    )
                }
                .buttonStyle(.plain)
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 500)
        .background(
            VStack(spacing: 0) {
                UnevenRoundedRectangle(
                    topLeadingRadius: 24,
                    topTrailingRadius: 24
                )
                .fill(Color(red: 245/255, green: 246/255, blue: 250/255))
                .shadow(color: .black.opacity(0.15), radius: 12, y: -4)

                Rectangle()
                    .fill(Color(red: 245/255, green: 246/255, blue: 250/255))
            }
        )
    }

    private func getStartedRow(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
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
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

// MARK: - Top Hero Component

struct HomeHeroView: View {
    let greetingText: String
    let opportunityCount: Int
    let hasCards: Bool
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

                    if !hasCards {
                        Text("Add your cards to start finding opportunities.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    } else if opportunityCount > 0 {
                        (Text("You have ")
                            .foregroundStyle(.white.opacity(0.6))
                        + Text("\(opportunityCount)")
                            .foregroundStyle(PBTheme.accent)
                            .fontWeight(.semibold)
                        + Text(" opportunity\(opportunityCount == 1 ? "" : "s") to check today.")
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
                                .font(.system(size: 17))
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
                            .font(.system(size: 34))
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

                Text("Tell PerkBandit where you're shopping to find the best card. You can also add or update your cards for more personalized recommendations.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(3)

                HStack(spacing: 12) {
                    Button {
                        // Ask PerkBandit action
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "message.fill")
                                .font(.caption2)
                            Text("Ask PerkBandit")
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

// MARK: - Opportunity Hero Card

struct OpportunityHeroCard: View {
    let opportunity: Opportunity
    let cardStore: CardStore
    @State private var showExplanation = false

    private var cardDef: CreditCard? {
        guard let defID = opportunity.cardDefinitionID else { return nil }
        return catalogCard(for: defID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Label
            Text("Top Opportunity")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.6))

            // Full-width card visual
            if let def = cardDef {
                CreditCardVisual(card: def)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(opportunity.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)

                Text(opportunity.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(2)
            }

            // Value estimate (only for expiring benefits where the value is a real credit amount)
            if opportunity.type == .expiringBenefit, let value = opportunity.estimatedValue {
                VStack(alignment: .leading, spacing: 4) {
                    Text("+$\(NSDecimalNumber(decimal: value).intValue)")
                        .font(.title.weight(.bold))
                        .foregroundStyle(PBTheme.positive)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundStyle(PBTheme.accent)
                        Text("Unclaimed credit expiring")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }

            // Welcome bonus progress
            if opportunity.type == .welcomeBonus, let progress = opportunity.progress {
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.15))
                            .frame(height: 6)
                        GeometryReader { geo in
                            Capsule()
                                .fill(PBTheme.accent)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                        .frame(height: 6)
                    }

                    HStack {
                        Text("\(Int(progress * 100))% complete")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        Spacer()
                        if let deadline = opportunity.expirationDate {
                            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
                            Text("\(daysLeft) days left")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(daysLeft <= 7 ? .red : PBTheme.accent)
                        }
                    }
                }
            }

            // Explanation
            if showExplanation {
                Text(opportunity.explanation)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 24/255, green: 30/255, blue: 52/255))
        )
    }
}

// MARK: - Opportunity Small Card

struct OpportunitySmallCard: View {
    let opportunity: Opportunity

    private var headerIcon: String {
        switch opportunity.type {
        case .expiringBenefit: return "clock.arrow.circlepath"
        case .welcomeBonus: return "star.circle.fill"
        case .categoryActivation: return "bolt.circle.fill"
        case .annualFeeReview: return "dollarsign.circle.fill"
        case .cardRecommendation: return "creditcard.fill"
        }
    }

    private var headerColor: Color {
        switch opportunity.type {
        case .expiringBenefit: return .orange
        case .welcomeBonus: return PBTheme.accent
        case .categoryActivation: return .blue
        case .annualFeeReview: return .orange
        case .cardRecommendation: return PBTheme.accent
        }
    }

    private var headerLabel: String {
        switch opportunity.type {
        case .expiringBenefit: return "Credits expiring"
        case .welcomeBonus: return "Bonus progress"
        case .categoryActivation: return "Activation needed"
        case .annualFeeReview: return "Annual fee"
        case .cardRecommendation: return "Recommendation"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: headerIcon)
                    .font(.caption)
                    .foregroundStyle(headerColor)
                Text(headerLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            switch opportunity.type {
            case .expiringBenefit:
                expiringBenefitBody
            case .welcomeBonus:
                welcomeBonusBody
            default:
                defaultBody
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }

    private var expiringBenefitBody: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(opportunity.title)
                .font(.subheadline.weight(.bold))
                .lineLimit(2)
            Text(opportunity.urgency.label)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let value = opportunity.estimatedValue {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                    Text("$\(NSDecimalNumber(decimal: value).intValue) credit expiring")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private var welcomeBonusBody: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(opportunity.title)
                .font(.subheadline.weight(.bold))
                .lineLimit(2)
            Text(opportunity.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let progress = opportunity.progress {
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

                Text("\(Int(progress * 100))% complete")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var defaultBody: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(opportunity.title)
                .font(.subheadline.weight(.bold))
                .lineLimit(2)
            Text(opportunity.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Opportunity List Row

struct OpportunityListRow: View {
    let opportunity: Opportunity

    private var color: Color {
        switch opportunity.iconColor {
        case "red": return .red
        case "orange": return .orange
        case "blue": return PBTheme.accent
        case "purple": return .purple
        default: return .orange
        }
    }

    var body: some View {
        OpportunityRow(
            icon: opportunity.icon,
            iconColor: color,
            title: opportunity.title,
            subtitle: opportunity.subtitle,
            trailingText: opportunity.urgency.label,
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

// MARK: - Zero Card Hero Card

struct ZeroCardHeroCard: View {
    var onAddCard: () -> Void
    var onHowItWorks: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add a card to get personalized recommendations")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)

            Text("PerkBandit can compare rewards, track benefits, and remind you before value expires.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(3)

            HStack(spacing: 12) {
                Button(action: onAddCard) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption2)
                        Text("Add a Card")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(PBTheme.accent))
                }

                Button(action: onHowItWorks) {
                    HStack(spacing: 2) {
                        Text("See How It Works")
                            .font(.caption.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 24/255, green: 30/255, blue: 52/255))
        )
    }
}

// MARK: - Add Card Sheet

struct AddCardSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cardStore: CardStore
    @State private var selectedCards: [String] = []

    private var alreadyOwnedCards: Set<String> {
        Set(cardStore.cards.map { $0.cardDefinitionID })
    }

    var body: some View {
        NavigationStack {
            ManualCardSetupView(selectedCards: $selectedCards, alreadyOwnedCards: alreadyOwnedCards) {
                guard !selectedCards.isEmpty else {
                    dismiss()
                    return
                }
                let newCards: [UserCard] = selectedCards.compactMap { cardId in
                    guard catalogCard(for: cardId) != nil else { return nil }
                    return UserCard.fromCatalog(id: cardId)
                }
                let existingIDs = Set(cardStore.cards.map { $0.cardDefinitionID })
                let uniqueNewCards = newCards.filter { !existingIDs.contains($0.cardDefinitionID) }
                cardStore.cards.append(contentsOf: uniqueNewCards)
                cardStore.isUserSelected = true
                cardStore.save()
                dismiss()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            selectedCards = cardStore.cards.map { $0.cardDefinitionID }
        }
    }
}

// MARK: - How It Works View

struct HowItWorksView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How PerkBandit Works")
                            .font(.title2.weight(.bold))
                        Text("Here's a preview of what you'll see once you add your cards.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Sample opportunity
                    sampleSection(
                        title: "Smart Recommendations",
                        icon: "creditcard.fill",
                        iconColor: PBTheme.accent
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            sampleBadge

                            Text("Best Card for Dining")
                                .font(.subheadline.weight(.bold))
                            Text("PerkBandit analyzes your cards and tells you which one earns the most rewards for each purchase category.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Sample benefit tracking
                    sampleSection(
                        title: "Benefit Tracking",
                        icon: "clock.arrow.circlepath",
                        iconColor: .orange
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            sampleBadge

                            Text("$300 Travel Credit Expiring")
                                .font(.subheadline.weight(.bold))
                            Text("Get reminders before your statement credits and perks expire so you never leave money on the table.")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                                Text("Expires in 45 days")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.orange)
                            }
                        }
                    }

                    // Sample welcome bonus
                    sampleSection(
                        title: "Welcome Bonus Progress",
                        icon: "star.circle.fill",
                        iconColor: PBTheme.accent
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            sampleBadge

                            Text("Chase Sapphire Preferred")
                                .font(.subheadline.weight(.bold))
                            Text("Track your spending toward welcome bonus requirements with real-time progress.")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            // Progress bar
                            VStack(alignment: .leading, spacing: 4) {
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.systemGray5))
                                        .frame(height: 6)
                                    Capsule()
                                        .fill(PBTheme.accent)
                                        .frame(width: 150, height: 6)
                                }

                                Text("$3,000 / $4,000 spent")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(red: 245/255, green: 246/255, blue: 250/255))
            .navigationTitle("How It Works")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var sampleBadge: some View {
        Text("SAMPLE")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(PBTheme.accent)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(PBTheme.accent.opacity(0.12))
            )
    }

    private func sampleSection<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }

            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                )
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CardStore())
        .environmentObject(AuthManager())
}
