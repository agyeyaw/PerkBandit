//
//  PointValuationStepView.swift
//  PerkBandit
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

private let valuationOptions: [(label: String, value: String, description: String)] = [
    ("Use PerkBandit estimates", "perkbandit", "We calculate point values based on real redemption data."),
    ("Use simple cashback value", "cashback", "1 point = 1 cent. Straightforward and easy to compare."),
    ("Customize values later", "custom", "Set your own valuations per program in settings."),
]

struct PointValuationStepView: View {
    @Binding var pointValuation: String
    let onAdvance: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("How should Scout value your points?")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("This affects how Scout compares card rewards.")
                    .font(.system(size: 15)).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            VStack(spacing: 12) {
                ForEach(valuationOptions, id: \.value) { option in
                    valuationCard(option)
                }
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
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private func valuationCard(_ option: (label: String, value: String, description: String)) -> some View {
        let selected = pointValuation == option.value
        Button {
            pointValuation = option.value
        } label: {
            HStack(spacing: 14) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(selected ? navyColor : Color(.systemGray3))

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.label)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    Text(option.description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(selected ? navyColor : Color(.systemGray4), lineWidth: selected ? 2 : 1)
            )
        }
    }
}
