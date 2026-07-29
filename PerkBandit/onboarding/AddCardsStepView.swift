//
//  AddCardsStepView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct SetupMethodStepView: View {
    let onSelect: (SetupMethod) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("How would you like to start?")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("You can change this anytime.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .padding(.top, 4)

            Spacer().frame(height: 24)

            VStack(spacing: 12) {
                SetupOptionCard(
                    icon: "creditcard.fill",
                    title: "Add Cards Manually",
                    subtitle: "Search for the cards you already own.",
                    action: { onSelect(.manual) }
                )
                SetupOptionCard(
                    icon: "building.columns.fill",
                    title: "Connect Accounts",
                    subtitle: "Automatically sync supported institutions. Optional.",
                    action: { onSelect(.connect) }
                )
                SetupOptionCard(
                    icon: "safari.fill",
                    title: "Explore Demo",
                    subtitle: "Preview PerkBandit with sample cards.",
                    action: { onSelect(.demo) }
                )
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white.ignoresSafeArea())
    }
}

private struct SetupOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(navyColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(navyColor, lineWidth: 1.5)
            )
        }
    }
}
