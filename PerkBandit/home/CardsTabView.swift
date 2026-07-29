//
//  CardsTabView.swift
//  PerkBandit
//

import SwiftUI

struct CardsTabView: View {
    @State private var selectedIndex: Int = 0
    private let cards = MockCard.samples

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 202/255, green: 202/255, blue: 202/255)
                .ignoresSafeArea()

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

                Spacer()

                // Stacked card fan
                ZStack {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        let n = cards.count
                        let rawOffset = index - selectedIndex
                        let circularOffset: Int = {
                            var o = rawOffset % n
                            if o > n / 2 { o -= n }
                            if o < -(n / 2) { o += n }
                            return o
                        }()
                        let absOffset = abs(circularOffset)
                        let scale = absOffset == 0 ? 0.95 : max(0.65, 0.95 - Double(absOffset) * 0.07)
                        let yOffset: CGFloat = absOffset == 0 ? 0 : CGFloat(circularOffset) * (absOffset == 1 ? 40 : 30 + CGFloat(absOffset) * 5)

                        CreditCardVisual(card: card)
                            .frame(width: 340)
                            .scaleEffect(scale)
                            .offset(y: yOffset)
                            .zIndex(Double(cards.count - absOffset))
                            .shadow(color: .black.opacity(absOffset == 0 ? 0.3 : 0.1), radius: absOffset == 0 ? 12 : 4, y: absOffset == 0 ? 6 : 2)
                            .onTapGesture {
                                guard index != selectedIndex else { return }
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                    selectedIndex = index
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer()
            }
        }
    }
}

#Preview {
    CardsTabView()
}
