// ContentView.swift
// EventFlow — Root View Controller

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @ObservedObject private var auth = BiometricAuthManager.shared
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView(onExplore: { })
                    .transition(.opacity)
                    .onAppear {
                
                        Task { await store.load() }

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

            BiometricLockGate()
                .animation(.easeInOut(duration: 0.3), value: auth.isLocked)
        }
    }
}
