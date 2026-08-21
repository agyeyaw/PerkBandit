//
//  AuthView.swift
//  PerkBandit
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authManager: AuthManager
    let initialLoginMode: Bool
    let onFinished: () -> Void
    let onBack: (() -> Void)?

    @State private var isLoginMode = false

    init(initialLoginMode: Bool = false, onBack: (() -> Void)? = nil, onFinished: @escaping () -> Void) {
        self.initialLoginMode = initialLoginMode
        self.onBack = onBack
        self.onFinished = onFinished
        self._isLoginMode = State(initialValue: initialLoginMode)
    }
    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false

    private let navyColor = Color(red: 24/255, green: 32/255, blue: 51/255)

    var body: some View {
        VStack(spacing: 0) {
            // Back button
            if let onBack {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(navyColor)
                            .frame(width: 36, height: 36)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }

            // Title
            Text(isLoginMode ? "Log in to your account" : "Create your account")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 28)

            // Email field
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            // Password field
            SecureField("Password", text: $password)
                .textContentType(isLoginMode ? .password : .newPassword)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 4)

            if !isLoginMode {
                Text("Password must be at least 6 characters")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
            }

            // Error message
            if let error = authManager.errorMessage {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            }

            Spacer().frame(height: 20)

            // Submit button
            Button {
                submit()
            } label: {
                Group {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isLoginMode ? "Log In" : "Create Account")
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(navyColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(isSubmitting || email.isEmpty || password.isEmpty)
            .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            if !initialLoginMode {
                // Toggle mode
                Button {
                    isLoginMode.toggle()
                    authManager.errorMessage = nil
                } label: {
                    Text(isLoginMode ? "Create an account" : "I already have an account")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(navyColor)
                }

                // Divider
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray4))
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Rectangle().frame(height: 1).foregroundColor(Color(.systemGray4))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

                // Continue with Google
                Button {
                    Task {
                        await authManager.signInWithGoogle()
                        if authManager.isSignedIn { onFinished() }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image("GoogleLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Continue with Google")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
            }

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func submit() {
        isSubmitting = true
        Task {
            if isLoginMode {
                await authManager.signIn(email: email, password: password)
            } else {
                await authManager.signUp(email: email, password: password)
            }
            isSubmitting = false
            if authManager.isSignedIn {
                onFinished()
            }
        }
    }
}

#Preview {
    AuthView(onFinished: { })
        .environmentObject(AuthManager())
}
