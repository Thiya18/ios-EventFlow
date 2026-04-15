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

