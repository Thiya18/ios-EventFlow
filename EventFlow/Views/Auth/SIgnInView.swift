//
//  SIgnInView.swift
//  EventFlow
//
//  Created by Thiya on 2026-04-15.
//



import SwiftUI

struct SignInView: View {
    @State private var mode: AuthMode = .signIn

    enum AuthMode { case signIn, signUp }

    var body: some View {
        ZStack {
            Colors.bgPrimary.ignoresSafeArea()
            if mode == .signIn {
                LoginForm(onSwitchToSignUp: { mode = .signUp })
            } else {
                SignUpForm(onSwitchToSignIn: { mode = .signIn })
            }
        }
    }
}

#Preview {
    SignInView()
}
struct LoginForm: View {
    let onSwitchToSignUp: () -> Void

    @State private var email    = ""
    @State private var password = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

    
                VStack(spacing: 8) {
                    HStack(spacing: 0) {
                        Text("Event").foregroundColor(Colors.textPrimary)
                        Text("Flow").foregroundColor(Colors.accentTeal)
                    }
                    .font(.system(size: 36, weight: .black))
                    .kerning(-0.5)

                    Text("Welcome back")
                        .font(.system(size: 15))
                        .foregroundColor(Colors.textSecondary)
                }
                .padding(.top, 64)
                .padding(.bottom, 48)

              
                ZStack {
                    Circle()
                        .fill(Colors.accentTeal.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Colors.accentTeal)
                }
                .padding(.bottom, 40)

           
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EMAIL")
                            .font(.system(size: 11, weight: .semibold))
                            .kerning(1)
                            .foregroundColor(Colors.textSecondary)
                        TextField("your@email.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Colors.bgSecondary)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Colors.accentTeal.opacity(email.isEmpty ? 0 : 0.4), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PASSWORD")
                            .font(.system(size: 11, weight: .semibold))
                            .kerning(1)
                            .foregroundColor(Colors.textSecondary)
                        SecureField("Enter password", text: $password)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Colors.bgSecondary)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Colors.accentTeal.opacity(password.isEmpty ? 0 : 0.4), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

      
                Button {
                   
                } label: {
                    ZStack {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(email.isEmpty || password.isEmpty
                                ? Colors.accentTeal.opacity(0.4)
                                : Colors.accentTeal)
                    .cornerRadius(16)
                }
                .disabled(email.isEmpty || password.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)


                HStack(spacing: 16) {
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                    Text("OR").font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)


                Button(action: onSwitchToSignUp) {
                    VStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(Colors.textSecondary)
                        Text("Create Account")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Colors.accentTeal)
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    LoginForm(onSwitchToSignUp: {})
        .background(Colors.bgPrimary)
}

struct SignUpForm: View {
    let onSwitchToSignIn: () -> Void

    @State private var name     = ""
    @State private var email    = ""
    @State private var password = ""
    @State private var confirm  = ""

    private var passwordMismatch: Bool {
        !confirm.isEmpty && password != confirm
    }

    private var canSubmit: Bool {
        !name.isEmpty && !email.isEmpty &&
        password.count >= 6 && password == confirm
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {


                VStack(spacing: 8) {
                    HStack(spacing: 0) {
                        Text("Event").foregroundColor(Colors.textPrimary)
                        Text("Flow").foregroundColor(Colors.accentTeal)
                    }
                    .font(.system(size: 36, weight: .black))
                    .kerning(-0.5)

                    Text("Create your account")
                        .font(.system(size: 15))
                        .foregroundColor(Colors.textSecondary)
                }
                .padding(.top, 64)
                .padding(.bottom, 40)


                VStack(spacing: 16) {

    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FULL NAME")
                            .font(.system(size: 11, weight: .semibold)).kerning(1)
                            .foregroundColor(Colors.textSecondary)
                        TextField("Your name", text: $name)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Colors.bgSecondary)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Colors.accentTeal.opacity(name.isEmpty ? 0 : 0.4), lineWidth: 1))
                    }


                    VStack(alignment: .leading, spacing: 8) {
                        Text("EMAIL")
                            .font(.system(size: 11, weight: .semibold)).kerning(1)
                            .foregroundColor(Colors.textSecondary)
                        TextField("your@email.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Colors.bgSecondary)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Colors.accentTeal.opacity(email.isEmpty ? 0 : 0.4), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PASSWORD")
                            .font(.system(size: 11, weight: .semibold)).kerning(1)
                            .foregroundColor(Colors.textSecondary)
                        SecureField("Min 6 characters", text: $password)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Colors.bgSecondary)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Colors.accentTeal.opacity(password.isEmpty ? 0 : 0.4), lineWidth: 1))
                    }


                    VStack(alignment: .leading, spacing: 8) {
                        Text("CONFIRM PASSWORD")
                            .font(.system(size: 11, weight: .semibold)).kerning(1)
                            .foregroundColor(Colors.textSecondary)
                        SecureField("Repeat password", text: $confirm)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Colors.bgSecondary)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(passwordMismatch ? Colors.error.opacity(0.6) :
                                        Colors.accentTeal.opacity(confirm.isEmpty ? 0 : 0.4),
                                        lineWidth: 1))
                        if passwordMismatch {
                            Text("Passwords don't match")
                                .font(.system(size: 12))
                                .foregroundColor(Colors.error)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)


                Button {
    
                } label: {
                    ZStack {
                        Text("Create Account")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(canSubmit ? Colors.accentTeal : Colors.accentTeal.opacity(0.4))
                    .cornerRadius(16)
                }
                .disabled(!canSubmit)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)


                Button(action: onSwitchToSignIn) {
                    VStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(Colors.textSecondary)
                        Text("Sign In")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Colors.accentTeal)
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }
}
