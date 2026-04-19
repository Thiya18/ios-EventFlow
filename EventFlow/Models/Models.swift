//
//  Models.swift
//  EventFlow
//
//  Created by Thiya on 2026-04-19.
//


import SwiftUI

//  Event
struct EventModel: Identifiable {
    let id: Int
    let tag: String
    let title: String
    let time: String
    let location: String
    let members: Int
    let accent: Color
    let date: EventDate
}

struct EventDate {
    let day: Int
    let month: Int
    let year: Int
}

//  Task
struct TaskModel: Identifiable {
    let id:      Int
    let rawId:   String
    let text:    String
    var done:    Bool
    let priority: TaskPriority
    let event:   String
    let dueDate: Date?
}

enum TaskPriority: String {
    case high, med, low

    var color: Color {
        switch self {
        case .high: return Colors.red
        case .med:  return Colors.accentGold
        case .low:  return Colors.success
        }
    }
}

//  Alert
struct AlertModel: Identifiable {
    let id: Int
    let tag: String
    let title: String
    let body: String
    let time: String
    var read: Bool
    let iconColor: Color
    let iconBg: Color
    let systemIcon: String
    let actions: [String]?
}

// Member
struct MemberModel: Identifiable {
    let id: Int
    let name: String
    let avatarURL: String
}

// Sample Data
extension EventModel {
    static let samples: [EventModel] = [
        EventModel(id: 1, tag: "MEETING",  title: "Final QA Review",     time: "02:00 PM — 03:00 PM", location: "Google Meet",       members: 5,  accent: Colors.accentTeal, date: EventDate(day: 12, month: 4, year: 2026)),
        EventModel(id: 2, tag: "EVENT",    title: "Team Kickoff Party",   time: "06:00 PM — 09:00 PM", location: "Kurunegala",         members: 12, accent: Colors.purple,     date: EventDate(day: 14, month: 4, year: 2026)),
        EventModel(id: 3, tag: "WORKSHOP", title: "Design Sprint",        time: "10:00 AM — 01:00 PM", location: "Office, 3rd Floor",  members: 8,  accent: Colors.accentGold, date: EventDate(day: 17, month: 4, year: 2026)),
    ]
}

extension TaskModel {
    static let samples: [TaskModel] = [
        TaskModel(id: 1, rawId: "", text: "Finalize UI and Prototypes", done: false, priority: .high, event: "Final QA Review",    dueDate: nil),
        TaskModel(id: 2, rawId: "", text: "Prepare QA test cases",      done: false, priority: .high, event: "Final QA Review",    dueDate: nil),
        TaskModel(id: 3, rawId: "", text: "Design Documentation",        done: true,  priority: .med,  event: "Design Sprint",       dueDate: nil),
        TaskModel(id: 4, rawId: "", text: "Send invites to team",        done: false, priority: .low,  event: "Team Kickoff Party",  dueDate: nil),
    ]
}

extension AlertModel {
    static let samples: [AlertModel] = [
        AlertModel(id: 1, tag: "LOCATION REMINDER", title: "You've arrived at the Supermarket",  body: "Your location reminder for the grocery run is now active.",                          time: "Just now",    read: false, iconColor: Colors.accentTeal, iconBg: Color(hex: "#0d2f2b"), systemIcon: "mappin.circle.fill", actions: ["Dismiss", "Open Map"]),
        AlertModel(id: 2, tag: "EVENT UPDATE",       title: "Final QA Review starts in 30 mins", body: "Get ready — your event 'Final QA Review' is coming up at 02:00 PM.",               time: "15 mins ago", read: false, iconColor: Colors.purple,     iconBg: Color(hex: "#1a1a2e"), systemIcon: "calendar",          actions: ["Dismiss", "View Event"]),
        AlertModel(id: 3, tag: "TASK SUGGESTION",    title: "Buy groceries for the Birthday Party", body: "Based on your event on Apr 14, don't forget to pick up supplies.",              time: "1 hour ago",  read: false, iconColor: Colors.accentGold, iconBg: Color(hex: "#1a1200"), systemIcon: "cart.fill",         actions: ["Ignore", "Add Task"]),
        AlertModel(id: 4, tag: "INVITE",             title: "Alex joined Team Kickoff Party",    body: "2 new members accepted your invite.",                                               time: "3 hours ago", read: true,  iconColor: Colors.pink,       iconBg: Color(hex: "#1a0d2e"), systemIcon: "person.2.fill",     actions: nil),
        AlertModel(id: 5, tag: "REMINDER",           title: "Tomorrow's Design Sprint",          body: "Don't forget to prepare your slides for the workshop at 10:00 AM.",                time: "Yesterday",   read: true,  iconColor: Colors.success,    iconBg: Color(hex: "#0a1f10"), systemIcon: "clock.fill",        actions: nil),
        AlertModel(id: 6, tag: "COMPLETED",          title: "Design Documentation marked done", body: "Great work! Your task has been checked off the list.",                              time: "Yesterday",   read: true,  iconColor: Colors.accentTeal, iconBg: Color(hex: "#0d2f2b"), systemIcon: "checkmark.circle.fill", actions: nil),
    ]
}
