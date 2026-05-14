
import SwiftUI

struct AllEventsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Colors.textPrimary)
                    }
                    Text("All Events")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Colors.textPrimary)
                        .padding(.leading, 16)
                    Spacer()
                    Text("\(store.events.count)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Colors.textSecondary)
                }
                .padding(.bottom, 28)

                if store.events.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(Colors.textSecondary)
                        Text("No events yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Colors.textSecondary)
                        Text("Tap + to create your first event")
                            .font(.system(size: 13))
                            .foregroundColor(Colors.textSecondary.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(48)
                } else {
                    // All events, newest first (sorted in AppStore.loadEvents)
                    ForEach(store.events) { event in
                        NavigationLink(destination: EventDetailsView(event: event)) {
                            LiveEventCardHome(event: event)
                        }
                        .padding(.bottom, 12)
                    }
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
    }
}
