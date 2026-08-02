//
//  InsightTabView.swift
//  PerkBandit
//

import SwiftUI

struct InsightTabView: View {
    var onRestartOnboarding: () -> Void

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
}
