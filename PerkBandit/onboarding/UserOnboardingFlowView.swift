//
//  UserOnboardingFlowView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import SwiftUI
import UserNotifications

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)
private let ctaLabels = ["Next", "Next", "Enable notifications", "Start exploring"]

enum UserOnboardingStepType: CaseIterable {
    case goals, cards, notifications, scout
}

struct UserOnboardingFlowView: View {
    let onFinished: () -> Void

    @State private var currentStep = 0
    @State private var selectedGoals: Set<String> = []

    private var isLastStep: Bool { currentStep == UserOnboardingStepType.allCases.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            // Top nav bar
            HStack {
                Button { withAnimation { currentStep -= 1 } } label: {
                    ZStack {
                        Circle().fill(Color(.systemGray6)).frame(width: 40, height: 40)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.primary)
                    }
                }
                .opacity(currentStep == 0 ? 0 : 1).disabled(currentStep == 0)

                Spacer()

                HStack(spacing: 6) {
                    ForEach(0..<UserOnboardingStepType.allCases.count, id: \.self) { i in
                        if i == currentStep {
                            RoundedRectangle(cornerRadius: 4).fill(navyColor).frame(width: 24, height: 8)
                        } else {
                            Circle().fill(Color.gray.opacity(0.35)).frame(width: 8, height: 8)
                        }
                    }
                }

                Spacer()

                Button("Skip") { onFinished() }
                    .font(.system(size: 15, weight: .medium)).foregroundColor(.secondary)
                    .opacity(isLastStep ? 0 : 1).disabled(isLastStep)
            }
            .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 8)

            // Step content
            ZStack {
                GoalsStepView(selectedGoals: $selectedGoals).opacity(currentStep == 0 ? 1 : 0)
                CardsStepView().opacity(currentStep == 1 ? 1 : 0)
                NotificationsStepView().opacity(currentStep == 2 ? 1 : 0)
                ScoutStepView().opacity(currentStep == 3 ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // CTA button
            Button { handleCTA() } label: {
                Text(ctaLabels[currentStep])
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(navyColor).foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20).padding(.bottom, 20)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func handleCTA() {
        let step = UserOnboardingStepType.allCases[currentStep]
        switch step {
        case .goals, .cards:
            withAnimation { currentStep += 1 }
        case .notifications:
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                DispatchQueue.main.async { withAnimation { currentStep += 1 } }
            }
        case .scout:
            onFinished()
        }
    }
}
