// SupportingViews.swift
// AddTaskView · AddMembersView · InviteLinkView · AddLocationView · SuccessView

import SwiftUI

// MARK: ─── AddTaskView ────────────────────────────────────────────────────────
struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var taskTitle = ""
    @State private var description = ""

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
                    .padding(.bottom, 32)

                SectionLabel("DESCRIPTION")
                TextEditor(text: $description)
                    .foregroundColor(.white)
                    .frame(minHeight: 120)
                    .padding(16)
                    .background(Colors.bgSecondary)
                    .cornerRadius(16)
                    .padding(.bottom, 32)

                HStack(spacing: 16) {
                    InfoTile(icon: "calendar", label: "DUE DATE", value: "Today")
                    InfoTile(icon: "clock",    label: "TIME",     value: "12:00 PM")
                }
                .padding(.bottom, 48)

                NavigationLink(destination: SuccessView()) {
                    Text("Save Task")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(16)
                        .background(Colors.accentTeal).cornerRadius(16)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
    }
}

// MARK: ─── AddMembersView ─────────────────────────────────────────────────────
struct AddMembersView: View {
    @Environment(\.dismiss) private var dismiss

    let selected = [
        ("Alex",   "https://i.pravatar.cc/150?img=47"),
        ("Jordan", "https://i.pravatar.cc/150?img=11"),
        ("Sarah",  "https://i.pravatar.cc/150?img=5"),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                BackHeader(title: "Add Members")
                    .padding(.bottom, 32)

                TextField("Search name, email, or phone..", text: .constant(""))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Colors.bgSecondary)
                    .cornerRadius(16)
                    .padding(.bottom, 24)

                NavigationLink(destination: InviteLinkView()) {
                    HStack(spacing: 8) {
                        Image(systemName: "link").font(.system(size: 14)).foregroundColor(Colors.accentTeal)
                        Text("Invite via link").font(.system(size: 12)).foregroundColor(Colors.accentTeal)
                    }
                    .padding(.vertical, 8).padding(.horizontal, 16)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Colors.accentTeal, lineWidth: 1))
                }
                .padding(.bottom, 32)

                SectionLabel("SELECTED")
                    .padding(.bottom, 24)

                HStack(spacing: 24) {
                    ForEach(selected, id: \.0) { name, url in
                        VStack(spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                AsyncImage(url: URL(string: url)) { img in img.resizable().scaledToFill() }
                                placeholder: { Circle().fill(Colors.bgSecondary) }
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Colors.accentTeal, lineWidth: 2))

                                ZStack {
                                    Circle().fill(Color(hex: "#4C4C4E"))
                                        .frame(width: 20, height: 20)
                                        .overlay(Circle().stroke(Colors.bgPrimary, lineWidth: 2))
                                    Image(systemName: "xmark").font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                                }
                                .offset(x: 6, y: -6)
                            }
                            Text(name).font(.system(size: 12)).foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 40)

                SectionLabel("SUGGESTED")
                    .padding(.bottom, 24)

                HStack {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Colors.bgSecondary)
                                .frame(width: 56, height: 56)
                            Text("M").font(.system(size: 18, weight: .semibold)).foregroundColor(Colors.accentTeal)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Marcus Aurelius").font(.system(size: 16, weight: .medium)).foregroundColor(.white)
                            Text("marcus@philosophy.org").font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                        }
                    }
                    Spacer()
                    Button { } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                            .foregroundColor(Colors.textSecondary)
                            .frame(width: 32, height: 32)
                            .overlay(Circle().stroke(Colors.textSecondary, lineWidth: 1))
                    }
                }

                Button { dismiss() } label: {
                    Text("Add Members (3)")
                        .font(.system(size: 14, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(16)
                        .background(Colors.accentTeal).cornerRadius(16)
                }
                .padding(.top, 40)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
    }
}

// MARK: ─── InviteLinkView ────────────────────────────────────────────────────
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

                // QR + header
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

                // Link bar
                HStack {
                    Text("https://eventflow.app/inv/q8x9z2...")
                        .font(.system(size: 13)).foregroundColor(.white)
                        .lineLimit(1)
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
                .background(Color(hex: "#252527"))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
                .padding(.bottom, 24)

                // Share via
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

                // Buttons
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
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
    }
}

// MARK: ─── AddLocationView ───────────────────────────────────────────────────
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
                BackHeader(title: "Add Location")
                    .padding(.bottom, 20)

                // Mini map placeholder
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "#141416"))
                        .frame(height: 320)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.06), lineWidth: 1))

                    // Grid lines (decorative)
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
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                    // Pin
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 42))
                        .foregroundColor(Colors.accentTeal)
                        .shadow(color: Colors.accentTeal.opacity(0.4), radius: 12)
                        .offset(y: 120)

                    // Search overlay
                    VStack(spacing: 6) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass").foregroundColor(Color(hex: "#888888"))
                            TextField("Search location...", text: $searchQuery)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            if !searchQuery.isEmpty {
                                Button { searchQuery = "" } label: {
                                    Image(systemName: "xmark").font(.system(size: 12)).foregroundColor(Color(hex: "#aaaaaa"))
                                }
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Color(hex: "#16161A").opacity(0.95))
                        .cornerRadius(14)
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
                            .background(Color(hex: "#16161A").opacity(0.97))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.07), lineWidth: 1))
                        }
                    }
                    .padding(14)
                }
                .padding(.bottom, 24)

                // Toggle card
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
                    Toggle("", isOn: $remind)
                        .tint(Colors.accentTeal)
                }
                .padding(18)
                .background(Colors.bgSecondary)
                .cornerRadius(20)
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
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
    }
}

// MARK: ─── SuccessView ───────────────────────────────────────────────────────
struct SuccessView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle().fill(Colors.accentTeal.opacity(0.1)).frame(width: 160, height: 160)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Colors.accentTeal)
            }
            .padding(.bottom, 32)

            Text("Success!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Colors.textPrimary)
                .padding(.bottom, 16)

            Text("Your event has been successfully created\nand saved to your calendar.")
                .font(.system(size: 15))
                .foregroundColor(Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
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

// MARK: ─── Shared sub-components ─────────────────────────────────────────────
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
