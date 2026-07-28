//
//  OnboardingView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/26/26.
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct OnboardingPage {
    let imageName: String
    let title: String
    let description: String
}

private let pages: [OnboardingPage] = [
    OnboardingPage(
        imageName: "AppLogo",
        title: "Welcome To PerkBandit",
        description: "Never Miss Another Reward, Credit, Or Perk. Scout Helps You Uncover The Hidden Value In Every Card."
    ),
    OnboardingPage(
        imageName: "AppLogo",
        title: "Track Every Perk",
        description: "Keep tabs on all your credit card benefits in one place. Never let a perk go unused again."
    ),
    OnboardingPage(
        imageName: "AppLogo",
        title: "Get Personalized Tips",
        description: "Scout analyzes your spending and suggests the best cards for every purchase you make."
    ),
]

struct OnboardingView: View {
    let onFinished: () -> Void

    @State private var currentPage = 0
    @State private var agreedToTerms = false

    var body: some View {
        VStack(spacing: 0) {
            // Swipeable area
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { i in
                    VStack(spacing: 16) {
                        Spacer()
                        Image(pages[i].imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
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
                    Circle()
                        .fill(i == currentPage ? navyColor : Color.gray.opacity(0.35))
                        .frame(
                            width: i == currentPage ? 8 : 6,
                            height: i == currentPage ? 8 : 6
                        )
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
                    onFinished()
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
    }
}
