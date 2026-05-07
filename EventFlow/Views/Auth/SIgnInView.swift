// SignInView.swift
import SwiftUI
import LocalAuthentication

struct SignInView: View {
    @EnvironmentObject private var store: AppStore
    @ObservedObject private var auth = BiometricAuthManager.shared

    @State private var email        = ""
    @State private var password     = ""
    @State private var showPassword = false
    @State private var showFaceID   = false
    @State private var faceIDEmail  = ""
    @State private var faceIDError  = ""
    @State private var showPermissionAlert = false

    var body: some View {
        if store.isLoggedIn {
            MainTabView(onSignOut: { store.signOut() })
        } else if showFaceID {
            faceIDPage
        } else {
            loginPage
        }
    }


    private var loginPage: some View {
        ZStack {
            Colors.bgPrimary.ignoresSafeArea()
            VStack(spacing: 0) {

                HStack {
                    Spacer()
                    Button("Sign Up") {}
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.blue)
                }
                .padding(.horizontal, 24).padding(.top, 20)

                Text("Log in")
                    .font(.system(size: 32, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24).padding(.top, 32).padding(.bottom, 28)

                VStack(alignment: .leading, spacing: 6) {
                    Text("EMAIL")
                        .font(.system(size: 11, weight: .bold)).kerning(1)
                        .foregroundColor(Colors.textSecondary)
                    HStack {
                        TextField("your@email.com", text: $email)
                            .foregroundColor(.white).font(.system(size: 15))
                            .keyboardType(.emailAddress).autocapitalization(.none)
                            .autocorrectionDisabled()
                        if !email.isEmpty {
                            Button { email = "" } label: {
                                Image(systemName: "xmark").font(.system(size: 12))
                                    .foregroundColor(Colors.textSecondary)
                            }
                        }
                    }
                    .padding(16).background(Color(hex: "#1C1C1E")).cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                .padding(.horizontal, 24).padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 6) {
                    Text("PASSWORD")
                        .font(.system(size: 11, weight: .bold)).kerning(1)
                        .foregroundColor(Colors.textSecondary)
                    HStack {
                        if showPassword {
                            TextField("Enter password", text: $password)
                                .foregroundColor(.white).font(.system(size: 15))
                                .autocapitalization(.none).autocorrectionDisabled()
                        } else {
                            SecureField("Enter password", text: $password)
                                .foregroundColor(.white).font(.system(size: 15))
                        }
                        Button { showPassword.toggle() } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .font(.system(size: 14)).foregroundColor(Colors.textSecondary)
                        }
                    }
                    .padding(16).background(Color(hex: "#1C1C1E")).cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                }
                .padding(.horizontal, 24).padding(.bottom, 20)

                if !store.authError.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 14)).foregroundColor(.red)
                        Text(store.authError).font(.system(size: 13)).foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.horizontal, 24).padding(.bottom, 12)
                }

            
                Button {
                    faceIDError = ""
                    faceIDEmail = email
                    showFaceID  = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
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
                    .background(Colors.accentTeal.opacity(0.1)).cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Colors.accentTeal.opacity(0.4), lineWidth: 1))
                }
                .padding(.horizontal, 24).padding(.bottom, 12)

                Button {
                    Task { await store.login(email: email, password: password) }
                } label: {
                    ZStack {
                        if store.isAuthLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("LOG IN").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(canLogin ? Color.blue : Color.blue.opacity(0.4)).cornerRadius(16)
                }
                .disabled(!canLogin || store.isAuthLoading)
                .padding(.horizontal, 24)

                HStack {
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                    Text("Or connect using social account")
                        .font(.system(size: 12)).foregroundColor(Colors.textSecondary).fixedSize()
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                }
                .padding(.horizontal, 24).padding(.vertical, 24)

                VStack(spacing: 12) {
                    socialButton(icon: "f.square.fill", color: Color(hex: "#1877F2"), label: "Connect with Facebook")
                    socialButton(icon: "phone.fill",   color: Color(hex: "#34A853"), label: "Connect with Phone number")
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    private var canLogin: Bool { !email.isEmpty && !password.isEmpty }



    private var faceIDPage: some View {
        ZStack {
            Colors.bgPrimary.ignoresSafeArea()
            VStack(spacing: 0) {

                HStack {
                    Button { showFaceID = false; faceIDError = "" } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
                    }
                    Spacer()
                    Button("Sign Up") {}
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.blue)
                }
                .padding(.horizontal, 24).padding(.top, 20)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Log in with \(auth.biometricLabel)")
                        .font(.system(size: 28, weight: .bold)).foregroundColor(.white)

                    if !faceIDEmail.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 12)).foregroundColor(Colors.accentTeal)
                            Text(faceIDEmail)
                                .font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                        }
                        .padding(.top, 4)
                    } else {
                        Text("Scan your face to sign in")
                            .font(.system(size: 15)).foregroundColor(Colors.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24).padding(.top, 40).padding(.bottom, 50)

                FaceIDIconView(isAuthenticating: auth.isAuthenticating)
                    .padding(.bottom, 40)

                if !faceIDError.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28)).foregroundColor(.red)
                        Text(faceIDError)
                            .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .background(Color.red.opacity(0.1)).cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, 40).padding(.bottom, 20)
                } else if !auth.authError.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28)).foregroundColor(.red)
                        Text("Face Not Recognised").font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                        Text("Try Again").font(.system(size: 14)).foregroundColor(Colors.textSecondary)
                    }
                    .padding(20)
                    .background(Color.red.opacity(0.1)).cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, 40).padding(.bottom, 20)
                }

                Spacer()

                if faceIDEmail.isEmpty {
                    Text("Tip: Enter your email on the login screen first for faster sign-in")
                        .font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40).padding(.bottom, 16)
                }

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
                    .background(Color.blue).cornerRadius(16)
                }
                .disabled(auth.isAuthenticating)
                .padding(.horizontal, 24).padding(.bottom, 12)

                Button { showFaceID = false; faceIDError = "" } label: {
                    Text("Maybe Later").font(.system(size: 14)).foregroundColor(Colors.textSecondary)
                }
                .padding(.bottom, 40)
            }
        }
        .alert("Allow EventFlow to use Face ID?", isPresented: $showPermissionAlert) {
            Button("OK") { triggerFaceID() }
            Button("Don't Allow", role: .cancel) { showFaceID = false }
        } message: {
            Text("This lets you use \(auth.biometricLabel) to log in to the app.")
        }
    }

  

    private func triggerFaceID() {
        faceIDError = ""
        auth.authenticate(reason: "Sign in to EventFlow") { success in
            guard success else { return }

           
            if !faceIDEmail.isEmpty {
                Task {
                    await store.loginWithFaceID(email: faceIDEmail)
                    if store.authError.isEmpty {
                        withAnimation { store.isLoggedIn = true }
                    } else {
                        faceIDError = store.authError
                    }
                }
            } else if !store.currentUserId.isEmpty {
            
                withAnimation { store.isLoggedIn = true }
                Task { await store.load() }
            } else {
          
                faceIDError = "Enter your email on the login screen, then try again."
            }
        }
    }

 
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



struct FaceIDIconView: View {
    let isAuthenticating: Bool
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.red.opacity(pulse ? 0.4 : 0.1), lineWidth: 2)
                .frame(width: pulse ? 140 : 110, height: pulse ? 140 : 110)
                .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: pulse)
            Circle().fill(Color(hex: "#1C1C1E")).frame(width: 100, height: 100)
                .shadow(color: .black.opacity(0.3), radius: 12)
            if isAuthenticating {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .red)).scaleEffect(1.5)
            } else {
                VStack(spacing: 6) {
                    HStack(spacing: 30) { faceCorner(); faceCorner() }
                    Spacer().frame(height: 20)
                    HStack(spacing: 30) { faceCorner(); faceCorner() }
                }
                .frame(width: 60, height: 60)
            }
        }
        .onAppear { pulse = true }
    }

    private func faceCorner() -> some View {
        RoundedRectangle(cornerRadius: 4).stroke(Color.red.opacity(0.8), lineWidth: 2)
            .frame(width: 16, height: 16)
    }
}
