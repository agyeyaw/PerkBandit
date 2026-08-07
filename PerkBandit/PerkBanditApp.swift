//
//  PerkBanditApp.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/26/26.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()

        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

enum AppScreen { case splash, onboarding, userOnboarding, auth, main }

@main
struct PerkBanditApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var cardStore = CardStore()
    @StateObject private var authManager = AuthManager()
    @State private var screen: AppScreen = .splash

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isLoading {
                    SplashScreenView { }
                } else if authManager.isSignedIn && hasCompletedOnboarding {
                    ContentView {
                        #if DEBUG
                        OnboardingPersistence.reset()
                        cardStore.reload()
                        #endif
                        hasCompletedOnboarding = false
                        screen = .splash
                    }
                    .environmentObject(cardStore)
                } else if hasCompletedOnboarding && !authManager.isSignedIn {
                    AuthView(initialLoginMode: true, onBack: { hasCompletedOnboarding = false }) { screen = .main }
                } else {
                    switch screen {
                    case .splash:
                        SplashScreenView { screen = .onboarding }
                    case .onboarding:
                        OnboardingView(onFinished: { screen = .userOnboarding },
                                       onLogin: { hasCompletedOnboarding = true })
                    case .userOnboarding:
                        UserOnboardingFlowView(onFinished: {
                            hasCompletedOnboarding = true
                            screen = .main
                        }, onBack: {
                            screen = .onboarding
                        })
                        .environmentObject(cardStore)
                    case .auth:
                        AuthView {
                            screen = .main
                        }
                    case .main:
                        ContentView { screen = .userOnboarding }
                            .environmentObject(cardStore)
                    }
                }
            }
            .environmentObject(authManager)
            .onChange(of: authManager.isSignedIn) { _, newValue in
                if !newValue {
                    hasCompletedOnboarding = false
                    screen = .splash
                }
            }
        }
    }
}
