//
//  LoginView.swift
//  PerkBandit
//
//  Created by Yaw Agyemang on 7/28/26.
//

import SwiftUI

private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

struct GoogleGIcon: View {
    let size: CGFloat

    var body: some View {
        Canvas { context, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            let cx = w / 2
            let cy = h / 2
            let r = min(w, h) / 2

            // Blue (left arc)
            var path = Path()
            path.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                        startAngle: .degrees(125), endAngle: .degrees(235), clockwise: false)
            path.addLine(to: CGPoint(x: cx, y: cy))
            path.closeSubpath()
            context.fill(path, with: .color(Color(red: 0.26, green: 0.52, blue: 0.96)))

            // Red (top arc)
            var path2 = Path()
            path2.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                         startAngle: .degrees(235), endAngle: .degrees(360), clockwise: false)
            path2.addLine(to: CGPoint(x: cx, y: cy))
            path2.closeSubpath()
            context.fill(path2, with: .color(Color(red: 0.92, green: 0.26, blue: 0.21)))

            // Yellow (right arc)
            var path3 = Path()
            path3.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                         startAngle: .degrees(0), endAngle: .degrees(55), clockwise: false)
            path3.addLine(to: CGPoint(x: cx, y: cy))
            path3.closeSubpath()
            context.fill(path3, with: .color(Color(red: 0.98, green: 0.74, blue: 0.02)))

            // Green (bottom-right arc)
            var path4 = Path()
            path4.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                         startAngle: .degrees(55), endAngle: .degrees(125), clockwise: false)
            path4.addLine(to: CGPoint(x: cx, y: cy))
            path4.closeSubpath()
            context.fill(path4, with: .color(Color(red: 0.20, green: 0.66, blue: 0.33)))

            // White center circle (G cutout)
            let innerR = r * 0.55
            var inner = Path()
            inner.addEllipse(in: CGRect(x: cx - innerR, y: cy - innerR,
                                        width: innerR * 2, height: innerR * 2))
            context.fill(inner, with: .color(.white))

            // White bar for the G crossbar
            let barHeight = r * 0.25
            let barLeft = cx
            let barRight = cx + r
            var bar = Path()
            bar.addRoundedRect(in: CGRect(x: barLeft, y: cy - barHeight / 2,
                                          width: barRight - barLeft, height: barHeight),
                               cornerSize: CGSize(width: barHeight / 2, height: barHeight / 2))
            context.fill(bar, with: .color(.white))
        }
        .frame(width: size, height: size)
    }
}

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    let onFinished: () -> Void

    @State private var email = ""

    var body: some View {
        VStack(spacing: 0) {
            // Logo
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding(.top, 48)
                .padding(.bottom, 20)

            // Title
            Text("Log in or sign up")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 28)

            // Email field
            ZStack(alignment: .trailing) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )

                if !email.isEmpty {
                    Button {
                        email = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .padding(.trailing, 12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 14)

            // Continue button
            Button {
                dismiss()
                onFinished()
            } label: {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(navyColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // "or" separator
            Text("or")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(.bottom, 20)

            // Continue with Google
            Button {
                dismiss()
                onFinished()
            } label: {
                HStack(spacing: 10) {
                    GoogleGIcon(size: 20)
                    Text("Continue with Google")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.black, lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            // Continue with Apple
            Button {
                dismiss()
                onFinished()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                    Text("Continue with Apple")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.black, lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }
}
