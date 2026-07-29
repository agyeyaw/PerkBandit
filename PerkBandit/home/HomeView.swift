//
//  HomeView.swift
//  PerkBandit
//

import SwiftUI

struct HomeView: View {
    @State private var cardExpanded = false
    @State private var dragOffset: CGFloat = 0
    @State private var selectedCardIndex = 0

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

                    Spacer()
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
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.height
                        }
                        .onEnded { value in
                            let velocity = value.predictedEndTranslation.height - value.translation.height
                            let threshold: CGFloat = 100

                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                if cardExpanded {
                                    // Swipe down to collapse
                                    if dragOffset > threshold || velocity > 300 {
                                        cardExpanded = false
                                    }
                                } else {
                                    // Swipe up to expand
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
