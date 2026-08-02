//
//  RecommendationPrefsStepView.swift
//  PerkBandit
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

private let recommendationOptions = [
    "Maximize cashback",
    "Maximize travel points",
    "Prioritize welcome bonuses",
    "Use credits before they expire",
    "Avoid cards with high balances",
    "Keep recommendations simple",
]

// Maps goal strings → recommendation pref to pre-select
private let goalToRecMapping: [String: String] = [
    "Earn more cashback": "Maximize cashback",
    "Maximize travel rewards": "Maximize travel points",
    "Complete welcome bonuses": "Prioritize welcome bonuses",
    "Track benefits": "Use credits before they expire",
]

struct RecommendationPrefsStepView: View {
    let selectedGoals: Set<String>
    @Binding var recommendationPrefs: Set<String>
    let onAdvance: () -> Void
    let onAdvanced: () -> Void

    @State private var hasAppliedDefaults = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("How should Scout choose your best card?")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Select as many as you'd like, or skip for now.")
                    .font(.system(size: 15)).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 12) {
                ForEach(recommendationOptions, id: \.self) { option in
                    prefChip(option)
                }
            }
            .padding(.horizontal, 20).padding(.top, 24)

            Spacer()

            // Advanced settings button
            Button(action: onAdvanced) {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 14))
                    Text("Advanced settings")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.secondary)
            }
            .padding(.bottom, 12)

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

            Button(action: onAdvance) {
                Text("Skip for now")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
        .onAppear {
            guard !hasAppliedDefaults else { return }
            hasAppliedDefaults = true
            for (goal, pref) in goalToRecMapping {
                if selectedGoals.contains(goal) {
                    recommendationPrefs.insert(pref)
                }
            }
        }
    }

    @ViewBuilder
    private func prefChip(_ option: String) -> some View {
        let selected = recommendationPrefs.contains(option)
        Button {
            if selected { recommendationPrefs.remove(option) } else { recommendationPrefs.insert(option) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(selected ? .white : navyColor)
                Text(option)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(selected ? .white : navyColor)
                Spacer()
            }
            .padding(.vertical, 12).padding(.horizontal, 14).frame(maxWidth: .infinity)
            .background(selected ? navyColor : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(navyColor, lineWidth: 1.5))
        }
    }
}
