//
//  AccountSetupViews.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

// MARK: - ConnectAccountsView (Screen 12B)

struct ConnectAccountsView: View {
    let onAdvance: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Connect Accounts")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal, 20)

            Text("Connecting accounts is optional. You can continue with manual tracking.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)
                .padding(.top, 16)

            VStack(spacing: 0) {
                InstitutionRow(name: "Chase", logo: "building.columns.fill")
                Divider().padding(.leading, 60)
                InstitutionRow(name: "American Express", logo: "creditcard.fill")
                Divider().padding(.leading, 60)
                InstitutionRow(name: "Capital One", logo: "banknote.fill")
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 1))
            .padding(.horizontal, 20)
            .padding(.top, 24)

            Spacer()

            Button(action: onAdvance) {
                Text("Set Up Later")
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
        .padding(.top, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white.ignoresSafeArea())
    }
}

private struct InstitutionRow: View {
    let name: String
    let logo: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: logo)
                .font(.system(size: 20))
                .foregroundColor(navyColor)
                .frame(width: 36)
            Text(name)
                .font(.system(size: 15, weight: .medium))
            Spacer()
            Button("Connect") {}
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(navyColor)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(navyColor, lineWidth: 1.5))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}

// MARK: - DemoPortfolioView (Screen 12C)

struct DemoPortfolioView: View {
    let onAdvance: () -> Void
    let onChooseAnother: () -> Void

    private let demoCards = [
        "[Demo] Chase Sapphire Reserve",
        "[Demo] Amex Platinum",
        "[Demo] Citi Double Cash",
        "[Demo] Capital One Venture",
    ]

    private let demoOpportunities = [
        "Earn 3x on dining this month",
        "Activate your $300 travel credit",
        "Bonus points on streaming services",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // DEMO badge banner
                Text("DEMO")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.yellow)

                VStack(alignment: .leading, spacing: 24) {
                    Text("Demo Portfolio")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cards")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        ForEach(demoCards, id: \.self) { card in
                            HStack {
                                Image(systemName: "creditcard.fill").foregroundColor(navyColor)
                                Text(card).font(.system(size: 15))
                            }
                            .padding(.vertical, 10).padding(.horizontal, 14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Opportunities")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        ForEach(demoOpportunities, id: \.self) { opp in
                            HStack {
                                Image(systemName: "star.fill").foregroundColor(.yellow)
                                Text(opp).font(.system(size: 15))
                            }
                            .padding(.vertical, 10).padding(.horizontal, 14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    VStack(spacing: 12) {
                        Button(action: onAdvance) {
                            Text("Use Demo Portfolio")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(navyColor)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Button(action: onChooseAnother) {
                            Text("Choose Another Setup Method")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}
