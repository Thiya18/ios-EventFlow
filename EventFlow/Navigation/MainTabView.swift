// MainTabView.swift
// Bottom tab bar — mirrors Tab.Navigator in App.tsx

import SwiftUI

struct MainTabView: View {
    let onSignOut: () -> Void
    @State private var selectedTab: Tab = .home

    enum Tab: Int {
        case home, calendar, create, map, profile
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:     HomeView()
                case .calendar: CalendarView()
                case .create:   CreateEventView(onDismiss: { selectedTab = .home })
                case .map:      MapView()
                case .profile:  ProfileView(onSignOut: onSignOut)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selected: $selectedTab)
        }
        .background(Colors.bgPrimary.ignoresSafeArea())
        .ignoresSafeArea(edges: .bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selected: MainTabView.Tab

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(icon: "house.fill",       tab: .home,     selected: $selected)
            TabBarItem(icon: "calendar",          tab: .calendar, selected: $selected)

            Button {
                selected = .create
            } label: {
                ZStack {
                    Circle()
                        .fill(Colors.accentTeal)
                        .frame(width: 60, height: 60)
                        .shadow(color: Colors.accentTeal.opacity(0.4), radius: 16, y: 8)
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                }
                .offset(y: -16)
            }
            .frame(maxWidth: .infinity)

            TabBarItem(icon: "map.fill",          tab: .map,      selected: $selected)
            TabBarItem(icon: "person.fill",        tab: .profile,  selected: $selected)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 28)
        .padding(.top, 12)
        .background(
            Colors.bgSecondary
                .clipShape(RoundedCornersShape(corners: [.topLeft, .topRight], radius: 32))
                .shadow(color: .black.opacity(0.3), radius: 12, y: -4)
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let tab: MainTabView.Tab
    @Binding var selected: MainTabView.Tab

    var isActive: Bool { selected == tab }

    var body: some View {
        Button { selected = tab } label: {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(isActive ? Colors.accentTeal : Colors.textSecondary)
                .frame(maxWidth: .infinity)
        }
    }
}


struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
