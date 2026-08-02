//
//  PBTheme.swift
//  PerkBandit
//

import SwiftUI

enum PBTheme {
    static let background = Color(red: 16/255, green: 20/255, blue: 36/255)
    static let cardBackground = Color(red: 28/255, green: 34/255, blue: 55/255)
    static let accent = Color(red: 60/255, green: 120/255, blue: 255/255)
    static let positive = Color(red: 52/255, green: 199/255, blue: 89/255)
    static let negative = Color(red: 255/255, green: 149/255, blue: 0/255)
    static let subtitleGray = Color(red: 142/255, green: 142/255, blue: 147/255)
}

struct PBSectionCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(PBTheme.cardBackground)
            )
            .padding(.horizontal)
    }
}

struct PBBottomButton: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(PBTheme.accent))
                .foregroundStyle(.white)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct PBSubPageContainer<Content: View>: View {
    let title: String
    let content: Content
    @Environment(\.dismiss) private var dismiss

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack {
            PBTheme.background.ignoresSafeArea()
            content
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
                        .foregroundStyle(.white)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
    }
}
