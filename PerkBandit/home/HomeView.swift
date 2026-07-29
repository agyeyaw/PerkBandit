//
//  HomeView.swift
//  PerkBandit
//

import SwiftUI

struct HomeView: View {
    @State private var cardExpanded = false
    @State private var dragOffset: CGFloat = 0
    @State private var selectedCardIndex = 0
    @State private var scrolledToTop = true

    private let mockCards = MockCard.samples

    private var totalBalance: Double {
        mockCards.reduce(0) { $0 + $1.balance }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        switch hour {
        case 5..<12: timeOfDay = "Good Morning"
        case 12..<17: timeOfDay = "Good Afternoon"
        default: timeOfDay = "Good Evening"
        }
        return "\(timeOfDay), Yaw"
    }

    var body: some View {
        GeometryReader { geo in
            let restingY = geo.size.height * 0.50
            let expandedY: CGFloat = 100
            let baseOffset = cardExpanded ? expandedY : restingY
            let currentOffset = min(restingY, max(expandedY, baseOffset + dragOffset))

            ZStack(alignment: .top) {
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 24/255, green: 32/255, blue: 51/255), location: 0.10),
                        .init(color: Color(red: 29/255, green: 36/255, blue: 51/255), location: 0.18),
                        .init(color: Color(red: 57/255, green: 69/255, blue: 95/255), location: 0.32),
                        .init(color: Color(red: 43/255, green: 53/255, blue: 73/255), location: 0.37),
                        .init(color: Color(red: 24/255, green: 32/255, blue: 51/255), location: 0.42),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Greeting header + Total balance
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greetingText)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)
                            Text("You Have 2 Opportunities")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                            Text("Today Worth An Estimated")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        Button(action: {}) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .padding(8)

                                Text("2")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 16, height: 16)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }

                    // Total credit balance
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Credit Balance")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        formattedBalance(totalBalance, largeSize: 25, smallSize: 20)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Credit card carousel
                VStack {
                    Spacer()
                    HomeCardCarousel(cards: mockCards, selectedIndex: $selectedCardIndex)
                }
                .frame(height: restingY - 40)

                VStack(spacing: 0) {
                    // Drag handle
                    Capsule()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 40, height: 5)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { dragOffset = $0.translation.height }
                                .onEnded { value in
                                    let velocity = value.predictedEndTranslation.height - value.translation.height
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                        if cardExpanded && (dragOffset > 50 || velocity > 300) {
                                            cardExpanded = false
                                        } else if !cardExpanded && (dragOffset < -50 || velocity < -300) {
                                            cardExpanded = true
                                        }
                                        dragOffset = 0
                                    }
                                }
                        )

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Section title
                            Text("Today's Top Opportunities")
                                .font(.title3.weight(.bold))
                                .padding(.bottom, -4)

                            // Target Score + Potential Value card
                            HStack(spacing: 0) {
                                // Left side — Target Score
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Today's Target Score")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                    Text("92/100")
                                        .font(.title.weight(.bold))
                                    GeometryReader { barGeo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color(.systemGray4))
                                                .frame(height: 6)
                                            Capsule()
                                                .fill(Color.green)
                                                .frame(width: barGeo.size.width * 0.92, height: 6)
                                        }
                                    }
                                    .frame(height: 6)
                                    Text("3 Of 4 Opportunities Remaining")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Divider()
                                    .padding(.vertical, 8)

                                // Right side — Potential Value
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Potential Value")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                    Text("+$18.92")
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(.green)
                                }
                                .frame(width: 100)
                                .padding(.leading, 12)
                            }
                            .padding(16)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                            // Opportunity Card 1
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "creditcard")
                                            .font(.body)
                                            .foregroundStyle(.white)
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Use Your Amex Gold For Lunch")
                                        .font(.subheadline.weight(.semibold))
                                    Text("Grubhub / Restaurant")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            // Opportunity Card 2
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(red: 24/255, green: 32/255, blue: 51/255))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "clock")
                                            .font(.body)
                                            .foregroundStyle(.white)
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Uber Cash Credit Expires Tomorrow")
                                        .font(.subheadline.weight(.semibold))
                                    Text("$10 Remaining")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            // Bottom row — Value Generated + Ask Pilot
                            HStack(spacing: 12) {
                                // Value Generated card
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Value Generated")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                    Text("$684.32")
                                        .font(.title2.weight(.bold))
                                    Text("This Year")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                    Divider()
                                    Text("+$49.29")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.green)
                                    Text("This Month")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 16))

                                // Ask Pilot card
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Ask Pilot")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("Where Are You Shopping?")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .background(Color(red: 24/255, green: 32/255, blue: 51/255))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onChange(of: proxy.frame(in: .named("sheet")).minY) { _, newValue in
                                        scrolledToTop = newValue >= 0
                                    }
                            }
                        )
                    }
                    .coordinateSpace(name: "sheet")
                    .scrollDisabled(!cardExpanded)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 24,
                        topTrailingRadius: 24
                    )
                    .fill(Color.white)
                )
                .offset(y: currentOffset)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.height
                        }
                        .onEnded { value in
                            let velocity = value.predictedEndTranslation.height - value.translation.height
                            let threshold: CGFloat = 100

                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                if cardExpanded {
                                    // Only collapse from body if scrolled to top
                                    if scrolledToTop && (dragOffset > threshold || velocity > 300) {
                                        cardExpanded = false
                                    }
                                } else {
                                    // Swipe up to expand (scroll is disabled when collapsed)
                                    if dragOffset < -threshold || velocity < -300 {
                                        cardExpanded = true
                                    }
                                }
                                dragOffset = 0
                            }
                        }
                )
            }
        }
    }
}

private func formattedBalance(_ value: Double, largeSize: CGFloat, smallSize: CGFloat) -> Text {
    let whole = Int(value)
    let cents = Int(round((value - Double(whole)) * 100))

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let wholeStr = formatter.string(from: NSNumber(value: whole)) ?? "\(whole)"
    let centsStr = String(format: "%02d", cents)

    return Text("$").font(.system(size: smallSize, weight: .bold))
        + Text("\(wholeStr).").font(.system(size: largeSize, weight: .bold))
        + Text(centsStr).font(.system(size: smallSize, weight: .bold))
}

#Preview {
    HomeView()
}
