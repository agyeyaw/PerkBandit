//
//  RequestCardSheet.swift
//  PerkBandit
//

import SwiftUI

struct RequestCardSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cardName = ""
    @State private var showConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What card are you looking for?")
                        .font(.system(size: 20, weight: .bold))
                    Text("We'll add it to our catalog as soon as possible.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                TextField("e.g. US Bank Altitude Go", text: $cardName)
                    .font(.system(size: 16))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                if showConfirmation {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Request submitted! We'll look into it.")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    Button {
                        submitRequest()
                    } label: {
                        Text("Submit Request")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(cardName.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.gray : Color(red: 24/255, green: 32/255, blue: 51/255))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(cardName.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("Request a Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func submitRequest() {
        let trimmed = cardName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        var existing = UserDefaults.standard.stringArray(forKey: "requestedCards") ?? []
        existing.append(trimmed)
        UserDefaults.standard.set(existing, forKey: "requestedCards")

        withAnimation {
            showConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}
