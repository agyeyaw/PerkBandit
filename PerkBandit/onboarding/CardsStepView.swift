//
//  CardsStepView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct CardsStepView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle().fill(Color(.systemGray6)).frame(width: 160, height: 160)
                Image(systemName: "creditcard.fill").font(.system(size: 80)).foregroundColor(navyColor)
            }
            Spacer()
            VStack(spacing: 8) {
                Text("Build your card portfolio")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center).padding(.horizontal, 24)
                Text("Add cards manually — no bank linking needed.")
                    .font(.system(size: 15)).foregroundColor(.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 32)
            }
            Spacer()
        }
    }
}
