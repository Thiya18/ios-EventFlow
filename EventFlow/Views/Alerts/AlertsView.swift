// AlertsView.swift

import SwiftUI

struct AlertsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore
    @State private var filter: AlertFilter = .all

    enum AlertFilter { case all, unread }

    private var unreadCount: Int { store.alerts.filter { !$0.read }.count }
    private var visible: [AlertModel] {
        filter == .unread ? store.alerts.filter { !$0.read } : store.alerts
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    HStack(spacing: 8) {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22)).foregroundColor(Colors.textPrimary)
                        }
                        Text("Notifications")
                            .font(.system(size: 20, weight: .bold)).foregroundColor(Colors.textPrimary)
                        if unreadCount > 0 {
                            Text("\(unreadCount)")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8).padding(.vertical, 2)
                                .background(Colors.accentTeal)
                                .clipShape(Capsule())
                        }
                    }
                    Spacer()
                    if unreadCount > 0 {
                        Button {
                            Task { await store.markAllRead() }
                        } label: {
                            Text("Mark all read")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Colors.accentTeal)
                        }
                    }
                }
                .padding(.bottom, 28)

                
                HStack(spacing: 8) {
                    ForEach([AlertFilter.all, AlertFilter.unread], id: \.self) { f in
                        let label = f == .all ? "All" : (unreadCount > 0 ? "Unread (\(unreadCount))" : "Unread")
                        Button { filter = f } label: {
                            Text(label)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(filter == f ? .black : Colors.textSecondary)
                                .frame(maxWidth: .infinity).padding(.vertical, 9)
                                .background(filter == f ? Colors.accentTeal : Color.clear)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(4)
                .background(Colors.bgSecondary)
                .cornerRadius(14)
                .padding(.bottom, 24)

 
                if visible.isEmpty {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle().fill(Colors.bgSecondary).frame(width: 72, height: 72)
                            Image(systemName: "bell").font(.system(size: 32)).foregroundColor(Colors.textSecondary)
                        }
                        Text("You're all caught up!")
                            .font(.system(size: 14, weight: .medium)).foregroundColor(Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }

       
                ForEach(visible) { alert in
                    AlertCard(
                        alert: alert,
                        onTap:    { Task { await store.markRead(id: alert.id) } },
                        onDismiss:{ Task { await store.dismissAlert(id: alert.id) } },
                        onAction: { Task { await store.markRead(id: alert.id) } }
                    )
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
        .task { await store.loadAlerts() }
    }
}


struct AlertCard: View {
    let alert: AlertModel
    let onTap: () -> Void
    let onDismiss: () -> Void
    let onAction: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                HStack(alignment: .top, spacing: 14) {
 
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(alert.iconBg)
                            .frame(width: 46, height: 46)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(alert.iconColor.opacity(0.2), lineWidth: 1)
                            )
                        Image(systemName: alert.systemIcon)
                            .font(.system(size: 20))
                            .foregroundColor(alert.iconColor)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text(alert.tag)
                                .font(.system(size: 10, weight: .bold)).kerning(0.8)
                                .foregroundColor(alert.iconColor)
                            Spacer()
                            Text(alert.time)
                                .font(.system(size: 10)).foregroundColor(Colors.textSecondary)
                        }
                        .padding(.bottom, 5)

                        Text(alert.title)
                            .font(.system(size: 14, weight: alert.read ? .medium : .bold))
                            .foregroundColor(Colors.textPrimary)
                            .padding(.bottom, 4)

                        Text(alert.body)
                            .font(.system(size: 12))
                            .foregroundColor(Colors.textSecondary)
                            .lineSpacing(4)

                        if let actions = alert.actions {
                            HStack(spacing: 8) {
                                Button(action: onDismiss) {
                                    Text(actions[0])
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Colors.textSecondary)
                                        .frame(maxWidth: .infinity).padding(8)
                                        .background(Color.white.opacity(0.07))
                                        .cornerRadius(10)
                                }
                                Button(action: onAction) {
                                    Text(actions[1])
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(alert.iconColor)
                                        .frame(maxWidth: .infinity).padding(8)
                                        .background(alert.iconColor.opacity(0.13))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.top, 14)
                        }
                    }
                }
                .padding(16)

         
                if !alert.read {
                    Circle()
                        .fill(Colors.accentTeal)
                        .frame(width: 8, height: 8)
                        .padding(16)
                }
            }
            .background(alert.read ? Colors.bgSecondary : Color(hex: "#1f2024"))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(alert.read ? Color.white.opacity(0.05) : Colors.accentTeal.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, 12)
    }
}

extension AlertsView.AlertFilter: Hashable {}
