//
//  UserOnboardingFlowView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct UserOnboardingFlowView: View {
    let onFinished: () -> Void

    @StateObject private var state = OnboardingState()
    @State private var stepStack: [UserOnboardingStep] = [.scoutIntro]

    private var currentStep: UserOnboardingStep { stepStack.last! }

    private var progressIndex: Int {
        switch currentStep {
        case .scoutIntro: return 0
        case .goals: return 1
        case .setupMethod, .manualCards, .connectAccounts, .demo: return 2
        case .notifications: return 3
        case .completion: return 4
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top nav bar
            HStack {
                Button(action: goBack) {
                    ZStack {
                        Circle().fill(Color(.systemGray6)).frame(width: 40, height: 40)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                .opacity(stepStack.count <= 1 ? 0 : 1)
                .disabled(stepStack.count <= 1)

                Spacer()

                // 5 progress dots
                HStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { i in
                        if i == progressIndex {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(navyColor)
                                .frame(width: 24, height: 8)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.35))
                                .frame(width: 8, height: 8)
                        }
                    }
                }

                Spacer()

                // Balance spacer matching back button width
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 8)

            // Step content
            currentStepView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.white.ignoresSafeArea())
    }

    @ViewBuilder
    private var currentStepView: some View {
        switch currentStep {
        case .scoutIntro:
            ScoutStepView(onAdvance: { advance(to: .goals) })

        case .goals:
            GoalsStepView(
                selectedGoals: $state.selectedGoals,
                onAdvance: { advance(to: .setupMethod) }
            )

        case .setupMethod:
            SetupMethodStepView(onSelect: { method in
                state.setupMethod = method
                switch method {
                case .manual: advance(to: .manualCards)
                case .connect: advance(to: .connectAccounts)
                case .demo: advance(to: .demo)
                }
            })

        case .manualCards:
            ManualCardSetupView(
                selectedCards: $state.selectedCards,
                onAdvance: { advance(to: .notifications) }
            )

        case .connectAccounts:
            ConnectAccountsView(onAdvance: { advance(to: .notifications) })

        case .demo:
            DemoPortfolioView(
                onAdvance: {
                    state.isDemoMode = true
                    advance(to: .notifications)
                },
                onChooseAnother: {
                    // Pop back to setupMethod, removing any branch screens on top
                    if let idx = stepStack.lastIndex(of: .setupMethod) {
                        withAnimation { stepStack = Array(stepStack.prefix(through: idx)) }
                    } else {
                        goBack()
                    }
                }
            )

        case .notifications:
            NotificationsStepView(onAdvance: { granted in
                state.notificationsEnabled = granted
                advance(to: .completion)
            })

        case .completion:
            CompletionStepView(onAdvance: {
                OnboardingPersistence.markCompleted()
                onFinished()
            })
        }
    }

    private func advance(to step: UserOnboardingStep) {
        withAnimation { stepStack.append(step) }
    }

    private func goBack() {
        guard stepStack.count > 1 else { return }
        withAnimation { stepStack.removeLast() }
    }
}
