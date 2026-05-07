// HomeView.swift

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: store.userAvatar)) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Circle().fill(Colors.bgSecondary)
                            }
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Good Morning, \(store.userName)")
                                    .font(.system(size: 12))
                                    .foregroundColor(Colors.textSecondary)
                                Text("Welcome Back!")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Colors.textPrimary)
                            }
                        }
                        Spacer()
                        NavigationLink(destination: AlertsView()) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.system(size: 22))
                                    .foregroundColor(Colors.textPrimary)
                                if store.unreadCount > 0 {
                                    Circle()
                                        .fill(Colors.accentTeal)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 2, y: -2)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 32)

                    WeeklyProgressCard(
                        progress:  store.taskProgress,
                        completed: store.doneTasks,
                        pending:   store.pendingTasks
                    )
                    .padding(.bottom, 24)

                    Text("Upcoming Events")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Colors.textPrimary)
                        .padding(.bottom, 16)

                    if store.events.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 36))
                                .foregroundColor(Colors.textSecondary)
                            Text("No events yet")
                                .font(.system(size: 14))
                                .foregroundColor(Colors.textSecondary)
                            Text("Tap + to create your first event")
                                .font(.system(size: 12))
                                .foregroundColor(Colors.textSecondary.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                        .background(Colors.bgSecondary)
                        .cornerRadius(24)
                        .padding(.bottom, 24)
                    } else {
                        ForEach(store.events.prefix(3)) { event in
                            NavigationLink(destination: EventDetailsView(event: event)) {
                                LiveEventCardHome(event: event)
                            }
                            .padding(.bottom, 12)
                        }
                        .padding(.bottom, 12)
                    }

                    Text("Today's Tasks")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Colors.textPrimary)
                        .padding(.bottom, 16)

                    if store.tasks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 36))
                                .foregroundColor(Colors.textSecondary)
                            Text("No tasks yet")
                                .font(.system(size: 14))
                                .foregroundColor(Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(32)
                        .background(Colors.bgSecondary)
                        .cornerRadius(24)
                    } else {
                        ForEach(store.tasks.prefix(4)) { task in
                            TaskRowItem(
                                title:    task.text,
                                subtitle: task.done ? "Done" : task.event,
                                done:     task.done
                            )
                            .onTapGesture {
                                Task { await store.toggleTask(id: task.id) }
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .background(Colors.bgPrimary)
            .refreshable {
                await store.loadAll()
            }
        }
    }
}

struct WeeklyProgressCard: View {
    let progress:  Double
    let completed: Int
    let pending:   Int

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("WEEKLY PROCESS")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Colors.textPrimary)

            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color(hex: "#2C2C2E"), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(Colors.accentTeal, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Colors.textPrimary)
                }
                .frame(width: 80, height: 80)

                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("COMPLETED")
                            .font(.system(size: 11))
                            .kerning(1)
                            .foregroundColor(Colors.textSecondary)
                        Text("\(completed)")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Colors.accentTeal)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PENDING")
                            .font(.system(size: 11))
                            .kerning(1)
                            .foregroundColor(Colors.textSecondary)
                        Text("\(pending)")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Colors.accentGold)
                    }
                }
            }
        }
        .padding(24)
        .background(Colors.bgSecondary)
        .cornerRadius(24)
    }
}

struct LiveEventCardHome: View {
    let event: EventModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(event.tag)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(event.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(event.accent.opacity(0.2))
                .cornerRadius(12)
                .padding(.bottom, 16)

            Text(event.title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Colors.textPrimary)
                .padding(.bottom, 8)

            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(Colors.textSecondary)
                Text(event.time)
                    .font(.system(size: 12))
                    .foregroundColor(Colors.textSecondary)
            }
            .padding(.bottom, 8)

            HStack(spacing: 8) {
                Image(systemName: "mappin")
                    .font(.system(size: 14))
                    .foregroundColor(Colors.textSecondary)
                Text(event.location.isEmpty ? "No location set" : event.location)
                    .font(.system(size: 12))
                    .foregroundColor(Colors.textSecondary)
            }
            .padding(.bottom, 8)

            HStack(spacing: 8) {
                Image(systemName: "person.2")
                    .font(.system(size: 14))
                    .foregroundColor(Colors.textSecondary)
                Text("\(event.members.count) member\(event.members.count == 1 ? "" : "s")")
                    .font(.system(size: 12))
                    .foregroundColor(Colors.textSecondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#0d2f35"))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(event.accent.opacity(0.2), lineWidth: 1)
        )
    }
}

struct TaskRowItem: View {
    let title: String
    let subtitle: String
    let done: Bool

    var body: some View {
        HStack(spacing: 16) {
            if done {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Colors.accentTeal)
            } else {
                Circle()
                    .stroke(Colors.accentTeal, lineWidth: 2)
                    .frame(width: 24, height: 24)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(done ? Colors.textSecondary : Colors.textPrimary)
                    .strikethrough(done)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Colors.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Colors.bgSecondary)
        .cornerRadius(16)
        .padding(.bottom, 12)
    }
}
