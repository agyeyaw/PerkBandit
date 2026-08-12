//
//  CardsStepView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)
private let issuerFilters = ["All", "Chase", "Amex", "Capital One", "Citi", "Discover", "Wells Fargo", "Bank of America"]

struct ManualCardSetupView: View {
    @Binding var selectedCards: [String]
    var alreadyOwnedCards: Set<String> = []
    let onAdvance: () -> Void

    @State private var searchText = ""
    @State private var selectedIssuer = "All"
    @State private var showRequestSheet = false

    private var filteredCards: [CreditCard] {
        cardCatalog.filter { card in
            let matchesIssuer = selectedIssuer == "All" || card.issuer == selectedIssuer
            let matchesSearch = searchText.isEmpty ||
                card.name.localizedCaseInsensitiveContains(searchText) ||
                card.issuer.localizedCaseInsensitiveContains(searchText)
            return matchesIssuer && matchesSearch
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Which cards do you own?")
                    .font(.system(size: 24, weight: .bold))
                Text("Select all that apply.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)

            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Search cards", text: $searchText)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Issuer filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(issuerFilters, id: \.self) { issuer in
                        Button {
                            selectedIssuer = issuer
                        } label: {
                            Text(issuer)
                                .font(.system(size: 13, weight: .medium))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 14)
                                .background(selectedIssuer == issuer ? navyColor : Color(.systemGray6))
                                .foregroundColor(selectedIssuer == issuer ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }

            // Selected count badge
            if !selectedCards.isEmpty {
                Text("\(selectedCards.count) selected")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(navyColor)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(navyColor.opacity(0.1))
                    .clipShape(Capsule())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }

            // Card list
            List(filteredCards) { card in
                Button {
                    if !alreadyOwnedCards.contains(card.id) {
                        if selectedCards.contains(card.id) {
                            selectedCards.removeAll { $0 == card.id }
                        } else {
                            selectedCards.append(card.id)
                        }
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            Text(alreadyOwnedCards.contains(card.id) ? "\(card.issuer) · Already added" : card.issuer)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: selectedCards.contains(card.id) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundColor(selectedCards.contains(card.id) ? navyColor : .secondary)
                    }
                    .opacity(alreadyOwnedCards.contains(card.id) ? 0.5 : 1.0)
                }
                .listRowBackground(Color.white)
            }
            .listStyle(.plain)

            // Don't see your card?
            Button {
                showRequestSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 14))
                    Text("Don't see your card?")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(navyColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)

            // CTAs
            VStack(spacing: 10) {
                Button(action: onAdvance) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(navyColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button(action: onAdvance) {
                    Text("Skip for now")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showRequestSheet) {
            RequestCardSheet()
        }
    }
}
