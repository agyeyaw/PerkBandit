//
//  InsightTabView.swift
//  PerkBandit
//

import SwiftUI

struct InsightTabView: View {
    var onRestartOnboarding: () -> Void
    @EnvironmentObject private var authManager: AuthManager

    private let navy = Color(red: 24/255, green: 32/255, blue: 51/255)

    var body: some View {
        ZStack {
            navy.ignoresSafeArea()
            VStack {
                Spacer()
                Text("Insight")
                    .font(.title)
                    .foregroundColor(.white)
                Spacer()

                Button("Sign Out") {
                    authManager.signOut()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .padding(.bottom, 12)

                #if DEBUG
                Button("Restart Onboarding") {
                    onRestartOnboarding()
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .padding(.bottom, 40)
                #endif
            }
        }
    }
}

#Preview {
    InsightTabView(onRestartOnboarding: { })
        .environmentObject(AuthManager())
}
