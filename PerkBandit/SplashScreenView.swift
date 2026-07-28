//
//  SplashScreenView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/26/26.
//

import SwiftUI

struct SplashScreenView: View {
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Color(red: 24/255, green: 32/255, blue: 51/255)
                .ignoresSafeArea()
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.4)) {
                    onFinished()
                }
            }
        }
    }
}
