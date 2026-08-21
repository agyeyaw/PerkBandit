//
//  NameEntryStepView.swift
//  PerkBandit
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct NameEntryStepView: View {
    @Binding var userName: String
    let onAdvance: () -> Void

    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("What's your name?")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer().frame(height: 12)

            Text("We'll use this to personalize your experience.")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer().frame(height: 40)

            TextField("Enter your name", text: $userName)
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal, 40)
                .focused($isNameFocused)
                .onChange(of: userName) { _, newValue in
                    let filtered = newValue.filter { $0.isLetter || $0 == " " || $0 == "'" || $0 == "-" || $0 == "\u{2019}" }
                    let capped = String(filtered.prefix(50))
                    if capped != newValue { userName = capped }
                }
                .submitLabel(.done)
                .onSubmit {
                    if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                        onAdvance()
                    }
                }

            Spacer()

            Button(action: onAdvance) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(userName.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : navyColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear { isNameFocused = true }
    }
}
