//
//  CalendarView.swift
//  EventFlow
//
//  Created by Thiya on 2026-04-19.
//



import SwiftUI

struct CalendarView: View {
    @State private var selectedTab: CalTab = .events
    @State private var tasks = TaskModel.samples
    @State private var activeDate = Date()
    @State private var anchorDate = Date()

    enum CalTab { case events, tasks }

    private let dayNames = ["Su","Mo","Tu","We","Th","Fr","Sa"]
    private let monthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

    private var weekDays: [Date] {
        var cal = Calendar.current
        let startOfWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: anchorDate))!
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private var pendingCount: Int { tasks.filter { !$0.done }.count }
    private var doneCount:    Int { tasks.filter {  $0.done }.count }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Date(), style: .date)
                                .font(.system(size: 12))
                                .foregroundColor(Colors.textSecondary)
                            Text("My Events & Tasks")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Colors.textPrimary)
                        }
                        Spacer()
                        NavigationLink(destination: CreateEventView(onDismiss: {})) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 40, height: 40)
                                .background(Colors.accentTeal)
                                .clipShape(Circle())
                                .shadow(color: Colors.accentTeal.opacity(0.4), radius: 10, y: 4)
                        }
                    }
                    .padding(.bottom, 24)

                    // Week Strip
                    WeekStripView(
                        weekDays: weekDays,
                        activeDate: $activeDate,
                        anchorDate: $anchorDate,
                        monthNames: monthNames,
                        dayNames: dayNames
                    )
                    .padding(.bottom, 24)

                    // Tabs
                    HStack(spacing: 8) {
                        ForEach([CalTab.events, CalTab.tasks], id: \.self) { tab in
                            Button {
                                selectedTab = tab
                            } label: {
                                Text(tab == .events ? "Events (\(EventModel.samples.count))" : "Tasks (\(tasks.count))")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(selectedTab == tab ? .black : Colors.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedTab == tab ? Colors.accentTeal : Color.clear)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(4)
                    .background(Colors.bgSecondary)
                    .cornerRadius(16)
                    .padding(.bottom, 20)

                    if selectedTab == .events {
                        EventsTab()
                    } else {
                        TasksTab(tasks: $tasks, pendingCount: pendingCount, doneCount: doneCount)
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .background(Colors.bgPrimary)
        }
    }
}

// MARK: - Week Strip
struct WeekStripView: View {
    let weekDays: [Date]
    @Binding var activeDate: Date
    @Binding var anchorDate: Date
    let monthNames: [String]
    let dayNames: [String]

    private func sameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }

    private var weekLabel: String {
        let cal = Calendar.current
        let m1 = cal.component(.month, from: weekDays.first ?? Date()) - 1
        let m2 = cal.component(.month, from: weekDays.last  ?? Date()) - 1
        let yr = cal.component(.year,  from: anchorDate)
        return "\(monthNames[m1]) — \(monthNames[m2]) \(yr)"
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    anchorDate = Calendar.current.date(byAdding: .day, value: -7, to: anchorDate)!
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Colors.accentTeal)
                }
                Spacer()
                Text(weekLabel)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Colors.textSecondary)
                Spacer()
                Button {
                    anchorDate = Calendar.current.date(byAdding: .day, value: 7, to: anchorDate)!
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Colors.accentTeal)
                }
            }

            HStack(spacing: 6) {
                ForEach(weekDays, id: \.self) { day in
                    let isActive  = sameDay(day, activeDate)
                    let isToday   = sameDay(day, Date())
                    let cal       = Calendar.current
                    let dayNum    = cal.component(.day, from: day)
                    let dayIdx    = cal.component(.weekday, from: day) - 1
                    let hasEvent  = EventModel.samples.contains {
                        $0.date.day == dayNum && $0.date.month == cal.component(.month, from: day)
                    }

                    Button { activeDate = day } label: {
                        VStack(spacing: 6) {
                            Text(["Su","Mo","Tu","We","Th","Fr","Sa"][dayIdx])
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(isActive ? .black : Colors.textSecondary)
                            Text("\(dayNum)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(isActive ? .black : Colors.textPrimary)
                            Circle()
                                .fill(hasEvent ? (isActive ? Color.black : Colors.accentTeal) : Color.clear)
                                .frame(width: 5, height: 5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isActive ? Colors.accentTeal : Color.clear)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isToday && !isActive ? Colors.accentTeal.opacity(0.35) : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Events Tab
struct EventsTab: View {
    var body: some View {
        ForEach(EventModel.samples) { ev in
            NavigationLink(destination: EventDetailsView()) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(ev.tag)
                        .font(.system(size: 11, weight: .bold))
                        .kerning(1)
                        .foregroundColor(ev.accent)
                        .padding(.bottom, 14)

                    Text(ev.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Colors.textPrimary)
                        .padding(.bottom, 10)

                    HStack(spacing: 5) {
                        Image(systemName: "clock").font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                        Text(ev.time).font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                    }.padding(.bottom, 4)

                    HStack(spacing: 5) {
                        Image(systemName: "mappin").font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                        Text(ev.location).font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                    }.padding(.bottom, 4)

                    HStack(spacing: 5) {
                        Image(systemName: "person.2").font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                        Text("\(ev.members) members").font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                    }

                    Rectangle()
                        .fill(ev.accent)
                        .frame(height: 3)
                        .cornerRadius(4)
                        .padding(.top, 16)
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#0d2f35"))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ev.accent.opacity(0.2), lineWidth: 1)
                )
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Tasks Tab
struct TasksTab: View {
    @Binding var tasks: [TaskModel]
    let pendingCount: Int
    let doneCount: Int

    private var progress: Double {
        tasks.isEmpty ? 0 : Double(doneCount) / Double(tasks.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Stats row
            HStack(spacing: 12) {
                ForEach([("Pending", pendingCount, Colors.accentGold), ("Done", doneCount, Colors.success), ("Total", tasks.count, Colors.accentTeal)], id: \.0) { label, val, color in
                    VStack(spacing: 4) {
                        Text("\(val)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(color)
                        Text(label)
                            .font(.system(size: 11))
                            .foregroundColor(Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Colors.bgSecondary)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.2), lineWidth: 1))
                }
            }
            .padding(.bottom, 20)

            // Progress bar
            VStack(spacing: 6) {
                HStack {
                    Text("Overall Progress").font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                    Spacer()
                    Text("\(Int(progress * 100))%").font(.system(size: 12)).foregroundColor(Colors.accentTeal)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.08)).frame(height: 6)
                        RoundedRectangle(cornerRadius: 6).fill(Colors.accentTeal)
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
            }
            .padding(.bottom, 20)

            // Task list
            ForEach(tasks) { task in
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(task.priority.color)
                        .frame(width: 4, height: 36)

                    Button {
                        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                            tasks[idx].done.toggle()
                        }
                    } label: {
                        Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22))
                            .foregroundColor(task.done ? Colors.accentTeal : Color.white.opacity(0.25))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(task.text)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(task.done ? Colors.textSecondary : Colors.textPrimary)
                            .strikethrough(task.done)
                        Text(task.event)
                            .font(.system(size: 11))
                            .foregroundColor(Colors.textSecondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(Colors.bgSecondary)
                .cornerRadius(16)
                .opacity(task.done ? 0.6 : 1.0)
                .padding(.bottom, 10)
            }
        }
    }
}
