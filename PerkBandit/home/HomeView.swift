//
//  HomeView.swift
//  PerkBandit
//

import SwiftUI

struct HomeView: View {
    @State private var showNotifications = false
    @State private var hasCardData = false

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning, Yaw"
        case 12..<17: return "Good Afternoon, Yaw"
        default: return "Good Evening, Yaw"
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // Navy fill for status bar area
            Color(red: 12/255, green: 16/255, blue: 32/255)
                .frame(height: 0)
                .background(Color(red: 12/255, green: 16/255, blue: 32/255))
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(spacing: 0) {
                    // Hero content (greeting, scout, etc.)
                    HomeHeroView(
                        greetingText: greetingText,
                        showNotifications: $showNotifications,
                        hasCardData: hasCardData
                    )

                    // Card recommendation overlaps the hero (only when no card data)
                    if !hasCardData {
                        CardRecommendationCard()
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                            .offset(y: -16)
                    }

                    // DEBUG: Toggle card data state
                    Toggle(isOn: $hasCardData) {
                        Text("Has Card Data")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    Spacer()
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
    }
}

// MARK: - Top Hero Component

struct HomeHeroView: View {
    let greetingText: String
    @Binding var showNotifications: Bool
    var hasCardData: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Greeting, notification bell, and Scout
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hi, Yaw")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("Welcome Back!")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)

                    (Text("You have ")
                        .foregroundStyle(.white.opacity(0.6))
                    + Text("2")
                        .foregroundStyle(PBTheme.accent)
                        .fontWeight(.semibold)
                    + Text(" opportunities worth an estimated value today.")
                        .foregroundStyle(.white.opacity(0.6)))
                        .font(.subheadline)
                }

                Spacer()

                VStack(spacing: 16) {
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

                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(PBTheme.accent.opacity(0.15))
                                .frame(width: 64, height: 64)

                            Image(systemName: "theatermask.and.paintbrush")
                                .font(.system(size: 28))
                                .foregroundStyle(PBTheme.accent)
                        }

                        HStack(spacing: 4) {
                            Text("Scout")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                            Image(systemName: "sparkle")
                                .font(.caption2)
                                .foregroundStyle(PBTheme.accent)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            if hasCardData {
                ActiveCardRecommendation()
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
            }
        }
        .background(
            UnevenRoundedRectangle(
                bottomLeadingRadius: 32,
                bottomTrailingRadius: 32
            )
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 12/255, green: 16/255, blue: 32/255),
                        Color(red: 20/255, green: 26/255, blue: 48/255),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .padding(.bottom, hasCardData ? 0 : -80)
            .ignoresSafeArea(edges: .top)
        )
    }
}

// MARK: - Card Recommendation Component

struct CardRecommendationCard: View {
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

                Text("Scout needs a recent transaction, merchant, or more card data to recommend your best card.")
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
                        // View Cards action
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

// MARK: - Active Card Recommendation (has card data)

struct ActiveCardRecommendation: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Scout's Best Opportunity label
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
                // Credit card visual
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 196/255, green: 170/255, blue: 80/255),
                                Color(red: 160/255, green: 135/255, blue: 60/255),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 48)
                    .overlay(
                        Text("AMEX")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                        , alignment: .bottomTrailing
                    )
                    .padding(.trailing, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Use your Amex Gold for lunch")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("4x dining points · $10 dining credit may still be available")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(2)
                }
            }

            // Value estimate
            VStack(alignment: .leading, spacing: 4) {
                Text("+$6.20")
                    .font(.title.weight(.bold))
                    .foregroundStyle(PBTheme.positive)

                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundStyle(PBTheme.accent)
                    Text("Best value right now")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            // Action pills
            HStack(spacing: 10) {
                Button {
                    // Why this card action
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.caption2)
                        Text("Why this card?")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                }

                Button {
                    // Where are you shopping action
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle")
                            .font(.caption2)
                        Text("Where are you shopping?")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(PBTheme.accent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().stroke(PBTheme.accent.opacity(0.4), lineWidth: 1)
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

#Preview {
    HomeView()
}
