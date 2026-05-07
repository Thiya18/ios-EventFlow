// BiometricAuthManager.swift
// EventFlow — Face ID / Touch ID Authentication

import LocalAuthentication
import SwiftUI
internal import Combine

final class BiometricAuthManager: ObservableObject {

    static let shared = BiometricAuthManager()

    @Published var isBiometricEnabled: Bool {
        didSet { UserDefaults.standard.set(isBiometricEnabled, forKey: "biometricEnabled") }
    }

    @Published var isLocked: Bool = false
    @Published var authError: String = ""
    @Published var isAuthenticating: Bool = false

    var biometricType: LABiometryType {
        let ctx = LAContext()
        _ = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return ctx.biometryType
    }

    var biometricLabel: String {
        switch biometricType {
        case .faceID:   return "Face ID"
        case .touchID:  return "Touch ID"
        case .opticID:  return "Optic ID"
        default:        return "Biometrics"
        }
    }

    var biometricIcon: String {
        switch biometricType {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        default:       return "lock.shield"
        }
    }

    private init() {
        isBiometricEnabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
    }

    func lock() {
        guard isBiometricEnabled else { return }
        DispatchQueue.main.async { self.isLocked = true }
    }

    func unlockIfNeeded() {
        guard isLocked, isBiometricEnabled else { return }
        authenticate(reason: "Unlock EventFlow")
    }

    func authenticate(reason: String = "Authenticate to continue",
                      completion: ((Bool) -> Void)? = nil) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            DispatchQueue.main.async {
                self.authError = error?.localizedDescription ?? "Biometrics not available on this device."
                completion?(false)
            }
            return
        }

        DispatchQueue.main.async { self.isAuthenticating = true }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        ) { success, evalError in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                if success {
                    self.isLocked  = false
                    self.authError = ""
                    completion?(true)
                } else {
                    let msg = evalError?.localizedDescription ?? "Authentication failed."
                    self.authError = msg
                    completion?(false)
                }
            }
        }
    }

    func toggleBiometric(completion: @escaping (Bool) -> Void) {
        if isBiometricEnabled {
            isBiometricEnabled = false
            completion(true)
        } else {
            authenticate(reason: "Enable \(biometricLabel) for EventFlow") { [weak self] success in
                if success { self?.isBiometricEnabled = true }
                completion(success)
            }
        }
    }
}

struct BiometricLockGate: View {
    @ObservedObject private var auth = BiometricAuthManager.shared

    var body: some View {
        if auth.isLocked {
            ZStack {
                Color.black.opacity(0.92).ignoresSafeArea()

                VStack(spacing: 32) {
                    ZStack {
                        Circle()
                            .fill(Colors.accentTeal.opacity(0.15))
                            .frame(width: 110, height: 110)
                        Image(systemName: auth.biometricIcon)
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(Colors.accentTeal)
                    }

                    VStack(spacing: 8) {
                        Text("EventFlow Locked")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("Use \(auth.biometricLabel) to unlock")
                            .font(.system(size: 15))
                            .foregroundColor(Colors.textSecondary)
                    }

                    if !auth.authError.isEmpty {
                        Text(auth.authError)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    Button {
                        BiometricAuthManager.shared.authenticate(reason: "Unlock EventFlow")
                    } label: {
                        HStack(spacing: 10) {
                            if auth.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: auth.biometricIcon)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            Text(auth.isAuthenticating ? "Authenticating…" : "Unlock with \(auth.biometricLabel)")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Colors.accentTeal)
                        .cornerRadius(16)
                    }
                    .disabled(auth.isAuthenticating)
                    .padding(.horizontal, 40)
                }
            }
            .transition(.opacity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    BiometricAuthManager.shared.authenticate(reason: "Unlock EventFlow")
                }
            }
        }
    }
}

struct FaceIDLoginView: View {
    @ObservedObject private var auth = BiometricAuthManager.shared
    var onSuccess: () -> Void

    @State private var animating = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("Log in to EventFlow")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text("Allow Sign In With \(auth.biometricLabel)?")
                    .font(.system(size: 15))
                    .foregroundColor(Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 60)

            ZStack {
                Circle()
                    .stroke(Colors.accentTeal.opacity(animating ? 0.5 : 0.15), lineWidth: 2)
                    .frame(width: animating ? 130 : 110, height: animating ? 130 : 110)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animating)

                Circle()
                    .fill(Colors.accentTeal.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: auth.biometricIcon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(Colors.accentTeal)
            }
            .onAppear { animating = true }
            .padding(.bottom, 60)

            if !auth.authError.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Face Not Recognised")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Try Again")
                            .font(.system(size: 12))
                            .foregroundColor(Colors.textSecondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color.red.opacity(0.12))
                .cornerRadius(14)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }

            Spacer()

            Button {
                auth.authenticate(reason: "Sign in to EventFlow") { success in
                    if success { onSuccess() }
                }
            } label: {
                ZStack {
                    if auth.isAuthenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: auth.biometricIcon)
                                .font(.system(size: 16, weight: .semibold))
                            Text("USE \(auth.biometricLabel.uppercased())")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Colors.accentTeal)
                .cornerRadius(16)
            }
            .disabled(auth.isAuthenticating)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)

            if !auth.authError.isEmpty {
                Button {
                    auth.authenticate(reason: "Sign in to EventFlow") { success in
                        if success { onSuccess() }
                    }
                } label: {
                    Text("TRY AGAIN")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Colors.accentTeal)
                }
                .padding(.bottom, 8)
            }

            Button {
            } label: {
                Text("Maybe Later")
                    .font(.system(size: 14))
                    .foregroundColor(Colors.textSecondary)
            }
            .padding(.bottom, 40)
        }
        .background(Colors.bgPrimary.ignoresSafeArea())
    }
}
