//
//  NotificationsView.swift
//  PerkBandit
//

import SwiftUI

struct NotificationsView: View {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var isDismissing = false

    private let dismissThreshold: CGFloat = 150

    private let notifications: [(icon: String, color: Color, title: String, subtitle: String, time: String)] = [
        ("creditcard", .orange, "Amex Gold 4x At Restaurants", "Use your Amex Gold card for dining today to maximize rewards.", "2m ago"),
        ("clock", Color(red: 24/255, green: 32/255, blue: 51/255), "Uber Cash Expiring Tomorrow", "You have $10 in Uber Cash that expires tomorrow. Use it or lose it!", "1h ago"),
        ("star.fill", .yellow, "New Reward Unlocked", "You've earned a $5 statement credit on your Chase Sapphire.", "3h ago"),
        ("exclamationmark.triangle", .red, "Payment Due Soon", "Your Citi Double Cash payment of $142.30 is due in 3 days.", "5h ago"),
        ("gift.fill", .purple, "Limited Time Offer", "Get 5x points on travel purchases with your Amex Platinum through August.", "1d ago"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Text("Notifications")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(notifications.enumerated()), id: \.offset) { _, item in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: item.icon)
                                        .font(.body)
                                        .foregroundStyle(.white)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                                    .lineLimit(2)
                            }

                            Spacer()

                            Text(item.time)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 24/255, green: 32/255, blue: 51/255).ignoresSafeArea())
        .offset(y: isDismissing ? dragOffset : max(0, dragOffset))
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDismissing {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if !isDismissing && (dragOffset > dismissThreshold || value.predictedEndTranslation.height > 300) {
                        dismiss()
                    } else if !isDismissing {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }

    private func dismiss() {
        isDismissing = true
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            dragOffset = -UIScreen.main.bounds.height
        } completion: {
            isPresented = false
        }
    }
}
