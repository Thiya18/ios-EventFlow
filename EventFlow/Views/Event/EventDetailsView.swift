// EventDetailsView.swift

import SwiftUI

struct EventDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore
    let event: EventModel

    private var eventTasks: [TaskModel] { store.tasks.filter { $0.event == event.title } }
    private var doneCount: Int { eventTasks.filter { $0.done }.count }


    private var liveEvent: EventModel {
        store.events.first { $0.rawId == event.rawId } ?? event
    }

    @State private var showAddTask    = false
    @State private var showAddMembers = false
    @State private var showLocationEdit = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

        
                HStack {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22)).foregroundColor(.white)
                        }
                        Text("Event Details")
                            .font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                            .padding(.leading, 12)
                    }
                    Spacer()
                    HStack(spacing: 20) {
                        Button { } label: {
                            Image(systemName: "square.and.arrow.up").foregroundColor(.white)
                        }
                        Button { } label: {
                            Image(systemName: "trash").foregroundColor(Color(hex: "#FF5C5C"))
                        }
                    }
                }
                .padding(.bottom, 32)

                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        LinearGradient(colors: [liveEvent.accent.opacity(0.7), liveEvent.accent.opacity(0.2)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(height: 140).frame(maxWidth: .infinity)
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 48)).foregroundColor(.white.opacity(0.3))
                    }
                    .clipped()

                    VStack(alignment: .leading, spacing: 16) {
                        Text(liveEvent.tag)
                            .font(.system(size: 10, weight: .bold)).kerning(1)
                            .foregroundColor(.black)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(liveEvent.accent).cornerRadius(12)

                        Text(liveEvent.title)
                            .font(.system(size: 20, weight: .semibold)).foregroundColor(.white)

                        HStack(spacing: 12) {
                            Image(systemName: "clock").font(.system(size: 16)).foregroundColor(Colors.textSecondary)
                            Text(liveEvent.time).font(.system(size: 14)).foregroundColor(Colors.textSecondary)
                        }
                        HStack(spacing: 12) {
                            Image(systemName: "mappin")
                                .font(.system(size: 16))
                                .foregroundColor(liveEvent.location.isEmpty ? Colors.accentTeal.opacity(0.6) : Colors.textSecondary)
                            if liveEvent.location.isEmpty {
                                Button { showLocationEdit = true } label: {
                                    Text("Tap to add location")
                                        .font(.system(size: 14))
                                        .foregroundColor(Colors.accentTeal.opacity(0.8))
                                }
                            } else {
                                Text(liveEvent.location)
                                    .font(.system(size: 14))
                                    .foregroundColor(Colors.textSecondary)
                            }
                        }
                    }
                    .padding(24)
                }
                .background(Colors.bgSecondary)
                .cornerRadius(24).clipped()
                .padding(.bottom, 24)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Members")
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                        Spacer()
                        Button { showAddMembers = true } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 13)).foregroundColor(Colors.accentTeal)
                                Text("Add")
                                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Colors.accentTeal)
                            }
                        }
                    }

                    if liveEvent.members.isEmpty {
                        Text("No members yet")
                            .font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                            .padding(.vertical, 8)
                    } else {

                        VStack(spacing: 12) {
                            ForEach(liveEvent.members) { member in
                                HStack(spacing: 14) {
            
                                    ZStack {
                                        Circle().fill(Colors.bgPrimary).frame(width: 44, height: 44)
                                        if member.avatarUrl.isEmpty {
                                            Text(String(member.name.prefix(1)).uppercased())
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Colors.accentTeal)
                                        } else {
                                            AsyncImage(url: URL(string: member.avatarUrl)) { img in
                                                img.resizable().scaledToFill()
                                            } placeholder: {
                                                Circle().fill(Colors.bgPrimary)
                                            }
                                            .frame(width: 44, height: 44).clipShape(Circle())
                                        }
                                    }
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(liveEvent.accent.opacity(0.3), lineWidth: 1.5))

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(member.name)
                                            .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                        Text(member.email)
                                            .font(.system(size: 11)).foregroundColor(Colors.textSecondary)
                                    }

                                    Spacer()

                                    Text(member.role.capitalized)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(member.role == "creator" ? .black : Colors.textSecondary)
                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                        .background(member.role == "creator" ? Colors.accentTeal : Color.white.opacity(0.08))
                                        .cornerRadius(8)

                                    if member.role != "creator" {
                                        Button {
                                            Task { await store.removeMember(eventRawId: liveEvent.rawId, userId: member.id) }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 18)).foregroundColor(Color(hex: "#FF5C5C").opacity(0.7))
                                        }
                                    }
                                }
                                .padding(12)
                                .background(Color(hex: "#252527"))
                                .cornerRadius(16)
                            }
                        }
                    }
                }
                .padding(24)
                .background(Colors.bgSecondary)
                .cornerRadius(24)
                .padding(.bottom, 24)

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Tasks")
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                        Spacer()
                        if !eventTasks.isEmpty {
                            Text("\(doneCount)/\(eventTasks.count) Done")
                                .font(.system(size: 14, weight: .semibold)).foregroundColor(Colors.accentTeal)
                        }
                    }
                    .padding(.bottom, 20)

                    if eventTasks.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "checklist")
                                .font(.system(size: 32)).foregroundColor(Colors.textSecondary)
                            Text("No tasks for this event yet")
                                .font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 24)
                    } else {
                        ForEach(eventTasks) { task in
                            DetailTaskRow(task: task,
                                          onToggle: { Task { await store.toggleTask(id: task.id) } })
                        }
                    }

                    Button { showAddTask = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus").font(.system(size: 18)).foregroundColor(Colors.accentTeal)
                            Text("Add Tasks").font(.system(size: 14, weight: .semibold)).foregroundColor(Colors.accentTeal)
                        }
                        .frame(maxWidth: .infinity).padding(16)
                        .background(Color(hex: "#38383A")).cornerRadius(12)
                    }
                    .padding(.top, 4)
                }
                .padding(24)
                .background(Colors.bgSecondary)
                .cornerRadius(24)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24).padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddTask) {
            AddTaskSheetView(eventTitle: liveEvent.title) { title, priority, dueDate in
                Task {
                    await store.createTask(text: title, priority: priority, dueDate: dueDate)
                    showAddTask = false
                }
            }
        }
        .sheet(isPresented: $showAddMembers) {
            AddMembersSheetView(event: liveEvent)
        }
        .sheet(isPresented: $showLocationEdit) {
            LocationEditSheet(eventRawId: liveEvent.rawId)
        }
        .task { await store.loadTasks() }
    }
}

struct LocationEditSheet: View {
    let eventRawId: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore
    @State private var pickedLocation = ""

    var body: some View {
        LocationPickerSheet(selectedLocation: $pickedLocation)
            .onChange(of: pickedLocation) { _, newVal in
                guard !newVal.isEmpty else { return }
                Task {
                    await store.updateEventLocation(rawId: eventRawId, location: newVal)
                    dismiss()
                }
            }
    }
}
struct DetailTaskRow: View {
    let task: TaskModel
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                Image(systemName: task.done ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundColor(task.done ? Colors.accentTeal : Colors.textSecondary)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(task.text)
                    .font(.system(size: 15))
                    .foregroundColor(task.done ? Colors.textSecondary : .white)
                    .strikethrough(task.done)
                if task.done {
                    Text("Completed").font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                } else if let due = task.dueDate {
                    HStack(spacing: 6) {
                        Image(systemName: "alarm").font(.system(size: 12)).foregroundColor(Color(hex: "#FF5C5C"))
                        Text("Due \(due, style: .time)").font(.system(size: 12)).foregroundColor(Color(hex: "#FF5C5C"))
                    }
                } else {
                    Text(task.priority.rawValue.capitalized + " priority")
                        .font(.system(size: 12)).foregroundColor(task.priority.color)
                }
            }
            Spacer()
        }
        .padding(20)
        .background(Color(hex: "#252527"))
        .cornerRadius(16)
        .opacity(task.done ? 0.6 : 1.0)
        .padding(.bottom, 12)
    }
}
struct AddTaskSheetView: View {
    let eventTitle: String
    let onSave: (String, String, Date?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var taskTitle  = ""
    @State private var priority   = "med"
    @State private var hasDueDate = false
    @State private var dueDate    = Date()
    @State private var isSaving   = false

    private let priorities = [("high","High",Colors.red),("med","Med",Colors.accentGold),("low","Low",Colors.success)]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    Text("TASK TITLE")
                        .font(.system(size: 11, weight: .bold)).kerning(1)
                        .foregroundColor(Colors.textSecondary).padding(.bottom, 8)
                    TextField("E.g. Finalize UI and Prototypes", text: $taskTitle)
                        .foregroundColor(.white).padding(16)
                        .background(Colors.bgSecondary).cornerRadius(16).padding(.bottom, 24)

                    Text("EVENT")
                        .font(.system(size: 11, weight: .bold)).kerning(1)
                        .foregroundColor(Colors.textSecondary).padding(.bottom, 8)
                    HStack {
                        Image(systemName: "calendar").foregroundColor(Colors.accentTeal)
                        Text(eventTitle).font(.system(size: 14)).foregroundColor(.white)
                    }
                    .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Colors.bgSecondary).cornerRadius(16).padding(.bottom, 24)

                    Text("PRIORITY")
                        .font(.system(size: 11, weight: .bold)).kerning(1)
                        .foregroundColor(Colors.textSecondary).padding(.bottom, 8)
                    HStack(spacing: 10) {
                        ForEach(priorities, id: \.0) { val, label, color in
                            Button { priority = val } label: {
                                Text(label).font(.system(size: 13, weight: .bold))
                                    .foregroundColor(priority == val ? .black : Colors.textSecondary)
                                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                                    .background(priority == val ? color : Color.clear).cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.4), lineWidth: 1))
                            }
                        }
                    }
                    .padding(.bottom, 24)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DUE DATE")
                                .font(.system(size: 11, weight: .bold)).kerning(1)
                                .foregroundColor(Colors.textSecondary)
                            Text(hasDueDate ? dueDate.formatted(date: .abbreviated, time: .shortened) : "No due date")
                                .font(.system(size: 14)).foregroundColor(.white)
                        }
                        Spacer()
                        Toggle("", isOn: $hasDueDate).tint(Colors.accentTeal)
                    }
                    .padding(16).background(Colors.bgSecondary).cornerRadius(16)
                    .padding(.bottom, hasDueDate ? 12 : 40)

                    if hasDueDate {
                        DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical).tint(Colors.accentTeal).colorScheme(.dark)
                            .padding(.bottom, 24)
                    }

                    Button {
                        guard !taskTitle.isEmpty, !isSaving else { return }
                        isSaving = true
                        onSave(taskTitle, priority, hasDueDate ? dueDate : nil)
                    } label: {
                        ZStack {
                            if isSaving {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Save Task").font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                            }
                        }
                        .frame(maxWidth: .infinity).padding(16)
                        .background(taskTitle.isEmpty ? Colors.accentTeal.opacity(0.4) : Colors.accentTeal)
                        .cornerRadius(16)
                    }
                    .disabled(taskTitle.isEmpty || isSaving)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24).padding(.top, 24)
            }
            .background(Colors.bgPrimary)
            .navigationTitle("Assign New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(Colors.accentTeal)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct AddMembersSheetView: View {
    let event: EventModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore
    @State private var searchText = ""
    @State private var addingId: String? = nil

    private var existingIds: Set<String> { Set(event.members.map { $0.id }) }

    private var filteredUsers: [MemberModel] {
        let q = searchText.lowercased()
        return store.allUsers.filter { user in
            !existingIds.contains(user.id) &&
            (q.isEmpty || user.name.lowercased().contains(q) || user.email.lowercased().contains(q))
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(Colors.textSecondary)
                    TextField("Search name or email...", text: $searchText)
                        .foregroundColor(.white).autocapitalization(.none).autocorrectionDisabled()
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Colors.textSecondary)
                        }
                    }
                }
                .padding(14)
                .background(Colors.bgSecondary)
                .cornerRadius(16)
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 16)

                if !event.members.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CURRENT MEMBERS")
                            .font(.system(size: 11, weight: .bold)).kerning(1)
                            .foregroundColor(Colors.textSecondary)
                            .padding(.horizontal, 24)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(event.members) { member in
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle().fill(Colors.bgSecondary).frame(width: 52, height: 52)
                                            if member.avatarUrl.isEmpty {
                                                Text(String(member.name.prefix(1)).uppercased())
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(Colors.accentTeal)
                                            } else {
                                                AsyncImage(url: URL(string: member.avatarUrl)) { img in
                                                    img.resizable().scaledToFill()
                                                } placeholder: { Circle().fill(Colors.bgSecondary) }
                                                .frame(width: 52, height: 52).clipShape(Circle())
                                            }
                                        }
                                        .overlay(Circle().stroke(Colors.accentTeal.opacity(0.4), lineWidth: 1.5))

                                        Text(member.name.components(separatedBy: " ").first ?? member.name)
                                            .font(.system(size: 11)).foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 16)

                    Divider().background(Color.white.opacity(0.06)).padding(.horizontal, 24).padding(.bottom, 16)
                }

              
                if store.allUsers.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView().tint(Colors.accentTeal)
                        Text("Loading users...").font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredUsers.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.slash").font(.system(size: 36)).foregroundColor(Colors.textSecondary)
                        Text(searchText.isEmpty ? "All users are already members" : "No users found")
                            .font(.system(size: 14)).foregroundColor(Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Text("ADD MEMBERS")
                                .font(.system(size: 11, weight: .bold)).kerning(1)
                                .foregroundColor(Colors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24).padding(.bottom, 12)

                            ForEach(filteredUsers) { user in
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle().fill(Colors.bgSecondary).frame(width: 48, height: 48)
                                        if user.avatarUrl.isEmpty {
                                            Text(String(user.name.prefix(1)).uppercased())
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Colors.accentTeal)
                                        } else {
                                            AsyncImage(url: URL(string: user.avatarUrl)) { img in
                                                img.resizable().scaledToFill()
                                            } placeholder: { Circle().fill(Colors.bgSecondary) }
                                            .frame(width: 48, height: 48).clipShape(Circle())
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(user.name).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                        Text(user.email).font(.system(size: 11)).foregroundColor(Colors.textSecondary)
                                    }

                                    Spacer()

                                    Button {
                                        addingId = user.id
                                        Task {
                                            await store.addMember(eventRawId: event.rawId, userId: user.id)
                                            addingId = nil
                                        }
                                    } label: {
                                        if addingId == user.id {
                                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Colors.accentTeal))
                                                .frame(width: 32, height: 32)
                                        } else {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 28)).foregroundColor(Colors.accentTeal)
                                        }
                                    }
                                    .disabled(addingId != nil)
                                }
                                .padding(.horizontal, 24).padding(.vertical, 12)

                                Divider().background(Color.white.opacity(0.05)).padding(.leading, 86)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .background(Colors.bgPrimary)
            .navigationTitle("Add Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.foregroundColor(Colors.accentTeal)
                }
            }
        }
        .preferredColorScheme(.dark)
        .task { await store.loadAllUsers() }
    }
}
