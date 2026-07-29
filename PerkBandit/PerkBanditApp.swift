//
//  PerkBanditApp.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/26/26.
//

import SwiftUI

enum AppScreen { case splash, onboarding, userOnboarding, main }

@main
struct PerkBanditApp: App {
    @State private var screen: AppScreen = .splash

    var body: some Scene {
        WindowGroup {
            switch screen {
            case .splash:
                SplashScreenView { screen = .onboarding }
            case .onboarding:
                OnboardingView { screen = .userOnboarding }
            case .userOnboarding:
                UserOnboardingFlowView { screen = .main }
            case .main:
                ContentView { screen = .userOnboarding }
            }
        }
    }
}
