//
//  CardSubPageView.swift
//  PerkBandit
//

import SwiftUI

struct CardSubPageView: View {
    let title: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 202/255, green: 202/255, blue: 202/255)
                .ignoresSafeArea()

            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.black)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.black)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CardSubPageView(title: "Benefits")
    }
}
