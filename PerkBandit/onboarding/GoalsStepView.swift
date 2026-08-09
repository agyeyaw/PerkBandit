//
//  GoalsStepView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)
private let goals = [
    "Earn more cashback", "Maximize travel rewards", "Track benefits",
    "Complete welcome bonuses", "Decide which cards to keep",
]

struct GoalsStepView: View {
    @Binding var selectedGoals: Set<String>
    let onAdvance: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What brings you to PerkBandit?")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Tell PerkBandit what matters most.")
                    .font(.system(size: 15)).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 12) {
                ForEach(goals, id: \.self) { goalChip($0) }
            }
            .padding(.horizontal, 20).padding(.top, 24)

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
            .disabled(selectedGoals.isEmpty)
            .opacity(selectedGoals.isEmpty ? 0.4 : 1)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private func goalChip(_ goal: String) -> some View {
        let selected = selectedGoals.contains(goal)
        Button {
            if selected { selectedGoals.remove(goal) } else { selectedGoals.insert(goal) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(selected ? .white : navyColor)
                Text(goal)
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
