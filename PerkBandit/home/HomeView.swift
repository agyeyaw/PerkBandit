//
//  HomeView.swift
//  PerkBandit
//

import SwiftUI

struct HomeView: View {
    @State private var cardExpanded = false
    @State private var dragOffset: CGFloat = 0

    private let navy = Color(red: 24/255, green: 32/255, blue: 51/255)

    var body: some View {
        GeometryReader { geo in
            let restingY = geo.size.height * 0.50
            let expandedY: CGFloat = 100
            let baseOffset = cardExpanded ? expandedY : restingY
            let currentOffset = max(expandedY, baseOffset + dragOffset)

            ZStack(alignment: .top) {
                navy.ignoresSafeArea()

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
