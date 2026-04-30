// EventFlowApp.swift  (UPDATED — background lock hooks)
// EventFlow — App Entry Point
// Drop into: EventFlow/App/EventFlowApp.swift

import SwiftUI
import UserNotifications

@main
struct EventFlowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - AppDelegate (background / foreground lifecycle)

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Request notification permission
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        return true
    }

    // ── Lock when going to background ─────────────────────────────────────
    func applicationDidEnterBackground(_ application: UIApplication) {
        BiometricAuthManager.shared.lock()
    }

    // ── Unlock when coming back to foreground ─────────────────────────────
    func applicationWillEnterForeground(_ application: UIApplication) {
        BiometricAuthManager.shared.unlockIfNeeded()
    }

    // Show notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
