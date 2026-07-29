//
//  CardsTabView.swift
//  PerkBandit
//

import SwiftUI

struct CardsTabView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 202/255, green: 202/255, blue: 202/255)
                .ignoresSafeArea()

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Manage")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.black)
                    Text("Your Cards")
                        .font(.system(size: 37, weight: .light))
                        .foregroundStyle(.gray)
                }

                Spacer()

                VStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white, .black)
                    Text("Add Card")
                        .font(.caption)
                        .foregroundStyle(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
}

#Preview {
    CardsTabView()
}
