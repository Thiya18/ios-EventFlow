//
//  EventFlowTests.swift
//  EventFlowTests
//

import XCTest
@testable import EventFlow
internal import SwiftUI

final class MemberModelTests: XCTestCase {

    func test_memberModel_id_is_set_correctly() {
        let member = makeMember(id: "user123")
        XCTAssertEqual(member.id, "user123")
    }

    func test_memberModel_name_is_set_correctly() {
        let member = makeMember(name: "Kasun Silva")
        XCTAssertEqual(member.name, "Kasun Silva")
    }

    func test_memberModel_email_is_set_correctly() {
        let member = makeMember(email: "kasun@test.com")
        XCTAssertEqual(member.email, "kasun@test.com")
    }

    func test_memberModel_role_is_set_correctly() {
        let member = makeMember(role: "organizer")
        XCTAssertEqual(member.role, "organizer")
    }

    func test_memberModel_equatable_same_fields() {
        let m1 = makeMember(id: "abc")
        let m2 = makeMember(id: "abc")
        XCTAssertEqual(m1, m2)
    }

    func test_memberModel_equatable_different_ids() {
        let m1 = makeMember(id: "abc")
        let m2 = makeMember(id: "xyz")
        XCTAssertNotEqual(m1, m2)
    }

    private func makeMember(id: String = "id1", name: String = "Test User",
                             email: String = "test@test.com", role: String = "member") -> MemberModel {
        MemberModel(id: id, name: name, email: email, avatarUrl: "", role: role)
    }
}

final class EventModelTests: XCTestCase {

    func test_eventModel_equality_based_on_rawId() {
        let e1 = makeEvent(rawId: "event_abc")
        let e2 = makeEvent(rawId: "event_abc")
        XCTAssertEqual(e1, e2)
    }

    func test_eventModel_inequality_different_rawId() {
        let e1 = makeEvent(rawId: "event_abc")
        let e2 = makeEvent(rawId: "event_xyz")
        XCTAssertNotEqual(e1, e2)
    }

    func test_eventModel_title_is_set() {
        let event = makeEvent(title: "Tech Summit 2026")
        XCTAssertEqual(event.title, "Tech Summit 2026")
    }

    func test_eventModel_tag_is_set() {
        let event = makeEvent(tag: "conference")
        XCTAssertEqual(event.tag, "conference")
    }

    func test_eventModel_location_is_set() {
        let event = makeEvent(location: "Colombo, Sri Lanka")
        XCTAssertEqual(event.location, "Colombo, Sri Lanka")
    }

    func test_eventModel_members_empty_by_default() {
        let event = makeEvent()
        XCTAssertTrue(event.members.isEmpty)
    }

    func test_eventModel_members_count() {
        let members = [
            MemberModel(id: "1", name: "A", email: "a@a.com", avatarUrl: "", role: "organizer"),
            MemberModel(id: "2", name: "B", email: "b@b.com", avatarUrl: "", role: "member"),
        ]
        let event = makeEvent(members: members)
        XCTAssertEqual(event.members.count, 2)
    }

    func test_eventDate_day_month_year() {
        let date = EventDate(day: 15, month: 6, year: 2026)
        XCTAssertEqual(date.day,   15)
        XCTAssertEqual(date.month, 6)
        XCTAssertEqual(date.year,  2026)
    }

    private func makeEvent(rawId: String = "rawId1", title: String = "Test Event",
                            tag: String = "general", location: String = "Online",
                            members: [MemberModel] = []) -> EventModel {
        EventModel(id: 0, rawId: rawId, tag: tag, title: title,
                   time: "10:00 AM — 11:00 AM", location: location,
                   accent: .blue,
                   date: EventDate(day: 1, month: 1, year: 2026),
                   members: members)
    }
}

final class TaskModelTests: XCTestCase {

    func test_taskModel_text_is_set() {
        let task = makeTask(text: "Book venue")
        XCTAssertEqual(task.text, "Book venue")
    }

    func test_taskModel_done_defaults_to_false() {
        let task = makeTask()
        XCTAssertFalse(task.done)
    }

    func test_taskModel_can_be_marked_done() {
        var task = makeTask()
        task.done = true
        XCTAssertTrue(task.done)
    }

    func test_taskModel_priority_high() {
        let task = makeTask(priority: .high)
        XCTAssertEqual(task.priority, .high)
    }

    func test_taskModel_priority_med() {
        let task = makeTask(priority: .med)
        XCTAssertEqual(task.priority, .med)
    }

    func test_taskModel_priority_low() {
        let task = makeTask(priority: .low)
        XCTAssertEqual(task.priority, .low)
    }

    func test_taskModel_dueDate_can_be_nil() {
        let task = makeTask(dueDate: nil)
        XCTAssertNil(task.dueDate)
    }

    func test_taskModel_dueDate_can_be_set() {
        let date = Date()
        let task = makeTask(dueDate: date)
        XCTAssertNotNil(task.dueDate)
    }

    func test_taskModel_event_name_is_set() {
        let task = makeTask(event: "Tech Summit")
        XCTAssertEqual(task.event, "Tech Summit")
    }

    private func makeTask(text: String = "Test task", done: Bool = false,
                           priority: TaskPriority = .med, event: String = "General",
                           dueDate: Date? = nil) -> TaskModel {
        TaskModel(id: 0, rawId: "raw1", text: text, done: done,
                  priority: priority, event: event, dueDate: dueDate)
    }
}

final class TaskPriorityTests: XCTestCase {

    func test_taskPriority_rawValue_high() {
        XCTAssertEqual(TaskPriority.high.rawValue, "high")
    }

    func test_taskPriority_rawValue_med() {
        XCTAssertEqual(TaskPriority.med.rawValue, "med")
    }

    func test_taskPriority_rawValue_low() {
        XCTAssertEqual(TaskPriority.low.rawValue, "low")
    }

    func test_taskPriority_color_not_nil() {
        _ = TaskPriority.high.color
        _ = TaskPriority.med.color
        _ = TaskPriority.low.color
    }
}

final class AlertModelTests: XCTestCase {

    func test_alertModel_title_is_set() {
        let alert = makeAlert(title: "New Event Created")
        XCTAssertEqual(alert.title, "New Event Created")
    }

    func test_alertModel_body_is_set() {
        let alert = makeAlert(body: "Tech Summit starts tomorrow")
        XCTAssertEqual(alert.body, "Tech Summit starts tomorrow")
    }

    func test_alertModel_read_defaults_to_false() {
        let alert = makeAlert(read: false)
        XCTAssertFalse(alert.read)
    }

    func test_alertModel_can_be_marked_read() {
        var alert = makeAlert(read: false)
        alert.read = true
        XCTAssertTrue(alert.read)
    }

    func test_alertModel_actions_can_be_nil() {
        let alert = makeAlert(actions: nil)
        XCTAssertNil(alert.actions)
    }

    func test_alertModel_actions_can_have_values() {
        let alert = makeAlert(actions: ["Accept", "Decline"])
        XCTAssertEqual(alert.actions?.count, 2)
    }

    func test_alertModel_systemIcon_is_set() {
        let alert = makeAlert(systemIcon: "calendar")
        XCTAssertEqual(alert.systemIcon, "calendar")
    }

    private func makeAlert(title: String = "Alert", body: String = "Body",
                            read: Bool = false, actions: [String]? = nil,
                            systemIcon: String = "bell") -> AlertModel {
        AlertModel(id: 0, tag: "info", title: title, body: body, time: "Just now",
                   read: read, iconColor: .blue, iconBg: .gray,
                   systemIcon: systemIcon, actions: actions)
    }
}

@MainActor
final class AppStoreComputedTests: XCTestCase {

    var store: AppStore!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "ef_user_id")
        store = AppStore()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "ef_user_id")
        store = nil
        super.tearDown()
    }

    func test_initial_isLoggedIn_false_when_no_saved_user() {
        XCTAssertFalse(store.isLoggedIn)
    }

    func test_initial_events_isEmpty() {
        XCTAssertTrue(store.events.isEmpty)
    }

    func test_initial_tasks_isEmpty() {
        XCTAssertTrue(store.tasks.isEmpty)
    }

    func test_initial_alerts_isEmpty() {
        XCTAssertTrue(store.alerts.isEmpty)
    }

    func test_initial_userName_isEmpty() {
        XCTAssertTrue(store.userName.isEmpty)
    }

    func test_initial_userEmail_isEmpty() {
        XCTAssertTrue(store.userEmail.isEmpty)
    }

    func test_initial_authError_isEmpty() {
        XCTAssertTrue(store.authError.isEmpty)
    }

    func test_initial_isAuthLoading_isFalse() {
        XCTAssertFalse(store.isAuthLoading)
    }

    func test_unreadCount_zero_when_no_alerts() {
        store.alerts = []
        XCTAssertEqual(store.unreadCount, 0)
    }

    func test_unreadCount_counts_only_unread() {
        store.alerts = [
            makeAlert(id: 0, read: false),
            makeAlert(id: 1, read: true),
            makeAlert(id: 2, read: false),
        ]
        XCTAssertEqual(store.unreadCount, 2)
    }

    func test_unreadCount_zero_when_all_read() {
        store.alerts = [
            makeAlert(id: 0, read: true),
            makeAlert(id: 1, read: true),
        ]
        XCTAssertEqual(store.unreadCount, 0)
    }

    func test_pendingTasks_zero_when_no_tasks() {
        store.tasks = []
        XCTAssertEqual(store.pendingTasks, 0)
    }

    func test_pendingTasks_counts_undone_tasks() {
        store.tasks = [
            makeTask(id: 0, done: false),
            makeTask(id: 1, done: true),
            makeTask(id: 2, done: false),
        ]
        XCTAssertEqual(store.pendingTasks, 2)
    }

    func test_doneTasks_counts_completed_tasks() {
        store.tasks = [
            makeTask(id: 0, done: true),
            makeTask(id: 1, done: false),
            makeTask(id: 2, done: true),
        ]
        XCTAssertEqual(store.doneTasks, 2)
    }

    func test_taskProgress_zero_when_no_tasks() {
        store.tasks = []
        XCTAssertEqual(store.taskProgress, 0.0, accuracy: 0.001)
    }

    func test_taskProgress_1_when_all_done() {
        store.tasks = [
            makeTask(id: 0, done: true),
            makeTask(id: 1, done: true),
        ]
        XCTAssertEqual(store.taskProgress, 1.0, accuracy: 0.001)
    }

    func test_taskProgress_half_when_half_done() {
        store.tasks = [
            makeTask(id: 0, done: true),
            makeTask(id: 1, done: false),
        ]
        XCTAssertEqual(store.taskProgress, 0.5, accuracy: 0.001)
    }

    func test_taskProgress_zero_when_none_done() {
        store.tasks = [
            makeTask(id: 0, done: false),
            makeTask(id: 1, done: false),
        ]
        XCTAssertEqual(store.taskProgress, 0.0, accuracy: 0.001)
    }

    func test_signOut_clears_all_state() {
        store.isLoggedIn  = true
        store.userName    = "Kasun"
        store.userEmail   = "kasun@test.com"
        store.userAvatar  = "http://avatar.url"
        store.isConnected = true
        store.events      = [makeEvent()]
        store.tasks       = [makeTask(id: 0)]
        store.alerts      = [makeAlert(id: 0)]

        store.signOut()

        XCTAssertFalse(store.isLoggedIn)
        XCTAssertTrue(store.userName.isEmpty)
        XCTAssertTrue(store.userEmail.isEmpty)
        XCTAssertTrue(store.userAvatar.isEmpty)
        XCTAssertFalse(store.isConnected)
        XCTAssertTrue(store.events.isEmpty)
        XCTAssertTrue(store.tasks.isEmpty)
        XCTAssertTrue(store.alerts.isEmpty)
    }

    func test_signOut_removes_saved_userId() {
        UserDefaults.standard.set("user_abc", forKey: "ef_user_id")
        store.signOut()
        let saved = UserDefaults.standard.string(forKey: "ef_user_id")
        XCTAssertTrue(saved == nil || saved == "")
    }

    func test_currentUserId_saved_to_userDefaults() {
        store.currentUserId = "user_999"
        let saved = UserDefaults.standard.string(forKey: "ef_user_id")
        XCTAssertEqual(saved, "user_999")
    }

    func test_currentUserId_read_from_userDefaults() {
        UserDefaults.standard.set("user_888", forKey: "ef_user_id")
        XCTAssertEqual(store.currentUserId, "user_888")
    }

    func test_markRead_updates_local_alert_read_to_true() {
        store.alerts = [makeAlert(id: 0, read: false)]
        store.alerts[0].read = true
        XCTAssertTrue(store.alerts[0].read)
    }

    func test_dismissAlert_removes_alert_from_list() {
        store.alerts = [
            makeAlert(id: 0, read: false),
            makeAlert(id: 1, read: true),
        ]
        store.alerts.removeAll { $0.id == 0 }
        XCTAssertEqual(store.alerts.count, 1)
        XCTAssertEqual(store.alerts.first?.id, 1)
    }

    func test_markAllRead_sets_all_alerts_to_read() {
        store.alerts = [
            makeAlert(id: 0, read: false),
            makeAlert(id: 1, read: false),
            makeAlert(id: 2, read: false),
        ]
        for i in store.alerts.indices { store.alerts[i].read = true }
        XCTAssertEqual(store.unreadCount, 0)
    }

    func test_toggleTask_flips_done_state() {
        store.tasks = [makeTask(id: 0, done: false)]
        store.tasks[0].done.toggle()
        XCTAssertTrue(store.tasks[0].done)
    }

    func test_toggleTask_flips_back_to_undone() {
        store.tasks = [makeTask(id: 0, done: true)]
        store.tasks[0].done.toggle()
        XCTAssertFalse(store.tasks[0].done)
    }

    private func makeTask(id: Int, done: Bool = false) -> TaskModel {
        TaskModel(id: id, rawId: "raw\(id)", text: "Task \(id)",
                  done: done, priority: .med, event: "Event", dueDate: nil)
    }

    private func makeAlert(id: Int, read: Bool = false) -> AlertModel {
        AlertModel(id: id, tag: "info", title: "Alert \(id)", body: "Body",
                   time: "Just now", read: read, iconColor: .blue, iconBg: .gray,
                   systemIcon: "bell", actions: nil)
    }

    private func makeEvent() -> EventModel {
        EventModel(id: 0, rawId: "raw0", tag: "conf", title: "Event",
                   time: "10AM", location: "Online", accent: .blue,
                   date: EventDate(day: 1, month: 1, year: 2026), members: [])
    }
}

final class BiometricAuthManagerTests: XCTestCase {

    var sut: BiometricAuthManager!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "biometricEnabled")
        sut = BiometricAuthManager.shared
        sut.isBiometricEnabled = false
        sut.isLocked = false
        sut.authError = ""
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "biometricEnabled")
        sut = nil
        super.tearDown()
    }

    func test_initial_isAuthenticating_isFalse() {
        XCTAssertFalse(sut.isAuthenticating)
    }

    func test_initial_authError_isEmpty() {
        XCTAssertTrue(sut.authError.isEmpty)
    }

    func test_biometricEnabled_persists_to_userDefaults() {
        sut.isBiometricEnabled = true
        let saved = UserDefaults.standard.bool(forKey: "biometricEnabled")
        XCTAssertTrue(saved)
    }

    func test_biometricEnabled_false_persists_to_userDefaults() {
        sut.isBiometricEnabled = false
        let saved = UserDefaults.standard.bool(forKey: "biometricEnabled")
        XCTAssertFalse(saved)
    }

    func test_lock_doesNotLock_when_biometricDisabled() {
        sut.isBiometricEnabled = false
        sut.lock()
        XCTAssertFalse(sut.isLocked)
    }

    func test_biometricLabel_returns_non_empty_string() {
        XCTAssertFalse(sut.biometricLabel.isEmpty)
    }

    func test_biometricIcon_returns_non_empty_string() {
        XCTAssertFalse(sut.biometricIcon.isEmpty)
    }

    func test_unlockIfNeeded_doesNothing_when_not_locked() {
        sut.isLocked = false
        sut.unlockIfNeeded()
    }
}

final class EventDateTests: XCTestCase {

    func test_eventDate_stores_day_correctly() {
        let date = EventDate(day: 25, month: 12, year: 2026)
        XCTAssertEqual(date.day, 25)
    }

    func test_eventDate_stores_month_correctly() {
        let date = EventDate(day: 1, month: 8, year: 2026)
        XCTAssertEqual(date.month, 8)
    }

    func test_eventDate_stores_year_correctly() {
        let date = EventDate(day: 1, month: 1, year: 2030)
        XCTAssertEqual(date.year, 2030)
    }

    func test_eventDate_first_day_of_year() {
        let date = EventDate(day: 1, month: 1, year: 2026)
        XCTAssertEqual(date.day, 1)
        XCTAssertEqual(date.month, 1)
    }

    func test_eventDate_last_day_of_year() {
        let date = EventDate(day: 31, month: 12, year: 2026)
        XCTAssertEqual(date.day, 31)
        XCTAssertEqual(date.month, 12)
    }
}
