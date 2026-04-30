//
//  NetworkLayer.swift
//  EventFlow
//
//  Created by Thiya on 2026-04-30.
//

=

import SwiftUI
internal import Combine

// ── Base URL ──────────────────────────────────────────────────────────────────
private let BASE_URL = "http://localhost:8000/api"

// ── Raw API structs ───────────────────────────────────────────────────────────

private struct RawEvent: Codable {
    let _id:         String
    let title:       String
    let tag:         String
    let location:    String
    let startTime:   String
    let endTime:     String
    let accentColor: String
    let members:     [RawMember]?
    struct RawMember: Codable {
        let user: RawUser?
        let role: String
    }
}

private struct RawTask: Codable {
    let _id:      String
    var done:     Bool
    let text:     String
    let priority: String
    let dueDate:  String?       // ISO-8601 or null
    let event:    RawEventBrief?
    struct RawEventBrief: Codable {
        let _id:   String
        let title: String
    }
}

private struct RawNotification: Codable {
    let _id:       String
    let tag:       String
    let title:     String
    let body:      String
    var read:      Bool
    let iconType:  String
    let actions:   [String]?
    let createdAt: String?
}

private struct RawUser: Codable {
    let _id:       String
    let name:      String
    let email:     String
    let avatarUrl: String?
}

// ── HTTP helpers ──────────────────────────────────────────────────────────────

private func apiGet<T: Decodable>(_ path: String) async throws -> T {
    guard let url = URL(string: BASE_URL + path) else { throw URLError(.badURL) }
    var req = URLRequest(url: url)
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let (data, _) = try await URLSession.shared.data(for: req)
    return try JSONDecoder().decode(T.self, from: data)
}

private func apiPost(_ path: String, body: [String: Any]) async throws -> Data {
    guard let url = URL(string: BASE_URL + path) else { throw URLError(.badURL) }
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.httpBody = try JSONSerialization.data(withJSONObject: body)
    let (data, _) = try await URLSession.shared.data(for: req)
    return data
}

private func apiPatch(_ path: String) async throws {
    guard let url = URL(string: BASE_URL + path) else { return }
    var req = URLRequest(url: url)
    req.httpMethod = "PATCH"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    _ = try? await URLSession.shared.data(for: req)
}

/// PATCH with a JSON body (used for FCM token save, etc.)
private func apiPatchWithBody(_ path: String, body: [String: Any]) async throws {
    guard let url = URL(string: BASE_URL + path) else { return }
    var req = URLRequest(url: url)
    req.httpMethod = "PATCH"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.httpBody = try? JSONSerialization.data(withJSONObject: body)
    _ = try? await URLSession.shared.data(for: req)
}

private func apiDelete(_ path: String) async throws {
    guard let url = URL(string: BASE_URL + path) else { return }
    var req = URLRequest(url: url)
    req.httpMethod = "DELETE"
    _ = try? await URLSession.shared.data(for: req)
}

// ── Converters ────────────────────────────────────────────────────────────────

private func toEventDate(_ iso: String) -> EventDate {
    let df = DateFormatter()
    let fmts = ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd'T'HH:mm:ss"]
    var date: Date?
    for fmt in fmts { df.dateFormat = fmt; if let d = df.date(from: iso) { date = d; break } }
    let cal = Calendar.current
    let d = date ?? Date()
    return EventDate(day: cal.component(.day, from: d),
                     month: cal.component(.month, from: d),
                     year: cal.component(.year, from: d))
}

private func toTimeString(_ start: String, _ end: String) -> String {
    let df = DateFormatter(); let out = DateFormatter(); out.dateFormat = "hh:mm a"
    for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ssZ"] {
        df.dateFormat = fmt
        if let s = df.date(from: start), let e = df.date(from: end) {
            return "\(out.string(from: s)) — \(out.string(from: e))"
        }
    }
    return "\(start) — \(end)"
}

private func accentColor(_ hex: String) -> Color {
    switch hex.uppercased() {
    case "#00CCBB": return Colors.accentTeal
    case "#6C63FF": return Colors.purple
    case "#FFC107": return Colors.accentGold
    case "#FF453A": return Colors.red
    case "#E040FB": return Colors.pink
    default:        return Color(hex: hex)
    }
}

private func toEventModel(_ raw: RawEvent, index: Int) -> EventModel {
    EventModel(id: index, tag: raw.tag, title: raw.title,
               time: toTimeString(raw.startTime, raw.endTime),
               location: raw.location, members: raw.members?.count ?? 0,
               accent: accentColor(raw.accentColor),
               date: toEventDate(raw.startTime))
}

private func toTaskModel(_ raw: RawTask, index: Int) -> TaskModel {
    let priority: TaskPriority = raw.priority == "high" ? .high : raw.priority == "low" ? .low : .med

    // Parse ISO-8601 dueDate string into a Date
    var due: Date? = nil
    if let ds = raw.dueDate {
        let df = DateFormatter()
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd"] {
            df.dateFormat = fmt
            if let d = df.date(from: ds) { due = d; break }
        }
    }

    return TaskModel(id: index, rawId: raw._id, text: raw.text, done: raw.done,
                     priority: priority, event: raw.event?.title ?? "", dueDate: due)
}

private func toAlertModel(_ raw: RawNotification, index: Int) -> AlertModel {
    let iconColor: Color; let iconBg: Color
    switch raw.iconType {
    case "mappin.circle.fill":    iconColor = Colors.accentTeal; iconBg = Color(hex: "#0d2f2b")
    case "calendar":              iconColor = Colors.purple;     iconBg = Color(hex: "#1a1a2e")
    case "cart.fill":             iconColor = Colors.accentGold; iconBg = Color(hex: "#1a1200")
    case "person.2.fill":         iconColor = Colors.pink;       iconBg = Color(hex: "#1a0d2e")
    case "clock.fill":            iconColor = Colors.success;    iconBg = Color(hex: "#0a1f10")
    case "checkmark.circle.fill": iconColor = Colors.accentTeal; iconBg = Color(hex: "#0d2f2b")
    default:                      iconColor = Colors.textSecondary; iconBg = Colors.bgSecondary
    }
    var timeLabel = "Recently"
    if let str = raw.createdAt {
        let df = DateFormatter(); var date: Date?
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ssZ"] {
            df.dateFormat = fmt; if let d = df.date(from: str) { date = d; break }
        }
        if let d = date {
            let diff = Date().timeIntervalSince(d)
            timeLabel = diff < 60 ? "Just now" : diff < 3600 ? "\(Int(diff/60)) mins ago" :
                        diff < 86400 ? "\(Int(diff/3600)) hours ago" : "Yesterday"
        }
    }
    return AlertModel(id: index, tag: raw.tag, title: raw.title, body: raw.body,
                      time: timeLabel, read: raw.read, iconColor: iconColor,
                      iconBg: iconBg, systemIcon: raw.iconType, actions: raw.actions)
}

// ── AppStore ──────────────────────────────────────────────────────────────────

@MainActor
final class AppStore: ObservableObject {

    // ── Auth state ─────────────────────────────────────────────────────────
    @Published var isLoggedIn:    Bool   = false
    @Published var authError:     String = ""
    @Published var isAuthLoading: Bool   = false

    // ── Data ───────────────────────────────────────────────────────────────
    @Published var events:      [EventModel]  = EventModel.samples
    @Published var tasks:       [TaskModel]   = TaskModel.samples
    @Published var alerts:      [AlertModel]  = AlertModel.samples
    @Published var userName:    String        = "Thiya"
    @Published var userAvatar:  String        = "https://i.pravatar.cc/150?img=47"
    @Published var userEmail:   String        = ""
    @Published var isConnected: Bool          = false

    // Raw IDs
    private var rawEventIds:   [String] = []
    private var rawTaskIds:    [String] = []
    private var rawAlertIds:   [String] = []

    // ── Logged-in user ID — persisted across app restarts ─────────────────
    var currentUserId: String {
        get { UserDefaults.standard.string(forKey: "ef_user_id") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "ef_user_id") }
    }

    // Check on launch if user is already logged in
    init() {
        isLoggedIn = !currentUserId.isEmpty
    }

    // ── SIGN UP ────────────────────────────────────────────────────────────
    func register(name: String, email: String, password: String) async {
        isAuthLoading = true
        authError     = ""
        do {
            let data = try await apiPost("/users/register", body: [
                "name": name, "email": email, "password": password
            ])
            let user = try JSONDecoder().decode(RawUser.self, from: data)
            currentUserId = user._id
            userName      = user.name
            userEmail     = user.email
            userAvatar    = user.avatarUrl ?? "https://i.pravatar.cc/150?img=47"
            isLoggedIn    = true
            // Save FCM token now that we have a userId
            await AppStore.pushFCMTokenIfAvailable(userId: user._id)
            await loadAll()
        } catch {
            authError = "Registration failed. Email may already be in use."
        }
        isAuthLoading = false
    }

    // ── SIGN IN ────────────────────────────────────────────────────────────
    func login(email: String, password: String) async {
        isAuthLoading = true
        authError     = ""
        do {
            let data = try await apiPost("/users/login", body: [
                "email": email, "password": password
            ])
            // Check for error response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let err = json["error"] as? String {
                authError     = err
                isAuthLoading = false
                return
            }
            let user = try JSONDecoder().decode(RawUser.self, from: data)
            currentUserId = user._id
            userName      = user.name
            userEmail     = user.email
            userAvatar    = user.avatarUrl ?? "https://i.pravatar.cc/150?img=47"
            isLoggedIn    = true
            // Save FCM token now that we have a userId
            await AppStore.pushFCMTokenIfAvailable(userId: user._id)
            await loadAll()
        } catch {
            authError = "Login failed. Check your email and password."
        }
        isAuthLoading = false
    }

    // ── SIGN OUT ───────────────────────────────────────────────────────────
    func signOut() {
        currentUserId = ""
        UserDefaults.standard.removeObject(forKey: "ef_user_id")
        isLoggedIn    = false
        events        = EventModel.samples
        tasks         = TaskModel.samples
        alerts        = AlertModel.samples
        userName      = "Thiya"
        userEmail     = ""
    }

    // ── Boot ───────────────────────────────────────────────────────────────
    func load() async {
        // If user is already logged in (stored ID), restore their name
        if !currentUserId.isEmpty {
            if let raw = try? await apiGet("/users/\(currentUserId)") as RawUser {
                userName    = raw.name
                userEmail   = raw.email
                userAvatar  = raw.avatarUrl ?? "https://i.pravatar.cc/150?img=47"
                isConnected = true
            }
        }
        await loadAll()
    }

    func loadAll() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadEvents() }
            group.addTask { await self.loadTasks() }
            group.addTask { await self.loadAlerts() }
        }
    }

    // ── Events ─────────────────────────────────────────────────────────────
    func loadEvents() async {
        guard let raw = try? await apiGet("/events") as [RawEvent] else { return }
        rawEventIds = raw.map { $0._id }
        events      = raw.enumerated().map { toEventModel($1, index: $0) }

        // Schedule local reminders for every upcoming event.
        // Uses the raw ISO startTime string parsed into a Date for accuracy.
        let nm = NotificationManager.shared
        let df = DateFormatter()
        let fmts = ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd'T'HH:mm:ss"]

        for rawEvent in raw {
            df.locale = Locale(identifier: "en_US_POSIX")
            var startDate: Date? = nil
            for fmt in fmts {
                df.dateFormat = fmt
                if let d = df.date(from: rawEvent.startTime) { startDate = d; break }
            }
            guard let start = startDate else { continue }

            if start > Date() {
                // Upcoming — (re)schedule reminders; safe to call again, iOS deduplicates by ID
                nm.scheduleEventReminder(
                    eventId:   rawEvent._id,
                    title:     rawEvent.title,
                    location:  rawEvent.location,
                    startDate: start)
            } else {
                // Past event — cancel any stale reminders
                nm.cancelEventReminder(eventId: rawEvent._id)
            }
        }
    }

    func createEvent(title: String, tag: String, location: String,
                     startTime: Date, endTime: Date) async {
        guard !currentUserId.isEmpty else {
            print("❌ No logged-in user")
            return
        }
        let fmt = ISO8601DateFormatter()
        _ = try? await apiPost("/events", body: [
            "title":       title,
            "tag":         tag,
            "location":    location,
            "startTime":   fmt.string(from: startTime),
            "endTime":     fmt.string(from: endTime),
            "accentColor": "#00CCBB",
            "creatorId":   currentUserId,
        ])
        await loadEvents()
    }

    // ── Tasks ──────────────────────────────────────────────────────────────
    func loadTasks() async {
        guard let raw = try? await apiGet("/tasks") as [RawTask] else { return }
        rawTaskIds = raw.map { $0._id }
        tasks      = raw.enumerated().map { toTaskModel($1, index: $0) }

        // Refresh all local reminders to match current server state
        let nm = NotificationManager.shared
        for task in tasks {
            if task.done {
                nm.cancelTaskReminder(taskId: task.rawId)
            } else if let due = task.dueDate, !task.rawId.isEmpty {
                nm.scheduleTaskReminder(taskId: task.rawId, text: task.text, dueDate: due)
            }
        }
    }

    func toggleTask(id: Int) async {
        guard id < rawTaskIds.count else { return }
        if let i = tasks.firstIndex(where: { $0.id == id }) { tasks[i].done.toggle() }
        let rawId = rawTaskIds[id]
        try? await apiPatch("/tasks/\(rawId)/toggle")
        await loadTasks()   // loadTasks will re-sync reminders
    }

    func createTask(text: String, priority: String = "med", dueDate: Date? = nil) async {
        guard !rawEventIds.isEmpty else { return }
        let fmt = ISO8601DateFormatter()
        var body: [String: Any] = [
            "text":      text,
            "eventId":   rawEventIds[0],
            "priority":  priority,
            "creatorId": currentUserId,
        ]
        if let due = dueDate {
            body["dueDate"] = fmt.string(from: due)
        }
        _ = try? await apiPost("/tasks", body: body)
        await loadTasks()   // will schedule local reminder if dueDate set
    }

    // ── Notifications ──────────────────────────────────────────────────────
    func loadAlerts() async {
        guard let raw = try? await apiGet("/notifications") as [RawNotification] else { return }
        rawAlertIds = raw.map { $0._id }
        alerts      = raw.enumerated().map { toAlertModel($1, index: $0) }
    }

    func markRead(id: Int) async {
        guard id < rawAlertIds.count else { return }
        if let i = alerts.firstIndex(where: { $0.id == id }) { alerts[i].read = true }
        try? await apiPatch("/notifications/\(rawAlertIds[id])/read")
    }

    func markAllRead() async {
        for i in alerts.indices { alerts[i].read = true }
        try? await apiPatch("/notifications/read-all")
    }

    func dismissAlert(id: Int) async {
        guard id < rawAlertIds.count else { return }
        alerts.removeAll { $0.id == id }
        try? await apiDelete("/notifications/\(rawAlertIds[id])")
    }

    // ── Computed ───────────────────────────────────────────────────────────
    var unreadCount:  Int    { alerts.filter { !$0.read }.count }
    var pendingTasks: Int    { tasks.filter  { !$0.done }.count }
    var doneTasks:    Int    { tasks.filter  {  $0.done }.count }
    var taskProgress: Double { tasks.isEmpty ? 0 : Double(doneTasks) / Double(tasks.count) }

    // ── FCM Token Helpers ──────────────────────────────────────────────────

    /// Called by AppDelegate when APNs returns a device token.
    nonisolated static func saveFCMTokenToBackend(userId: String, token: String) async {
        try? await apiPatchWithBody("/users/\(userId)/fcm-token", body: ["fcmToken": token])
        print("[FCM] Token sent to backend for user \(userId)")
    }

    /// Called right after login/register — pushes any stored APNs token immediately.
    nonisolated static func pushFCMTokenIfAvailable(userId: String) async {
        guard let token = UserDefaults.standard.string(forKey: "ef_apns_token"),
              !token.isEmpty else { return }
        await saveFCMTokenToBackend(userId: userId, token: token)
    }
}
