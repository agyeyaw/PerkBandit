//
//  DataConfidenceStepView.swift
//  PerkBandit
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct DataConfidenceStepView: View {
    let onAdvance: () -> Void

    private let statusLabels: [(icon: String, title: String, description: String)] = [
        ("checkmark.seal.fill", "Verified", "Automatically confirmed"),
        ("hand.raised.fill", "Manually tracked", "Information provided by you"),
        ("chart.line.uptrend.xyaxis", "Estimated", "Calculated from available data"),
        ("exclamationmark.triangle.fill", "Needs confirmation", "Scout needs your help"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Scout always shows what it knows")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer().frame(height: 24)

            VStack(spacing: 10) {
                ForEach(statusLabels, id: \.title) { item in
                    HStack(spacing: 14) {
                        Image(systemName: item.icon)
                            .font(.system(size: 18))
                            .foregroundColor(navyColor)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.system(size: 15, weight: .semibold))
                            Text(item.description)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer().frame(height: 20)

            Text("You'll always see where financial information came from and when it was last updated.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button(action: onAdvance) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(navyColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white.ignoresSafeArea())
    }
}
