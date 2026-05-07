// Models.swift
import SwiftUI


struct MemberModel: Identifiable, Equatable {
    let id:        String
    let name:      String
    let email:     String
    let avatarUrl: String
    let role:      String
}


struct EventModel: Identifiable, Equatable {
    static func == (lhs: EventModel, rhs: EventModel) -> Bool {
        lhs.rawId == rhs.rawId
    }

    let id:       Int
    let rawId:    String
    let tag:      String
    let title:    String
    let time:     String
    let location: String
    let accent:   Color
    let date:     EventDate
    let members:  [MemberModel]
}

struct EventDate {
    let day: Int; let month: Int; let year: Int
}

struct TaskModel: Identifiable {
    let id:       Int
    let rawId:    String
    let text:     String
    var done:     Bool
    let priority: TaskPriority
    let event:    String
    let dueDate:  Date?
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
