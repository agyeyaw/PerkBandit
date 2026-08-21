//
//  OnboardingView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/26/26.
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct OnboardingPage {
    let title: String
    let description: String
}

private let pages: [OnboardingPage] = [
    OnboardingPage(
        title: "Welcome to PerkBandit",
        description: "Never miss another reward, credit, or perk. PerkBandit helps you uncover the hidden value in every card."
    ),
    OnboardingPage(
        title: "Never miss another credit",
        description: "PerkBandit keeps track of every benefit so you don't leave money on the table."
    ),
    OnboardingPage(
        title: "Always know the best card to use",
        description: "Earn more points, cashback, and perks with every purchase."
    ),
    OnboardingPage(
        title: "PerkBandit tells you what to do— not just what you own",
        description: "Get simple, personalized recommendations based on your cards, spending, and available benefits."
    ),
    OnboardingPage(
        title: "See how much value you've earned",
        description: "Track the rewards, credit, and savings you've unlocked with PerkBandit."
    ),
    OnboardingPage(
        title: "Your Data, Your Control",
        description: "Start manually today and connect accounts whenever you're ready."
    ),
]

struct OnboardingView: View {
    let onFinished: () -> Void
    var onLogin: (() -> Void)?

    @EnvironmentObject var authManager: AuthManager
    @State private var currentPage = 0
    @State private var agreedToTerms = false
    @State private var showLoginSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Swipeable area
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { i in
                    VStack(spacing: 16) {
                        Spacer()
                        Text(pages[i].title)
                            .font(.system(size: 22, weight: .bold))
                            .multilineTextAlignment(.center)
                        Text(pages[i].description)
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                        Spacer().frame(height: 4)
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)

            // Page dots — separate row, naturally below all page content
            HStack(spacing: 6) {
                ForEach(pages.indices, id: \.self) { i in
                    if i == currentPage {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(navyColor)
                            .frame(width: 24, height: 8)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.35))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .padding(.vertical, 12)

            // Fixed bottom
            VStack(spacing: 12) {
                // Terms checkbox row
                HStack(spacing: 10) {
                    Button {
                        agreedToTerms.toggle()
                    } label: {
                        Circle()
                            .strokeBorder(navyColor, lineWidth: 1.5)
                            .background(
                                Circle().fill(agreedToTerms ? navyColor : Color.clear)
                            )
                            .frame(width: 22, height: 22)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(agreedToTerms ? 1 : 0)
                            )
                    }
                    (Text("I Agree To The ") + Text("Terms Of Service").bold())
                        .font(.system(size: 14))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Get Started button
                Button {
                    onFinished()
                } label: {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(navyColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // I Already Have An Account button
                Button {
                    showLoginSheet = true
                } label: {
                    Text("I Already Have An Account")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 10)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showLoginSheet) {
            VStack(spacing: 16) {
                Text("Welcome back")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.top, 28)

                // Continue with Google
                Button {
                    Task {
                        await authManager.signInWithGoogle()
                        if authManager.isSignedIn {
                            showLoginSheet = false
                            onLogin?()
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image("GoogleLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Continue with Google")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)

                // Continue with Email
                Button {
                    showLoginSheet = false
                    onLogin?()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope")
                            .font(.system(size: 16))
                        Text("Continue with Email")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .background(Color.white)
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
        }
    }
}
