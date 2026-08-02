//
//  ContentView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/26/26.
//

import SwiftUI

struct ContentView: View {
    let onBack: () -> Void

    private let navy = Color(red: 24/255, green: 32/255, blue: 51/255)

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            CardsTabView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Cards")
                }

            InsightTabView(onRestartOnboarding: onBack)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Insight")
                }

            AskTabView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Ask")
                }
        }
        .tint(navy)
    }
}

#Preview {
    ContentView { }
}
