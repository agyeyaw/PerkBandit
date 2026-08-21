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
    @State private var viewportHeight: CGFloat = 0

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

            GeometryReader { geo in
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
                .onAppear { viewportHeight = geo.size.height }
                .onChange(of: geo.size.height) { _, newH in viewportHeight = newH }
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

        // Data flow
        let topOpportunity = opportunities.first
        let remaining = Array(opportunities.dropFirst())
        let highlights = Array(remaining.prefix(2))
        let moreOpportunities = Array(remaining.dropFirst(2).prefix(4))
        let allCredits: [(userCardID: String, cardName: String, state: UserBenefitState, credit: StatementCredit)] = cardStore.cards.flatMap { userCard -> [(String, String, UserBenefitState, StatementCredit)] in
            guard let def = userCard.definition else { return [] }
            return userCard.benefitStates.compactMap { state in
                guard state.status != .used,
                      let credit = def.statementCredits.first(where: { $0.description == state.id })
                else { return nil }
                return (userCard.id, def.name, state, credit)
            }
        }
        let valueCaptured = OpportunityEngine.estimatedValueCaptured(cards: cardStore.cards)

        // Top Opportunity Card
        if let top = topOpportunity {
            TopOpportunityCard(opportunity: top, cardStore: cardStore, onViewCards: onViewCards)
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
            // Highlight tiles
            if !highlights.isEmpty {
                let columns: [GridItem] = highlights.count == 1
                    ? [GridItem(.flexible())]
                    : [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(highlights) { opp in
                        OpportunityHighlightTile(opportunity: opp)
                            .onTapGesture { selectedOpportunity = opp }
                    }
                }
            }

            // More Opportunities section
            if !moreOpportunities.isEmpty {
                MoreOpportunitiesSection(
                    opportunities: moreOpportunities,
                    onSelect: { opp in selectedOpportunity = opp }
                )
            }

            // Empty state when no opportunities at all
            if opportunities.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(PBTheme.positive)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("You're all caught up")
                            .font(.subheadline.weight(.medium))
                        Text("No urgent actions based on your latest updates.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                )
            }

            // Credits Carousel
            if !allCredits.isEmpty {
                CreditsCarousel(credits: allCredits, cardStore: cardStore)
            }

            // Value Captured Card
            if let value = valueCaptured {
                ValueCapturedCard(thisYear: value.thisYear, thisMonth: value.thisMonth)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .frame(minHeight: viewportHeight * 0.6, alignment: .top)
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
        ZeroCardHeroCard(onAddCard: { showAddCard = true }, onHowItWorks: { showHowItWorks = true })
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
        .frame(minHeight: viewportHeight * 0.6, alignment: .top)
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
            // Profile icon, greeting, and notification bell
            HStack(alignment: .center, spacing: 10) {
                // Profile icon — top-left, smaller
                Button {
                    showProfile = true
                } label: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.8))
                }

                HStack(spacing: 6) {
                    Text(greetingText)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.6))

                    // Notification bell — right of greeting
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showNotifications = true
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.system(size: 15))
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.horizontal, 4)

                            Circle()
                                .fill(PBTheme.accent)
                                .frame(width: 8, height: 8)
                                .offset(x: -2, y: 6)
                        }
                    }
                }

                Spacer()

                // Upgrade button — top-right
                Button {
                    // TODO: Navigate to premium upgrade
                } label: {
                    HStack(spacing: 2) {
                        Text("Go Premium")
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(PBTheme.accent)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 16)
            .padding(.top, 12)
            .padding(.bottom, 6)

            // "Welcome Back!" — flush left, aligned with "Where are you shopping?"
            Text("Welcome Back!")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
                .padding(.leading, 20)
                .padding(.bottom, 6)

            // Subtitle — flush left
            Group {
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
            .padding(.leading, 20)
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

// MARK: - Top Opportunity Card

struct TopOpportunityCard: View {
    let opportunity: Opportunity
    let cardStore: CardStore
    var onViewCards: () -> Void = {}
    @State private var showExplanation = false

    private var cardDef: CreditCard? {
        guard let defID = opportunity.cardDefinitionID else { return nil }
        return catalogCard(for: defID)
    }

    private var statusBadge: (text: String, color: Color)? {
        if opportunity.type == .expiringBenefit, let value = opportunity.estimatedValue {
            return ("+$\(NSDecimalNumber(decimal: value).intValue)", PBTheme.positive)
        }
        if opportunity.urgency <= .medium {
            return ("Action needed", .orange)
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack {
                Text("Top Opportunity")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                Button(action: onViewCards) {
                    HStack(spacing: 2) {
                        Text("View cards")
                            .font(.caption.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundStyle(PBTheme.accent)
                }
            }

            // Card visual + details side by side
            HStack(alignment: .top, spacing: 14) {
                if let def = cardDef {
                    CreditCardVisual(card: def)
                        .frame(width: 120)
                }

                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(opportunity.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text(opportunity.subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(2)

                    // Status badge
                    if let badge = statusBadge {
                        Text(badge.text)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(badge.color)
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

                    // Action pill
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

            // Explanation (full width, below the HStack)
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 24/255, green: 30/255, blue: 52/255))
        )
    }
}

// MARK: - Opportunity Highlight Tile

struct OpportunityHighlightTile: View {
    let opportunity: Opportunity

    private var badgeColor: Color {
        switch opportunity.type {
        case .expiringBenefit: return .orange
        case .welcomeBonus: return .blue
        case .categoryActivation: return .green
        case .annualFeeReview: return .orange
        case .needsConfirmation: return .orange
        case .cardRecommendation: return .blue
        }
    }

    private var badgeLabel: String {
        switch opportunity.type {
        case .expiringBenefit: return "Expiring soon"
        case .welcomeBonus: return "Bonus progress"
        case .categoryActivation: return "Action needed"
        case .annualFeeReview: return "Annual fee"
        case .needsConfirmation: return "Needs confirmation"
        case .cardRecommendation: return "Recommendation"
        }
    }

    private var valueText: String {
        if let value = opportunity.estimatedValue {
            return "$\(NSDecimalNumber(decimal: value).intValue)"
        }
        return opportunity.title
    }

    private var cardName: String {
        if let defID = opportunity.cardDefinitionID,
           let def = catalogCard(for: defID) {
            return def.name
        }
        return opportunity.subtitle
    }

    private var detailText: String? {
        switch opportunity.type {
        case .expiringBenefit:
            if let date = opportunity.expirationDate {
                let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
                return days <= 0 ? "Expires today" : "Expires in \(days) day\(days == 1 ? "" : "s")"
            }
            return opportunity.urgency.label
        case .welcomeBonus:
            return nil
        case .annualFeeReview:
            if let date = opportunity.expirationDate {
                let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
                return "Due in \(days) day\(days == 1 ? "" : "s")"
            }
            return nil
        case .needsConfirmation:
            return "Tap to confirm"
        default:
            return nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Badge
            HStack(spacing: 4) {
                Circle()
                    .fill(badgeColor)
                    .frame(width: 6, height: 6)
                Text(badgeLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(badgeColor)
            }

            Spacer().frame(height: 0)

            // Value / title
            if opportunity.estimatedValue != nil {
                Text(valueText)
                    .font(.title3.weight(.bold))
                    .lineLimit(1)
            } else {
                Text(opportunity.title)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(2)
            }

            // Card name
            Text(cardName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            // Progress bar for welcome bonus
            if opportunity.type == .welcomeBonus, let progress = opportunity.progress {
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray5))
                                .frame(height: 5)
                            Capsule()
                                .fill(PBTheme.accent)
                                .frame(width: geo.size.width * progress, height: 5)
                        }
                    }
                    .frame(height: 5)

                    Text("\(Int(progress * 100))% complete")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else if let detail = detailText {
                Text(detail)
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

// MARK: - More Opportunities Section

struct MoreOpportunitiesSection: View {
    let opportunities: [Opportunity]
    var onSelect: (Opportunity) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("More Opportunities")
                    .font(.title3.weight(.bold))
                Spacer()
                Button {
                    // See all
                } label: {
                    Text("See all")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(PBTheme.accent)
                }
            }

            VStack(spacing: 0) {
                ForEach(Array(opportunities.enumerated()), id: \.element.id) { index, opp in
                    Button { onSelect(opp) } label: {
                        OpportunityRow(
                            icon: opp.icon,
                            iconColor: opportunityColor(opp),
                            title: opp.title,
                            subtitle: opp.subtitle,
                            trailingText: opp.urgency.label,
                            trailingColor: opportunityColor(opp)
                        )
                    }
                    .buttonStyle(.plain)

                    if index < opportunities.count - 1 {
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

    private func opportunityColor(_ opp: Opportunity) -> Color {
        switch opp.iconColor {
        case "red": return .red
        case "orange": return .orange
        case "blue": return PBTheme.accent
        case "purple": return .purple
        default: return .orange
        }
    }
}

// MARK: - Credits Carousel

struct CreditsCarousel: View {
    let credits: [(userCardID: String, cardName: String, state: UserBenefitState, credit: StatementCredit)]
    let cardStore: CardStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Credits")
                    .font(.title3.weight(.bold))
                Spacer()
                Text("See all")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(PBTheme.accent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(credits.enumerated()), id: \.element.state.id) { _, item in
                        Button {
                            cardStore.toggleBenefitStatus(
                                userCardID: item.userCardID,
                                benefitID: item.state.id
                            )
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: OpportunityEngine.iconForBenefit(item.credit.description))
                                    .font(.title3)
                                    .foregroundStyle(.blue)

                                Text("$\(Int(item.credit.perPeriodAmount))")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.primary)

                                Text(item.credit.description)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)

                                Text(item.state.status == .available ? "Available" : "Not Sure")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(item.state.status == .available ? .green : .orange)
                            }
                            .frame(width: 100)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Value Captured Card

struct ValueCapturedCard: View {
    let thisYear: Decimal
    let thisMonth: Decimal

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Estimated value captured")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("$\(NSDecimalNumber(decimal: thisYear).intValue) this year")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)

                if thisMonth > 0 {
                    Text("+$\(NSDecimalNumber(decimal: thisMonth).intValue) this month")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(PBTheme.positive)
                }
            }

            Spacer()

            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title2)
                .foregroundStyle(PBTheme.positive.opacity(0.6))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.green.opacity(0.08))
        )
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
        cardStore.isUserSelected ? Set(cardStore.cards.map { $0.cardDefinitionID }) : []
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
                if cardStore.isUserSelected {
                    // Append only truly new cards
                    let existingIDs = Set(cardStore.cards.map { $0.cardDefinitionID })
                    let uniqueNewCards = newCards.filter { !existingIDs.contains($0.cardDefinitionID) }
                    cardStore.cards.append(contentsOf: uniqueNewCards)
                } else {
                    // First real selection — discard phantom defaults
                    cardStore.cards = newCards
                }
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
            selectedCards = cardStore.isUserSelected ? cardStore.cards.map { $0.cardDefinitionID } : []
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
        .environmentObject(CardStore(catalogService: CardCatalogService()))
        .environmentObject(AuthManager())
}
