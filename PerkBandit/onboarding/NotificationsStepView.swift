//
//  NotificationsStepView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import SwiftUI
import UserNotifications

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct NotificationsStepView: View {
    let onAdvance: (Bool) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle().fill(Color(.systemGray6)).frame(width: 100, height: 100)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 48))
                    .foregroundColor(navyColor)
            }

            Spacer().frame(height: 24)

            Text("Stay One Step Ahead")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer().frame(height: 12)

            Text("Scout can remind you before valuable opportunities expire.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer().frame(height: 28)

            VStack(spacing: 0) {
                NotificationExampleRow(icon: "calendar.badge.exclamationmark", label: "Expiring credits")
                Divider().padding(.leading, 52)
                NotificationExampleRow(icon: "flag.checkered", label: "Welcome-bonus deadlines")
                Divider().padding(.leading, 52)
                NotificationExampleRow(icon: "star.fill", label: "High-value card recommendations")
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.systemGray4), lineWidth: 1))
            .padding(.horizontal, 20)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async { onAdvance(granted) }
                    }
                } label: {
                    Text("Enable Notifications")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(navyColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button { onAdvance(false) } label: {
                    Text("Not Now")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

private struct NotificationExampleRow: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(navyColor)
                .frame(width: 28)
            Text(label)
                .font(.system(size: 15))
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
    }
}
