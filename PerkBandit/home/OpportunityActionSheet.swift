//
//  OpportunityActionSheet.swift
//  PerkBandit
//

import SwiftUI

struct OpportunityActionSheet: View {
    let opportunity: Opportunity
    @EnvironmentObject var cardStore: CardStore
    @Environment(\.dismiss) private var dismiss
    @State private var spendInput: String = ""

    private var cardDef: CreditCard? {
        guard let defID = opportunity.cardDefinitionID else { return nil }
        return catalogCard(for: defID)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 16)

            // Header: card swatch + title
            HStack(spacing: 14) {
                if let def = cardDef {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [def.gradientStart.color, def.gradientEnd.color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 36)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(opportunity.title)
                        .font(.subheadline.weight(.bold))
                        .lineLimit(2)
                    Text(opportunity.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            Divider()

            // Explanation
            Text(opportunity.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)

            // Type-specific content
            switch opportunity.type {
            case .expiringBenefit:
                expiringBenefitContent
            case .categoryActivation:
                categoryActivationContent
            case .welcomeBonus:
                welcomeBonusContent
            case .annualFeeReview:
                annualFeeContent
            case .needsConfirmation:
                needsConfirmationContent
            case .cardRecommendation:
                EmptyView()
            }

            Spacer()
        }
        .presentationDetents([.medium])
    }

    // MARK: - Expiring Benefit

    private var expiringBenefitContent: some View {
        VStack(spacing: 16) {
            if let value = opportunity.estimatedValue {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("$\(NSDecimalNumber(decimal: value).intValue) credit expiring")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            }

            if let date = opportunity.expirationDate {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                    Text("Expires \(date, style: .date)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            }

            Button {
                if let ucID = opportunity.userCardID, let bID = opportunity.benefitID {
                    cardStore.markBenefitUsed(userCardID: ucID, benefitID: bID)
                }
                dismiss()
            } label: {
                Text("Mark as Used")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(PBTheme.accent))
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Category Activation

    private var categoryActivationContent: some View {
        VStack(spacing: 16) {
            if let def = cardDef, let activation = def.activationRequired {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.circle.fill")
                        .foregroundStyle(.blue)
                    Text(activation)
                        .font(.subheadline.weight(.medium))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            }

            Button {
                if let ucID = opportunity.userCardID {
                    cardStore.markCategoryActivated(userCardID: ucID)
                }
                dismiss()
            } label: {
                Text("Mark Activated")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(PBTheme.accent))
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Welcome Bonus

    private var welcomeBonusContent: some View {
        VStack(spacing: 16) {
            // Progress bar
            if let progress = opportunity.progress {
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            Capsule()
                                .fill(PBTheme.accent)
                                .frame(width: geo.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(progress * 100))% complete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
            }

            // Current/target from the user card
            if let ucID = opportunity.userCardID,
               let userCard = cardStore.cards.first(where: { $0.id == ucID }),
               let bonus = userCard.welcomeBonus,
               let target = bonus.targetSpend {
                let current = bonus.currentSpend ?? 0
                HStack {
                    Text("$\(Int(current)) of $\(Int(target))")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("$\(Int(target - current)) remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
            }

            // Spend input
            HStack(spacing: 12) {
                Text("$")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                TextField("New total spend", text: $spendInput)
                    .keyboardType(.decimalPad)
                    .font(.title3)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal, 20)

            Button {
                if let ucID = opportunity.userCardID,
                   let amount = Double(spendInput) {
                    cardStore.updateBonusSpend(userCardID: ucID, currentSpend: amount)
                }
                dismiss()
            } label: {
                Text("Update Spend")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(PBTheme.accent))
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Annual Fee Review

    private var annualFeeContent: some View {
        VStack(spacing: 16) {
            if let value = opportunity.estimatedValue {
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(.orange)
                    Text("$\(NSDecimalNumber(decimal: value).intValue) annual fee")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            }

            if let date = opportunity.expirationDate {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                    Text("Renews \(date, style: .date)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            }

            Button {
                dismiss()
            } label: {
                Text("Dismiss")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color(.systemGray3)))
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Needs Confirmation

    private var needsConfirmationContent: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(.orange)
                Text("Confirm whether you've used this benefit")
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)

            HStack(spacing: 12) {
                Button {
                    if let ucID = opportunity.userCardID, let bID = opportunity.benefitID {
                        cardStore.markBenefitUsed(userCardID: ucID, benefitID: bID)
                    }
                    dismiss()
                } label: {
                    Text("Yes, Used")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(PBTheme.accent))
                }

                Button {
                    if let ucID = opportunity.userCardID, let bID = opportunity.benefitID {
                        cardStore.toggleBenefitStatus(userCardID: ucID, benefitID: bID)
                    }
                    dismiss()
                } label: {
                    Text("Not Used")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color(.systemGray5)))
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
