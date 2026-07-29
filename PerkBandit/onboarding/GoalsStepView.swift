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

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle().fill(Color(.systemGray6)).frame(width: 160, height: 160)
                Image(systemName: "target").font(.system(size: 80)).foregroundColor(navyColor)
            }
            Spacer()
            VStack(spacing: 8) {
                Text("What's your goal?")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center).padding(.horizontal, 24)
                Text("Tell Scout what matters most.")
                    .font(.system(size: 15)).foregroundColor(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 32)
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(goals, id: \.self) { goalChip($0) }
            }
            .padding(.horizontal, 20).padding(.top, 24)
            Spacer()
        }
    }

    @ViewBuilder
    private func goalChip(_ goal: String) -> some View {
        let selected = selectedGoals.contains(goal)
        Button {
            if selected { selectedGoals.remove(goal) } else { selectedGoals.insert(goal) }
        } label: {
            Text(goal)
                .font(.system(size: 14, weight: .medium)).multilineTextAlignment(.center)
                .padding(.vertical, 10).padding(.horizontal, 14).frame(maxWidth: .infinity)
                .background(selected ? navyColor : Color.white)
                .foregroundColor(selected ? .white : navyColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(navyColor, lineWidth: 1.5))
        }
    }
}
