//
//  CardsTabView.swift
//  PerkBandit
//

import SwiftUI

struct CardsTabView: View {
    private let navy = Color(red: 24/255, green: 32/255, blue: 51/255)

    var body: some View {
        ZStack {
            navy.ignoresSafeArea()
            Text("Cards")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    CardsTabView()
}
