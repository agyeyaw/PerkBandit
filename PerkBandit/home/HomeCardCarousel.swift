//
//  HomeCardCarousel.swift
//  PerkBandit
//

import SwiftUI

struct HomeCardCarousel: View {
    let cards: [MockCard]
    @Binding var selectedIndex: Int

    @State private var scrolledID: UUID?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var selectedCard: MockCard {
        cards[selectedIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Balance display
            VStack(spacing: 4) {
                Text("Card Balance")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                formattedBalance(selectedCard.balance, largeSize: 45, smallSize: 25)
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: selectedIndex)
            }
            .padding(.bottom, 2)

            // Card carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 32) {
                    ForEach(cards) { card in
                        GeometryReader { proxy in
                            let midX = proxy.frame(in: .global).midX
                            let screenMid = UIScreen.main.bounds.width / 2
                            let distance = abs(midX - screenMid)
                            let maxDistance: CGFloat = 300
                            let normalised = min(distance / maxDistance, 1)

                            let scale = reduceMotion ? 1.0 : 1.0 - (normalised * 0.15)
                            let opacity = reduceMotion ? 1.0 : 1.0 - (normalised * 0.3)

                            CreditCardVisual(card: card)
                                .rotation3DEffect(.degrees(65), axis: (x: 1, y: 0, z: 0), perspective: 0.5)
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .animation(
                                    reduceMotion ? .default : .spring(response: 0.3),
                                    value: normalised
                                )
                        }
                        .frame(width: 280, height: 200)
                        .id(card.id)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, (UIScreen.main.bounds.width - 280) / 2)
            }
            .padding(.top, -50)
            .padding(.bottom, -65)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledID)
            .onChange(of: scrolledID) { _, newID in
                if let newID, let index = cards.firstIndex(where: { $0.id == newID }) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedIndex = index
                    }
                }
            }
            .onAppear {
                scrolledID = cards[selectedIndex].id
            }

            // Page indicators
            HStack(spacing: 8) {
                ForEach(cards.indices, id: \.self) { index in
                    Circle()
                        .fill(.white.opacity(index == selectedIndex ? 1.0 : 0.4))
                        .frame(
                            width: index == selectedIndex ? 8 : 6,
                            height: index == selectedIndex ? 8 : 6
                        )
                        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                }
            }
            .padding(.top, 8)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                if selectedIndex < cards.count - 1 {
                    selectedIndex += 1
                    scrolledID = cards[selectedIndex].id
                }
            case .decrement:
                if selectedIndex > 0 {
                    selectedIndex -= 1
                    scrolledID = cards[selectedIndex].id
                }
            @unknown default:
                break
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
    ZStack {
        Color(red: 24/255, green: 32/255, blue: 51/255)
            .ignoresSafeArea()
        HomeCardCarousel(cards: MockCard.samples, selectedIndex: .constant(0))
    }
}
