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
        case .nameEntry: return 1
        case .goals: return 2
        case .setupMethod, .manualCards, .confirmCards, .connectAccounts, .demo: return 3
        case .welcomeBonus, .benefitStatus: return 4
        case .recommendationPrefs, .pointValuation: return 5
        case .notifications: return 6
        case .dataConfidence, .firstValue: return 7
        case .completion: return 8
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
                    ForEach(0..<9, id: \.self) { i in
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
            ScoutStepView(onAdvance: { advance(to: .nameEntry) })

        case .nameEntry:
            NameEntryStepView(
                userName: $state.userName,
                onAdvance: { advance(to: .goals) }
            )

        case .goals:
            GoalsStepView(
                selectedGoals: $state.selectedGoals,
                onAdvance: { advance(to: .setupMethod) }
            )

        case .setupMethod:
            ManualExplanationStepView(
                onContinueManually: {
                    state.setupMethod = .manual
                    advance(to: .manualCards)
                },
                onConnectAccount: {
                    state.setupMethod = .connect
                    advance(to: .connectAccounts)
                },
                onExploreSample: {
                    state.setupMethod = .demo
                    advance(to: .demo)
                }
            )

        case .manualCards:
            ManualCardSetupView(
                selectedCards: $state.selectedCards,
                onAdvance: {
                    if !state.selectedCards.isEmpty {
                        advance(to: .confirmCards)
                    } else {
                        advance(to: .notifications)
                    }
                }
            )

        case .confirmCards:
            ConfirmCardsStepView(
                selectedCards: $state.selectedCards,
                onAdvance: { advanceAfterCardSetup() },
                onAddMore: { goBack() }
            )

        case .connectAccounts:
            ConnectAccountsView(onAdvance: { advance(to: .benefitStatus) })

        case .demo:
            DemoPortfolioView(
                onAdvance: {
                    state.isDemoMode = true
                    advance(to: .notifications)
                },
                onChooseAnother: {
                    if let idx = stepStack.lastIndex(of: .setupMethod) {
                        withAnimation { stepStack = Array(stepStack.prefix(through: idx)) }
                    } else {
                        goBack()
                    }
                }
            )

        case .welcomeBonus:
            WelcomeBonusStepView(
                selectedCards: $state.selectedCards,
                cardBonusStatuses: $state.cardBonusStatuses,
                cardBonusDetails: $state.cardBonusDetails,
                onAdvance: { advance(to: .benefitStatus) }
            )

        case .benefitStatus:
            BenefitStatusStepView(
                setupMethod: state.setupMethod,
                benefitStatuses: $state.benefitStatuses,
                onAdvance: { advance(to: .recommendationPrefs) }
            )

        case .recommendationPrefs:
            RecommendationPrefsStepView(
                selectedGoals: state.selectedGoals,
                recommendationPrefs: $state.recommendationPrefs,
                onAdvance: { advance(to: .notifications) },
                onAdvanced: { advance(to: .pointValuation) }
            )

        case .pointValuation:
            PointValuationStepView(
                pointValuation: $state.pointValuation,
                onAdvance: { advance(to: .notifications) }
            )

        case .notifications:
            NotificationsStepView(onAdvance: { granted in
                state.notificationsEnabled = granted
                advance(to: .dataConfidence)
            })

        case .dataConfidence:
            DataConfidenceStepView(onAdvance: {
                advance(to: .firstValue)
            })

        case .firstValue:
            FirstValuePreviewStepView(
                selectedCards: state.selectedCards,
                setupMethod: state.setupMethod,
                onAdvance: { advance(to: .completion) }
            )

        case .completion:
            CompletionStepView(onAdvance: {
                OnboardingPersistence.markCompleted()
                onFinished()
            })
        }
    }

    private func advanceAfterCardSetup() {
        if state.selectedGoals.contains("Complete welcome bonuses") {
            advance(to: .welcomeBonus)
        } else {
            advance(to: .benefitStatus)
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
