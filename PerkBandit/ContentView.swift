//
//  ContentView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/26/26.
//

import SwiftUI

struct ContentView: View {
    let onBack: () -> Void

    @State private var selectedTab = 0
    private let navy = Color(red: 24/255, green: 32/255, blue: 51/255)

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(onViewCards: { selectedTab = 1 })
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            CardsTabView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Cards")
                }
                .tag(1)

            InsightTabView(onRestartOnboarding: onBack)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Insight")
                }
                .tag(2)

            AskTabView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Ask")
                }
                .tag(3)
        }
        .tint(navy)
    }
}

#Preview {
    ContentView { }
        .environmentObject(CardStore())
}
