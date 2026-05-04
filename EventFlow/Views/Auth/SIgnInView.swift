// SignInView.swift  (UPDATED — real Face ID via LocalAuthentication)
// EventFlow — Sign In with Face ID
// Drop into: EventFlow/Views/Auth/SignInView.swift

import SwiftUI
import LocalAuthentication

struct SignInView: View {
    @EnvironmentObject private var store: AppStore
    @ObservedObject private var auth = BiometricAuthManager.shared

    @State private var email      = ""
    @State private var showFaceID = false
    @State private var isSignedIn = false

    var body: some View {
        if isSignedIn {
            MainTabView(onSignOut: { /* handle sign out */ })
        } else if showFaceID {
            faceIDPage
        } else {
            loginPage
        }
    }

    // MARK: - Login page (with Face ID option)

    private var loginPage: some View {
        ZStack {
            Colors.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back + Sign Up nav
                HStack {
                    Button { showFaceID = false } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button("Sign Up") {}
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Log in").font(.system(size: 32, weight: .bold)).foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24).padding(.top, 32).padding(.bottom, 28)

                // Email field
                VStack(alignment: .leading, spacing: 6) {
                    Text("EMAIL").font(.system(size: 11, weight: .bold)).kerning(1).foregroundColor(Colors.textSecondary)
                    HStack {
                        TextField("your@email.com", text: $email)
                            .foregroundColor(.white).font(.system(size: 15))
                            .keyboardType(.emailAddress).autocapitalization(.none)
                        if !email.isEmpty {
                            Button { email = "" } label: {
                                Image(systemName: "xmark").font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "#1C1C1E"))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                .padding(.horizontal, 24).padding(.bottom, 20)

                // ── Face ID quick login ──────────────────────────────────
                Button {
                    showFaceID = true
                    // Auto-trigger Face ID after navigation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        triggerFaceID()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: auth.biometricIcon)
                            .font(.system(size: 18, weight: .semibold))
                        Text("Log in with \(auth.biometricLabel)")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(Colors.accentTeal)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(Colors.accentTeal.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Colors.accentTeal.opacity(0.4), lineWidth: 1))
                }
                .padding(.horizontal, 24).padding(.bottom, 12)

                // Standard login
                Button {
                    isSignedIn = true
                } label: {
                    Text("LOG IN")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(Color.blue)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)

                // Divider
                HStack {
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                    Text("Or connect using social account").font(.system(size: 12)).foregroundColor(Colors.textSecondary).fixedSize()
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                }
                .padding(.horizontal, 24).padding(.vertical, 24)

                // Social login options
                VStack(spacing: 12) {
                    socialButton(icon: "f.square.fill", color: Color(hex: "#1877F2"), label: "Connect with Facebook")
                    socialButton(icon: "phone.fill", color: Color(hex: "#34A853"), label: "Connect with Phone number")
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    // MARK: - Face ID page

    private var faceIDPage: some View {
        ZStack {
            Colors.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back + Sign Up
                HStack {
                    Button { showFaceID = false } label: {
                        Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
                    }
                    Spacer()
                    Button("Sign Up") {}.font(.system(size: 15, weight: .semibold)) .foregroundColor(.blue)
                }
                .padding(.horizontal, 24).padding(.top, 20)

                // Title
                VStack(alignment: .leading, spacing: 6) {
                    Text("Log in to \(auth.biometricLabel)")
                        .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                    Text("Allow Sign In With \(auth.biometricLabel)?")
                        .font(.system(size: 15)).foregroundColor(Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24).padding(.top, 40).padding(.bottom, 50)

                // Animated Face ID icon
                FaceIDIconView(isAuthenticating: auth.isAuthenticating)
                    .padding(.bottom, 50)

                // Error message
                if !auth.authError.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28)).foregroundColor(.red)
                        Text("Face Not Recognised")
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                        Text("Try Again")
                            .font(.system(size: 14)).foregroundColor(Colors.textSecondary)
                    }
                    .padding(20)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, 40).padding(.bottom, 20)
                }

                Spacer()

                // USE FACE ID
                Button(action: triggerFaceID) {
                    ZStack {
                        if auth.isAuthenticating {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("USE \(auth.biometricLabel.uppercased())")
                                .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
                .disabled(auth.isAuthenticating)
                .padding(.horizontal, 24).padding(.bottom, 12)

                Button { showFaceID = false } label: {
                    Text("Maybe Later").font(.system(size: 14)).foregroundColor(Colors.textSecondary)
                }
                .padding(.bottom, 12)

                Text("We'll require face recognition after 2 minutes of inactivity.\nYou can change the frequency in app settings.")
                    .font(.system(size: 11)).foregroundColor(Colors.textSecondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40).padding(.bottom, 40)
            }
        }
        // System Face ID permission dialog — shown automatically when we call evaluate
        .alert("Allow EventFlow to use Face ID?", isPresented: $showPermissionAlert) {
            Button("OK") { triggerFaceID() }
            Button("Don't Allow", role: .cancel) { showFaceID = false }
        } message: {
            Text("This lets you use \(auth.biometricLabel) to log in to the app.")
        }
    }

    @State private var showPermissionAlert = false

    private func triggerFaceID() {
        auth.authenticate(reason: "Sign in to EventFlow") { success in
            if success {
                withAnimation { isSignedIn = true }
            }
        }
    }

    // MARK: - Social button helper

    private func socialButton(icon: String, color: Color, label: String) -> some View {
        Button {} label: {
            HStack(spacing: 12) {
                Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
                Text(label).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color(hex: "#1C1C1E")).cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }
}

// MARK: - Face ID Animated Icon

struct FaceIDIconView: View {
    let isAuthenticating: Bool
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.red.opacity(pulse ? 0.4 : 0.1), lineWidth: 2)
                .frame(width: pulse ? 140 : 110, height: pulse ? 140 : 110)
                .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: pulse)

            Circle()
                .fill(Color(hex: "#1C1C1E"))
                .frame(width: 100, height: 100)
                .shadow(color: .black.opacity(0.3), radius: 12)

            if isAuthenticating {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                    .scaleEffect(1.5)
            } else {
                // Face ID scan lines (simplified SVG-style)
                VStack(spacing: 6) {
                    HStack(spacing: 30) {
                        faceCorner(corners: [.topLeft])
                        faceCorner(corners: [.topRight])
                    }
                    Spacer().frame(height: 20)
                    HStack(spacing: 30) {
                        faceCorner(corners: [.bottomLeft])
                        faceCorner(corners: [.bottomRight])
                    }
                }
                .frame(width: 60, height: 60)
            }
        }
        .onAppear { pulse = true }
    }

    private func faceCorner(corners: UIRectCorner) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.red.opacity(0.8), lineWidth: 2)
                .frame(width: 16, height: 16)
        }
    }
}
