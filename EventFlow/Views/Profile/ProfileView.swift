// ProfileView.swift
// EventFlow — Profile with real user data from AppStore

import SwiftUI

struct ProfileView: View {
    let onSignOut: () -> Void
    @EnvironmentObject private var store: AppStore
    @ObservedObject private var auth = BiometricAuthManager.shared
    @ObservedObject private var nm   = NotificationManager.shared
    @State private var showTestPanel = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

           
                    ZStack {
                        Text("Profile")
                            .font(.system(size: 18, weight: .semibold)).foregroundColor(Colors.textPrimary)
                        HStack {
                            Spacer()
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20)).foregroundColor(Colors.textPrimary)
                            }
                        }
                    }
                    .padding(.bottom, 28)

          
                    VStack(spacing: 14) {
                        ZStack(alignment: .bottomTrailing) {
                      
                            if !store.userAvatar.isEmpty, let url = URL(string: store.userAvatar) {
                                AsyncImage(url: url) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Circle().fill(Colors.bgSecondary)
                                        .overlay(
                                            Text(String(store.userName.prefix(1)).uppercased())
                                                .font(.system(size: 36, weight: .bold))
                                                .foregroundColor(Colors.accentTeal)
                                        )
                                }
                                .frame(width: 96, height: 96).clipShape(Circle())
                                .overlay(Circle().stroke(Colors.accentTeal, lineWidth: 3))
                            } else {
                             
                                Circle().fill(Colors.bgSecondary)
                                    .frame(width: 96, height: 96)
                                    .overlay(Circle().stroke(Colors.accentTeal, lineWidth: 3))
                                    .overlay(
                                        Text(String(store.userName.prefix(1)).uppercased())
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(Colors.accentTeal)
                                    )
                            }

                            ZStack {
                                Circle().fill(Colors.accentTeal)
                                    .frame(width: 28, height: 28)
                                    .overlay(Circle().stroke(.black, lineWidth: 2))
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 12)).foregroundColor(.black)
                            }
                        }

                       
                        Text(store.userName.isEmpty ? "User" : store.userName)
                            .font(.system(size: 22, weight: .bold)).foregroundColor(Colors.textPrimary)

            
                        Text(store.userEmail.isEmpty ? "No email" : store.userEmail)
                            .font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                    }
                    .padding(.bottom, 28)

                    HStack(spacing: 16) {
                        StatCard(value: "\(store.events.count)", label: "Events")
                        StatCard(value: "\(store.doneTasks)", label: "Done")
                        StatCard(value: "\(store.pendingTasks)", label: "Pending")
                    }
                    .padding(.bottom, 28)

           
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SECURITY & ACCESS")
                            .font(.system(size: 12)).kerning(1).foregroundColor(Colors.textSecondary)

                        VStack(spacing: 0) {

                            // Face ID / Touch ID Row
//                            HStack(spacing: 14) {
//                                Image(systemName: auth.biometricIcon)
//                                    .font(.system(size: 18)).foregroundColor(Colors.accentTeal)
//                                VStack(alignment: .leading, spacing: 2) {
//                                    Text(auth.biometricLabel)
//                                        .font(.system(size: 14, weight: .medium)).foregroundColor(Colors.textPrimary)
//                                    if auth.biometricType == .none {
//                                        Text("Not available on this device")
//                                            .font(.system(size: 11)).foregroundColor(Colors.textSecondary)
//                                    }
//                                }
//                                Spacer()
//                                Toggle(isOn: Binding(
//                                    get: { auth.isBiometricEnabled },
//                                    set: { newValue in
//                                        if newValue {
//                                            auth.authenticate(
//                                                reason: "Confirm your identity to enable \(auth.biometricLabel)"
//                                            ) { success in
//                                                if !success { auth.isBiometricEnabled = false }
//                                            }
//                                        } else {
//                                            auth.isBiometricEnabled = false
//                                        }
//                                    }
//                                )) { EmptyView() }
//                                .tint(Colors.accentTeal)
//                                .disabled(auth.biometricType == .none)
//                            }
//                            .padding(.vertical, 14)
                            Divider().background(Color(hex: "#2C2C2E"))

                         
                            Button {
                                if nm.permissionGranted {
                                    showTestPanel.toggle()
                                } else {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 18)).foregroundColor(Colors.accentTeal)
                                    Text("Push Notifications")
                                        .font(.system(size: 14, weight: .medium)).foregroundColor(Colors.textPrimary)
                                    Spacer()
                                    Text(nm.permissionGranted ? "On" : "On")
                                        .font(.system(size: 13))
                                        .foregroundColor(nm.permissionGranted ? Colors.accentTeal : Colors.textSecondary)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16)).foregroundColor(Color(hex: "#3A3A3C"))
                                }
                                .padding(.vertical, 14)
                            }
                            Divider().background(Color(hex: "#2C2C2E"))

                       
                            HStack(spacing: 14) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 18)).foregroundColor(Colors.accentTeal)
                                Text("Location Access")
                                    .font(.system(size: 14, weight: .medium)).foregroundColor(Colors.textPrimary)
                                Spacer()
                                Text("Always")
                                    .font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16)).foregroundColor(Color(hex: "#3A3A3C"))
                            }
                            .padding(.vertical, 14)
                        }
                        .padding(.horizontal, 16)
                        .background(Colors.bgSecondary)
                        .cornerRadius(20)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)

              
                    if showTestPanel {
                        NotificationTestPanel()
                            .padding(.bottom, 20)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                  
                    Button(action: onSignOut) {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right").foregroundColor(Colors.error)
                            Text("Sign Out").font(.system(size: 15, weight: .semibold)).foregroundColor(Colors.error)
                        }
                        .frame(maxWidth: .infinity).padding(16)
                        .background(Colors.error.opacity(0.1)).cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Colors.error.opacity(0.2), lineWidth: 1))
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .background(Colors.bgPrimary)
            .animation(.easeInOut, value: showTestPanel)
            .refreshable { await store.load() }
            .task {
          
                await store.load()
            }
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 22, weight: .bold)).foregroundColor(Colors.accentTeal)
            Text(label).font(.system(size: 10)).foregroundColor(Colors.textSecondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(16)
        .background(Colors.bgSecondary).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").font(.system(size: 22)).foregroundColor(.white)
                    }
                    Text("Settings").font(.system(size: 18, weight: .semibold)).foregroundColor(.white).padding(.leading, 8)
                    Spacer()
                    NavigationLink(destination: AlertsView()) {
                        Image(systemName: "bell").font(.system(size: 20)).foregroundColor(.white)
                    }
                }
                .padding(.bottom, 40)

                SettingsSectionHeader("PRIVACY")
                SettingsGroup {
                    SettingsRow(icon: "shield.fill",    label: "Data Sharing Permissions")
                    Divider().background(Color(hex: "#2C2C2E"))
                    SettingsRow(icon: "eye.slash.fill", label: "Invisible Mode")
                }
                .padding(.bottom, 32)

                SettingsSectionHeader("ACCOUNT")
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 20)).foregroundColor(Color(hex: "#E0E0E0")).padding(.top, 2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Email Address")
                                .font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "#E0E0E0"))
                            // Real email from store
                            Text(store.userEmail.isEmpty ? "No email set" : store.userEmail)
                                .font(.system(size: 13)).foregroundColor(Colors.textSecondary).padding(.bottom, 16)
                            Button { } label: {
                                Text("UPDATE EMAIL")
                                    .font(.system(size: 11, weight: .black)).kerning(0.5).foregroundColor(Colors.accentTeal)
                            }
                        }
                    }
                    .padding(20)
                }
                .background(Color(hex: "#1A1A1C")).cornerRadius(16).padding(.bottom, 32)

                SettingsSectionHeader("PREFERENCES")
                SettingsGroup {
                    SettingsRow(icon: "globe", label: "Language", value: "English (UK)")
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
    }
}

struct SettingsSectionHeader: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).font(.system(size: 13)).kerning(2).foregroundColor(Color(hex: "#E0E0E0")).padding(.bottom, 16)
    }
}

struct SettingsGroup<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(spacing: 0) { content }
            .padding(.horizontal, 16)
            .background(Color(hex: "#1A1A1C")).cornerRadius(16).padding(.bottom, 32)
    }
}

struct SettingsRow: View {
    let icon: String
    let label: String
    var value: String? = nil
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(Color(hex: "#E0E0E0"))
            Text(label).font(.system(size: 14)).foregroundColor(Color(hex: "#E0E0E0")).frame(maxWidth: .infinity, alignment: .leading)
            if let val = value { Text(val).font(.system(size: 13)).foregroundColor(Colors.textSecondary) }
            Image(systemName: "chevron.right").font(.system(size: 18)).foregroundColor(.white)
        }
        .padding(.vertical, 16)
    }
}
