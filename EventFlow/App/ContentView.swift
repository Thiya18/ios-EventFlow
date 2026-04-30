// ContentView.swift  (UPDATED — BiometricLockGate overlay)
// EventFlow — Root View Controller
// Drop into: EventFlow/App/ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @ObservedObject private var auth = BiometricAuthManager.shared
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView(onExplore: { /* handle sign out */ })
          
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                SignInView()
                    .transition(.opacity)
            }

            // Biometric lock gate — overlays everything when app is locked
            BiometricLockGate()
                .animation(.easeInOut(duration: 0.3), value: auth.isLocked)
        }
    }
}
