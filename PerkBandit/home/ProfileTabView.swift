//
//  ProfileTabView.swift
//  PerkBandit
//

import SwiftUI

struct ProfileTabView: View {
    private let navy = Color(red: 24/255, green: 32/255, blue: 51/255)

    var body: some View {
        ZStack {
            navy.ignoresSafeArea()
            Text("Profile")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ProfileTabView()
}
