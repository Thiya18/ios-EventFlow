// SupportingViews.swift
// AddTaskView · AddMembersView · InviteLinkView · AddLocationView · SuccessView

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore
    @State private var taskTitle  = ""
    @State private var priority   = "med"
    @State private var hasDueDate = false
    @State private var dueDate    = Date()
    @State private var isSaving   = false
    @State private var saved      = false

    private let priorities = [("high", "High", Colors.red),
                               ("med",  "Med",  Colors.accentGold),
                               ("low",  "Low",  Colors.success)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Assign New Task")
                    .padding(.bottom, 32)

                SectionLabel("TASK TITLE")
                TextField("E.g. Finalize UI and Prototypes", text: $taskTitle)
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Colors.bgSecondary)
                    .cornerRadius(16)
                    .padding(.bottom, 24)

                SectionLabel("PRIORITY")
                HStack(spacing: 10) {
                    ForEach(priorities, id: \.0) { val, label, color in
                        Button { priority = val } label: {
                            Text(label)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(priority == val ? .black : Colors.textSecondary)
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(priority == val ? color : Color.clear)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.4), lineWidth: 1))
                        }
                    }
                }
                .padding(.bottom, 24)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionLabel("DUE DATE")
                        Text(hasDueDate ? dueDate.formatted(date: .abbreviated, time: .shortened) : "No due date")
                            .font(.system(size: 14)).foregroundColor(.white)
                    }
                    Spacer()
                    Toggle("", isOn: $hasDueDate).tint(Colors.accentTeal)
                }
                .padding(16)
                .background(Colors.bgSecondary)
                .cornerRadius(16)
                .padding(.bottom, hasDueDate ? 12 : 48)

                if hasDueDate {
                    DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .tint(Colors.accentTeal)
                        .colorScheme(.dark)
                        .padding(.bottom, 24)
                }

                Button {
                    guard !taskTitle.isEmpty, !isSaving else { return }
                    isSaving = true
                    Task {
                        await store.createTask(text: taskTitle, priority: priority,
                                               dueDate: hasDueDate ? dueDate : nil)
                        saved = true
                        isSaving = false
                    }
                } label: {
                    ZStack {
                        if isSaving {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Text("Save Task")
                                .font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity).padding(16)
                    .background(taskTitle.isEmpty ? Colors.accentTeal.opacity(0.4) : Colors.accentTeal)
                    .cornerRadius(16)
                }
                .disabled(taskTitle.isEmpty || isSaving)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $saved) { SuccessView() }
    }
}


struct AddMembersView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore

    let event: EventModel

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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Add Members")
                    .padding(.bottom, 24)

           
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(Colors.textSecondary)
                    TextField("Search name or email...", text: $searchText)
                        .foregroundColor(.white).autocapitalization(.none).autocorrectionDisabled()
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundColor(Colors.textSecondary)
                        }
                    }
                }
                .padding(14)
                .background(Colors.bgSecondary)
                .cornerRadius(16)
                .padding(.bottom, 24)


                if !event.members.isEmpty {
                    SectionLabel("CURRENT MEMBERS").padding(.bottom, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(event.members) { member in
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle().fill(Colors.bgSecondary).frame(width: 56, height: 56)
                                        if member.avatarUrl.isEmpty {
                                            Text(String(member.name.prefix(1)).uppercased())
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(Colors.accentTeal)
                                        } else {
                                            AsyncImage(url: URL(string: member.avatarUrl)) { img in
                                                img.resizable().scaledToFill()
                                            } placeholder: { Circle().fill(Colors.bgSecondary) }
                                            .frame(width: 56, height: 56).clipShape(Circle())
                                        }
                                    }
                                    .overlay(Circle().stroke(Colors.accentTeal.opacity(0.4), lineWidth: 1.5))

                                    Text(member.name.components(separatedBy: " ").first ?? member.name)
                                        .font(.system(size: 11)).foregroundColor(.white)

                                    Text(member.role.capitalized)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(member.role == "creator" ? .black : Colors.textSecondary)
                                        .padding(.horizontal, 6).padding(.vertical, 2)
                                        .background(member.role == "creator" ? Colors.accentTeal : Color.white.opacity(0.08))
                                        .cornerRadius(6)
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }

                    Divider().background(Color.white.opacity(0.06)).padding(.bottom, 24)
                }

                
                SectionLabel("ADD MEMBERS").padding(.bottom, 16)

                if store.allUsers.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            ProgressView().tint(Colors.accentTeal)
                            Text("Loading users...").font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 40)
                } else if filteredUsers.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "person.slash")
                                .font(.system(size: 36)).foregroundColor(Colors.textSecondary)
                            Text(searchText.isEmpty ? "All users are already members" : "No users found")
                                .font(.system(size: 14)).foregroundColor(Colors.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 40)
                } else {
                    VStack(spacing: 0) {
                        ForEach(filteredUsers) { user in
                            HStack(spacing: 14) {
                    
                                ZStack {
                                    Circle().fill(Colors.bgSecondary).frame(width: 52, height: 52)
                                    if user.avatarUrl.isEmpty {
                                        Text(String(user.name.prefix(1)).uppercased())
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(Colors.accentTeal)
                                    } else {
                                        AsyncImage(url: URL(string: user.avatarUrl)) { img in
                                            img.resizable().scaledToFill()
                                        } placeholder: { Circle().fill(Colors.bgSecondary) }
                                        .frame(width: 52, height: 52).clipShape(Circle())
                                    }
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(user.name)
                                        .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                                    Text(user.email)
                                        .font(.system(size: 11)).foregroundColor(Colors.textSecondary)
                                }

                                Spacer()

                                
                                Button {
                                    addingId = user.id
                                    Task {
                                        await store.addMember(eventRawId: event.rawId, userId: user.id)
                                        addingId = nil
                                        dismiss()
                                    }
                                } label: {
                                    if addingId == user.id {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Colors.accentTeal))
                                            .frame(width: 32, height: 32)
                                    } else {
                                        Image(systemName: "person.badge.plus")
                                            .font(.system(size: 20)).foregroundColor(Colors.accentTeal)
                                    }
                                }
                                .disabled(addingId != nil)
                            }
                            .padding(14)
                            .background(Colors.bgSecondary)
                            .cornerRadius(16)
                            .padding(.bottom, 10)
                        }
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
        .task { await store.loadAllUsers() }
    }
}


struct InviteLinkView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    let shareOptions: [(String,String)] = [
        ("💬","Message"),("✉️","Email"),("🐦","Twitter"),("📘","Facebook"),("💼","LinkedIn"),("⋯","More")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Invite via Link")
                    .padding(.bottom, 28)

                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .frame(width: 160, height: 160)
                            .shadow(color: Colors.accentTeal.opacity(0.2), radius: 20, y: 8)
                        Image(systemName: "qrcode")
                            .font(.system(size: 100))
                            .foregroundColor(.black)
                        RoundedRectangle(cornerRadius: 6).fill(Colors.accentTeal)
                            .frame(width: 24, height: 24)
                            .background(.white.opacity(1)).cornerRadius(6)
                    }
                    Text("Share Event Access")
                        .font(.system(size: 20, weight: .semibold)).foregroundColor(.white)
                    Text("Anyone with this link or QR code can\ninstantly view the event details and RSVP.")
                        .font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                        .multilineTextAlignment(.center).lineSpacing(6)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 28)

                HStack {
                    Text("https://eventflow.app/inv/q8x9z2...")
                        .font(.system(size: 13)).foregroundColor(.white).lineLimit(1)
                    Spacer()
                    Button {
                        copied = true
                        UIPasteboard.general.string = "https://eventflow.app/inv/q8x9z2"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 16)).foregroundColor(Colors.accentTeal)
                            Text(copied ? "Copied!" : "Copy")
                                .font(.system(size: 12, weight: .semibold)).foregroundColor(Colors.accentTeal)
                        }
                    }
                }
                .padding(14)
                .background(Color(hex: "#252527")).cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
                .padding(.bottom, 24)

                SectionLabel("SHARE VIA").padding(.bottom, 16)
                HStack(spacing: 0) {
                    ForEach(shareOptions, id: \.0) { icon, label in
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "#1C1C1E"))
                                    .frame(width: 52, height: 52)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
                                Text(icon).font(.system(size: 22))
                            }
                            Text(label).font(.system(size: 11)).foregroundColor(Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 24)

                HStack(spacing: 12) {
                    Button { } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up").foregroundColor(.white)
                            Text("Share").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity).padding(16)
                        .background(Color(hex: "#2C2C2E")).cornerRadius(16)
                    }
                    Button {
                        copied = true
                        UIPasteboard.general.string = "https://eventflow.app/inv/q8x9z2"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                    } label: {
                        Text(copied ? "✓ Link Copied!" : "Copy Link")
                            .font(.system(size: 14, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(16)
                            .background(Colors.accentTeal).cornerRadius(16)
                    }
                    .frame(maxWidth: .infinity * 2)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24).padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
    }
}


struct AddLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remind = true
    @State private var searchQuery = ""

    let suggestions = ["Kurunegala","Kandy","Colombo","Galle","Negombo"]

    var filtered: [String] {
        searchQuery.isEmpty ? [] : suggestions.filter { $0.lowercased().hasPrefix(searchQuery.lowercased()) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Add Location").padding(.bottom, 20)

                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "#141416")).frame(height: 320)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.06), lineWidth: 1))

                    Canvas { ctx, size in
                        let stride: CGFloat = 60
                        var x: CGFloat = 0
                        while x < size.width {
                            ctx.stroke(Path { p in p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height)) }, with: .color(Color.white.opacity(0.05)), lineWidth: 1)
                            x += stride
                        }
                        var y: CGFloat = 0
                        while y < size.height {
                            ctx.stroke(Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y)) }, with: .color(Color.white.opacity(0.05)), lineWidth: 1)
                            y += stride
                        }
                    }
                    .frame(height: 320).clipShape(RoundedRectangle(cornerRadius: 24))

                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 42)).foregroundColor(Colors.accentTeal)
                        .shadow(color: Colors.accentTeal.opacity(0.4), radius: 12).offset(y: 120)

                    VStack(spacing: 6) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass").foregroundColor(Color(hex: "#888888"))
                            TextField("Search location...", text: $searchQuery)
                                .foregroundColor(.white).font(.system(size: 14))
                            if !searchQuery.isEmpty {
                                Button { searchQuery = "" } label: {
                                    Image(systemName: "xmark").font(.system(size: 12)).foregroundColor(Color(hex: "#aaaaaa"))
                                }
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Color(hex: "#16161A").opacity(0.95)).cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))

                        if !filtered.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(filtered, id: \.self) { s in
                                    Button { searchQuery = s } label: {
                                        HStack(spacing: 10) {
                                            Image(systemName: "mappin").font(.system(size: 14)).foregroundColor(Colors.accentTeal)
                                            Text(s).font(.system(size: 13)).foregroundColor(.white)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 14).padding(.vertical, 11)
                                    }
                                    if s != filtered.last { Divider().background(Color.white.opacity(0.05)) }
                                }
                            }
                            .background(Color(hex: "#16161A").opacity(0.97)).cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.07), lineWidth: 1))
                        }
                    }
                    .padding(14)
                }
                .padding(.bottom, 24)

                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14).fill(Color(hex: "#252527")).frame(width: 44, height: 44)
                        Image(systemName: "arrow.right.to.line").foregroundColor(Colors.accentTeal)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Remind me when I arrive")
                            .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                        Text("Alert triggers upon entry")
                            .font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                    }
                    Spacer()
                    Toggle("", isOn: $remind).tint(Colors.accentTeal)
                }
                .padding(18).background(Colors.bgSecondary).cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.05), lineWidth: 1))
                .padding(.bottom, 20)

                Button { dismiss() } label: {
                    Text("Save Location Reminder")
                        .font(.system(size: 15, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(16)
                        .background(Colors.accentTeal).cornerRadius(16)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24).padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
    }
}

struct SuccessView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle().fill(Colors.accentTeal.opacity(0.1)).frame(width: 160, height: 160)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80)).foregroundColor(Colors.accentTeal)
            }
            .padding(.bottom, 32)

            Text("Success!")
                .font(.system(size: 28, weight: .bold)).foregroundColor(Colors.textPrimary)
                .padding(.bottom, 16)

            Text("Your task has been successfully created\nand saved.")
                .font(.system(size: 15)).foregroundColor(Colors.textSecondary)
                .multilineTextAlignment(.center).lineSpacing(6)
                .padding(.bottom, 48)

            Button { dismiss() } label: {
                Text("Back to Dashboard")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(16)
                    .background(Colors.accentTeal).cornerRadius(16)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Colors.bgPrimary.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}


struct BackHeader: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    var body: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22)).foregroundColor(.white)
            }
            Text(title)
                .font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                .padding(.leading, 8)
            Spacer()
        }
    }
}

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 12)).kerning(1)
            .foregroundColor(Colors.textSecondary)
    }
}

struct InfoTile: View {
    let icon: String
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 16)).foregroundColor(Colors.textSecondary)
                Text(label).font(.system(size: 12)).kerning(1).foregroundColor(Colors.textSecondary)
            }
            Text(value).font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Colors.bgSecondary)
        .cornerRadius(16)
    }
}


import MapKit

struct LocationPickerSheet: View {
    @Binding var selectedLocation: String
    @Environment(\.dismiss) private var dismiss

    @State private var searchText    = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
        span:   MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedPin:  CLLocationCoordinate2D? = nil
    @State private var isSearching   = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

         
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: selectedPin.map { [PickedPin(coord: $0)] } ?? []) { pin in
                    MapAnnotation(coordinate: pin.coord) {
                        VStack(spacing: 0) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Colors.accentTeal)
                                .shadow(color: Colors.accentTeal.opacity(0.5), radius: 8)
                            Circle()
                                .fill(Colors.accentTeal.opacity(0.3))
                                .frame(width: 12, height: 6)
                                .scaleEffect(x: 1, y: 0.5)
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)

 
                VStack(spacing: 0) {
        
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Colors.textSecondary)
                        TextField("Search location...", text: $searchText)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                            .onChange(of: searchText) { _, val in
                                if val.isEmpty { searchResults = [] } else { search(val) }
                            }
                        if !searchText.isEmpty {
                            Button { searchText = ""; searchResults = [] } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Colors.textSecondary)
                            }
                        }
                        if isSearching {
                            ProgressView().tint(Colors.accentTeal).scaleEffect(0.8)
                        }
                    }
                    .padding(14)
                    .background(Color(hex: "#1C1C1E").opacity(0.97))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.horizontal, 16).padding(.top, 16)
                    .shadow(color: .black.opacity(0.4), radius: 10, y: 4)

                    // Search results dropdown
                    if !searchResults.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(searchResults.prefix(5), id: \.self) { item in
                                Button {
                                    selectMapItem(item)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(Colors.accentTeal)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.name ?? "Unknown")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                            if let addr = item.placemark.title {
                                                Text(addr)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(Colors.textSecondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16).padding(.vertical, 12)
                                }
                                if item != searchResults.prefix(5).last {
                                    Divider().background(Color.white.opacity(0.05))
                                }
                            }
                        }
                        .background(Color(hex: "#1C1C1E").opacity(0.97))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        .padding(.horizontal, 16).padding(.top, 8)
                        .shadow(color: .black.opacity(0.4), radius: 10, y: 4)
                    }

                    Spacer()

          
                    if !selectedLocation.isEmpty || selectedPin != nil {
                        VStack(spacing: 8) {
                            if !selectedLocation.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(Colors.accentTeal)
                                    Text(selectedLocation)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(hex: "#1C1C1E").opacity(0.95))
                                .cornerRadius(12)
                            }

                            Button {
                                dismiss()
                            } label: {
                                Text("Confirm Location")
                                    .font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                                    .frame(maxWidth: .infinity).padding(16)
                                    .background(Colors.accentTeal).cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(Colors.accentTeal)
                }
            }
            .preferredColorScheme(.dark)
        }
    }



    private func search(_ query: String) {
        isSearching = true
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = query
        req.region = region
        MKLocalSearch(request: req).start { response, _ in
            DispatchQueue.main.async {
                isSearching = false
                searchResults = response?.mapItems ?? []
            }
        }
    }

    private func selectMapItem(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        selectedPin = coord
        selectedLocation = item.name ?? item.placemark.title ?? ""
        searchText = ""
        searchResults = []
        withAnimation {
            region = MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}

struct PickedPin: Identifiable {
    let id = UUID()
    let coord: CLLocationCoordinate2D
}
