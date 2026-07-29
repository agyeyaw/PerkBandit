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

    var body: some View {
        GeometryReader { geo in
            let restingY = geo.size.height * 0.50
            let expandedY: CGFloat = 100
            let baseOffset = cardExpanded ? expandedY : restingY
            let currentOffset = max(expandedY, baseOffset + dragOffset)

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

                // Credit card carousel
                VStack {
                    Spacer()
                    HomeCardCarousel(cards: mockCards, selectedIndex: $selectedCardIndex)
                }
                .frame(height: currentOffset - 40)

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

#Preview {
    HomeView()
}
