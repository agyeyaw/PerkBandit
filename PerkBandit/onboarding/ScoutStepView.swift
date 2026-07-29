//
//  ScoutStepView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import SwiftUI

struct ScoutStepView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle().fill(Color(.systemGray6)).frame(width: 160, height: 160)
                Image("AppLogo").resizable().scaledToFit().frame(width: 120, height: 120)
            }
            Spacer()
            VStack(spacing: 8) {
                Text("Meet Scout, your copilot")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center).padding(.horizontal, 24)
                Text("Scout gives you simple, personalized guidance — backed by data, not guesswork.")
                    .font(.system(size: 15)).foregroundColor(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 32)
            }
            Spacer()
        }
    }
}
