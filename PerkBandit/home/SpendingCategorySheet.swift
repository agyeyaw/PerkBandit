//
//  SpendingCategorySheet.swift
//  PerkBandit
//

import SwiftUI

struct SpendingCategorySheet: View {
    @EnvironmentObject var cardStore: CardStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: SpendingCategory?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 245/255, green: 246/255, blue: 250/255)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Text("What are you buying?")
                            .font(.title2.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)

                        Text("Pick a category and we'll find your best card.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(SpendingCategory.allCases) { category in
                                Button {
                                    selectedCategory = category
                                } label: {
                                    VStack(spacing: 10) {
                                        Image(systemName: category.icon)
                                            .font(.title2)
                                            .foregroundStyle(PBTheme.accent)

                                        Text(category.label)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.primary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 90)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color(.systemBackground))
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationDestination(item: $selectedCategory) { category in
                BestCardResultView(category: category)
                    .environmentObject(cardStore)
            }
        }
    }
}
