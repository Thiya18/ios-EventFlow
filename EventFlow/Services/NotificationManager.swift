// NotificationManager.swift
// EventFlow — Local Push Notification Manager (Full Implementation)

import UIKit
import UserNotifications
import SwiftUI
import CoreLocation
internal import Combine


final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    @Published var permissionGranted: Bool = false
    @Published var pendingCount: Int = 0

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        refreshPendingCount()
    }


    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
                if granted {
                    print("[Notifications] ✅ Permission granted")
                    UIApplication.shared.registerForRemoteNotifications()
                } else if let error {
                    print("[Notifications] ❌ Permission denied: \(error.localizedDescription)")
                }
            }
        }
    }

    func refreshPendingCount() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async { self.pendingCount = requests.count }
        }
    }

    func scheduleTaskReminder(taskId: String, text: String, dueDate: Date) {
        let center = UNUserNotificationCenter.current()
        let offsets: [(label: String, seconds: TimeInterval, title: String)] = [
            ("24h", -86_400, "📅 Task Due Tomorrow"),
            ("1h",  -3_600,  "⏰ Task Due in 1 Hour"),
        ]
        for offset in offsets {
            let fireDate = dueDate.addingTimeInterval(offset.seconds)
            guard fireDate > Date() else { continue }
            let content        = UNMutableNotificationContent()
            content.title      = offset.title
            content.body       = text
            content.sound      = .default
            content.badge      = 1
            content.userInfo   = ["taskId": taskId, "type": "task_reminder"]
            let comps   = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(
                identifier: "task_\(taskId)_\(offset.label)",
                content: content,
                trigger: trigger)
            center.add(request) { [weak self] error in
                if let error {
                    print("[Notifications] ❌ Task schedule failed (\(offset.label)): \(error)")
                } else {
                    print("[Notifications] 🔔 Task reminder (\(offset.label)) scheduled for '\(text)'")
                    self?.refreshPendingCount()
                }
            }
        }
    }

    func cancelTaskReminder(taskId: String) {
        let ids = ["task_\(taskId)_24h", "task_\(taskId)_1h"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        refreshPendingCount()
    }

    func scheduleEventReminder(eventId: String, title: String, location: String, startDate: Date) {
        let center = UNUserNotificationCenter.current()
        let offsets: [(label: String, seconds: TimeInterval, notifTitle: String)] = [
            ("24h", -86_400, "📅 Event Tomorrow"),
            ("1h",  -3_600,  "🗓 Event Starting in 1 Hour"),
        ]
        for offset in offsets {
            let fireDate = startDate.addingTimeInterval(offset.seconds)
            guard fireDate > Date() else { continue }
            let content       = UNMutableNotificationContent()
            content.title     = offset.notifTitle
            content.body      = location.isEmpty
                ? "\"\(title)\" starts \(offset.label == "1h" ? "in 1 hour" : "tomorrow")."
                : "\"\(title)\" starts \(offset.label == "1h" ? "in 1 hour" : "tomorrow") at \(location)."
            content.sound     = .default
            content.badge     = 1
            content.userInfo  = ["eventId": eventId, "type": "event_reminder"]
            let comps   = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(
                identifier: "event_\(eventId)_\(offset.label)",
                content: content,
                trigger: trigger)
            center.add(request) { [weak self] error in
                if let error {
                    print("[Notifications] ❌ Event schedule failed (\(offset.label)): \(error)")
                } else {
                    print("[Notifications] 🗓 Event reminder (\(offset.label)) scheduled for '\(title)'")
                    self?.refreshPendingCount()
                }
            }
        }
    }

    func cancelEventReminder(eventId: String) {
        let ids = ["event_\(eventId)_24h", "event_\(eventId)_1h"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        refreshPendingCount()
    }

    func scheduleImmediate(
        title: String,
        body: String,
        userInfo: [String: String] = [:],
        delay: TimeInterval = 3
    ) {
        let content         = UNMutableNotificationContent()
        content.title       = title
        content.body        = body
        content.sound       = .default
        content.badge       = 1
        content.userInfo    = userInfo
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(
            identifier: "immediate_\(UUID().uuidString)",
            content: content,
            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error { print("[Notifications] ❌ Immediate notification failed: \(error)") }
            else { self?.refreshPendingCount() }
        }
    }

    func scheduleLocationNotification(
        identifier: String,
        title: String,
        body: String,
        latitude: Double,
        longitude: Double,
        radiusMeters: Double = 200
    ) {
        let content         = UNMutableNotificationContent()
        content.title       = title
        content.body        = body
        content.sound       = .default
        content.userInfo    = ["type": "location_reminder"]
        let region = CLCircularRegion(
            center: .init(latitude: latitude, longitude: longitude),
            radius: radiusMeters,
            identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit  = false
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let request = UNNotificationRequest(
            identifier: "geo_\(identifier)",
            content: content,
            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[Notifications] ❌ Location notification failed: \(error)")
            } else {
                print("[Notifications] 📍 Location notification registered for '\(title)'")
            }
        }
    }


    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
        refreshPendingCount()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let info = response.notification.request.content.userInfo
        if let taskId = info["taskId"] as? String {
            NotificationCenter.default.post(name: .taskNotificationTapped, object: nil, userInfo: ["taskId": taskId])
        }
        if let eventId = info["eventId"] as? String {
            NotificationCenter.default.post(name: .eventNotificationTapped, object: nil, userInfo: ["eventId": eventId])
        }
        completionHandler()
    }
}


extension Notification.Name {
    static let taskNotificationTapped  = Notification.Name("taskNotificationTapped")
    static let eventNotificationTapped = Notification.Name("eventNotificationTapped")
}


struct NotificationTestPanel: View {
    @ObservedObject private var nm = NotificationManager.shared
    @State private var showConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.fill").foregroundColor(Color(hex: "#00C9B1"))
                Text("LOCAL NOTIFICATIONS")
                    .font(.system(size: 11, weight: .semibold)).kerning(1)
                    .foregroundColor(Color.white.opacity(0.5))
                Spacer()
                if nm.pendingCount > 0 {
                    Text("\(nm.pendingCount) pending")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#00C9B1"))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(hex: "#00C9B1").opacity(0.15))
                        .cornerRadius(8)
                }
            }

            if !nm.permissionGranted {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                    Text("Notifications disabled. Enable in iOS Settings.")
                        .font(.system(size: 13)).foregroundColor(.orange)
                }
            }

            HStack(spacing: 12) {
                notifButton(label: "Test Now (3s)", icon: "bell.badge", color: Color(hex: "#00C9B1")) {
                    nm.scheduleImmediate(title: "🔔 EventFlow Test", body: "Local push notifications are working!", delay: 3)
                    showConfirm = true
                }
                notifButton(label: "Event Alert (5s)", icon: "calendar.badge.clock", color: Color(hex: "#8B5CF6")) {
                    nm.scheduleImmediate(title: "📅 Event Tomorrow", body: "\"Team Kickoff Party\" starts tomorrow at 06:00 PM in Kurunegala.", delay: 5)
                }
            }

            if showConfirm {
                Text("✅ Scheduled! Lock your screen to see it.")
                    .font(.system(size: 12)).foregroundColor(Color(hex: "#00C9B1"))
            }
        }
        .padding(16)
        .background(Color(hex: "#1C1C1E"))
        .cornerRadius(16)
        .onAppear { nm.refreshPendingCount() }
    }

    @ViewBuilder
    private func notifButton(label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 20)).foregroundColor(color)
                Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(.white).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity).padding(12)
            .background(color.opacity(0.12)).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.25), lineWidth: 1))
        }
    }
}
