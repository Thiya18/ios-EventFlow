// AddLocationReminderView.swift
// EventFlow — Add Location Reminder with real map, search, and push notifications

import SwiftUI
import MapKit
import CoreLocation
import UserNotifications
internal import Combine


extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}


final class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published var results: [MKLocalSearchCompletion] = []
    @Published var isSearching = false
    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func search(_ query: String) {
        if query.isEmpty {
            results = []
            isSearching = false
        } else {
            isSearching = true
            completer.queryFragment = query
        }
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = completer.results
            self.isSearching = false
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.results = []
            self.isSearching = false
        }
    }

    func resolve(_ completion: MKLocalSearchCompletion) async -> (CLLocationCoordinate2D, String)? {
        let request = MKLocalSearch.Request(completion: completion)
        guard let response = try? await MKLocalSearch(request: request).start(),
              let item = response.mapItems.first else { return nil }
        let placemark = item.placemark
        let parts = [placemark.name, placemark.locality, placemark.administrativeArea, placemark.country]
            .compactMap { $0 }.filter { !$0.isEmpty }
        var seen = Set<String>()
        let address = parts.filter { seen.insert($0).inserted }.prefix(3).joined(separator: ", ")
        return (placemark.coordinate, address.isEmpty ? completion.title : address)
    }
}

// MARK: - User Location Manager
final class UserLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userCoordinate: CLLocationCoordinate2D? = nil
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async { self.userCoordinate = loc.coordinate }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { self.authStatus = manager.authorizationStatus }
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}


struct AddLocationReminderView: View {
    var event: EventModel? = nil

    @Environment(\.dismiss) private var dismiss
    @StateObject private var searchService = LocationSearchService()
    @StateObject private var locationMgr   = UserLocationManager()

    @State private var searchText   = ""
    @State private var showDropdown = false
    @FocusState private var focused: Bool

    @State private var selectedName  = ""
    @State private var selectedCoord: CLLocationCoordinate2D? = nil
    @State private var showMap       = false

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
        span:   MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var remindOnArrival   = true
    @State private var isSaving          = false
    @State private var saveSuccess       = false
    @State private var saveError         = ""
    @State private var mapCenteredOnUser = false

    private var canSave: Bool { selectedCoord != nil && remindOnArrival }

    var body: some View {
        ZStack(alignment: .top) {
            Colors.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {

             
                HStack(spacing: 12) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Text("Add Location Reminder")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    if showMap, locationMgr.userCoordinate != nil {
                        Button { centerOnUser() } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill").font(.system(size: 11))
                                Text("Me").font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(Colors.accentTeal)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Colors.accentTeal.opacity(0.15))
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

     
                if let event = event {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar").font(.system(size: 12)).foregroundColor(Colors.accentTeal)
                        Text("For: \(event.title)")
                            .font(.system(size: 12, weight: .medium)).foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Colors.accentTeal.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

               
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(showDropdown ? Colors.accentTeal : Colors.textSecondary)
                                .font(.system(size: 15))

                            TextField("Search location...", text: $searchText)
                                .foregroundColor(.white)
                                .font(.system(size: 15))
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($focused)
                                .onChange(of: searchText) { newVal in
                                    showDropdown = !newVal.isEmpty
                                    if !newVal.isEmpty && newVal != selectedName {
                                        selectedCoord = nil
                                        showMap = false
                                    }
                                    searchService.search(newVal)
                                }

                            if !searchText.isEmpty {
                                Button { clearAll() } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Colors.textSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                        .background(Color(hex: "#1C1C1E"))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(showDropdown ? Colors.accentTeal.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)

                        if showDropdown {
                            VStack(spacing: 0) {
                                if searchService.isSearching {
                                    HStack(spacing: 10) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Colors.accentTeal))
                                            .scaleEffect(0.8)
                                        Text("Searching...")
                                            .font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                                        Spacer()
                                    }.padding(16)
                                } else if searchService.results.isEmpty {
                                    HStack(spacing: 10) {
                                        Image(systemName: "magnifyingglass").foregroundColor(Colors.textSecondary)
                                        Text("No results found")
                                            .font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                                        Spacer()
                                    }.padding(16)
                                } else {
                                    ForEach(Array(searchService.results.prefix(6).enumerated()), id: \.offset) { idx, result in
                                        Button { selectResult(result) } label: {
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    Circle().fill(Colors.accentTeal.opacity(0.15)).frame(width: 36, height: 36)
                                                    Image(systemName: "mappin.circle.fill")
                                                        .foregroundColor(Colors.accentTeal).font(.system(size: 17))
                                                }
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(result.title)
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(.white).lineLimit(1)
                                                    if !result.subtitle.isEmpty {
                                                        Text(result.subtitle)
                                                            .font(.system(size: 12))
                                                            .foregroundColor(Colors.textSecondary).lineLimit(1)
                                                    }
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 11)).foregroundColor(Colors.textSecondary.opacity(0.6))
                                            }
                                            .padding(.horizontal, 14).padding(.vertical, 12)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        if idx < min(5, searchService.results.count - 1) {
                                            Divider().background(Color.white.opacity(0.06)).padding(.horizontal, 14)
                                        }
                                    }
                                }
                            }
                            .background(Color(hex: "#242426"))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Colors.accentTeal.opacity(0.3), lineWidth: 1))
                            .shadow(color: .black.opacity(0.5), radius: 16, x: 0, y: 8)
                            .padding(.horizontal, 16)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        if showMap, let coord = selectedCoord {
                            VStack(spacing: 0) {
                                // Selected location header
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Colors.accentTeal).font(.system(size: 16))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Selected Location")
                                            .font(.system(size: 11)).foregroundColor(Colors.textSecondary)
                                        Text(selectedName)
                                            .font(.system(size: 13, weight: .semibold)).foregroundColor(.white).lineLimit(2)
                                    }
                                    Spacer()
                                    Button { clearAll() } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Colors.textSecondary).font(.system(size: 18))
                                    }
                                }
                                .padding(.horizontal, 16).padding(.vertical, 12)
                                .background(Colors.accentTeal.opacity(0.1))

                                ZStack(alignment: .bottomTrailing) {
                                    Map(coordinateRegion: $region,
                                        showsUserLocation: true,
                                        annotationItems: [SelectedPin(coord: coord)]) { pin in
                                        MapAnnotation(coordinate: pin.coord) {
                                            VStack(spacing: 0) {
                                                ZStack {
                                                    Circle()
                                                        .fill(Colors.accentTeal)
                                                        .frame(width: 44, height: 44)
                                                        .shadow(color: Colors.accentTeal.opacity(0.7), radius: 12)
                                                    Image(systemName: "mappin.fill")
                                                        .font(.system(size: 22, weight: .bold))
                                                        .foregroundColor(.black)
                                                }
                                                Rectangle()
                                                    .fill(Colors.accentTeal)
                                                    .frame(width: 3, height: 10)
                                                Circle()
                                                    .fill(Colors.accentTeal.opacity(0.4))
                                                    .frame(width: 8, height: 8)
                                            }
                                        }
                                    }
                                    .frame(height: 260)

                                    if locationMgr.userCoordinate != nil {
                                        Button { centerOnUser() } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(hex: "#1C1C1E"))
                                                    .frame(width: 38, height: 38)
                                                    .shadow(color: .black.opacity(0.4), radius: 6)
                                                Image(systemName: "location.fill")
                                                    .font(.system(size: 15)).foregroundColor(Colors.accentTeal)
                                            }
                                        }.padding(10)
                                    }
                                }
                            }
                            .background(Color(hex: "#1C1C1E"))
                            .cornerRadius(20)
                            .overflow(hidden: true)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Colors.accentTeal.opacity(0.4), lineWidth: 1))
                            .padding(.horizontal, 16)
                            .transition(.opacity.combined(with: .scale(scale: 0.97)))

                            HStack(spacing: 8) {
                                Image(systemName: "circle.dashed")
                                    .foregroundColor(Colors.accentTeal).font(.system(size: 13))
                                Text("You'll get a push notification when you enter a 300m radius of this location.")
                                    .font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                            }
                            .padding(.horizontal, 20)
                            .transition(.opacity)

                        } else if !showDropdown {
                      
                            VStack(spacing: 14) {
                                ZStack {
                                    Circle().fill(Colors.accentTeal.opacity(0.1)).frame(width: 72, height: 72)
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 32)).foregroundColor(Colors.accentTeal.opacity(0.6))
                                }
                                Text("Search for a location above")
                                    .font(.system(size: 14, weight: .medium)).foregroundColor(Colors.textSecondary)
                                Text("Map will appear after selecting a result")
                                    .font(.system(size: 12)).foregroundColor(Colors.textSecondary.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity).frame(height: 200)
                            .background(Color(hex: "#1C1C1E")).cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07), lineWidth: 1))
                            .padding(.horizontal, 16)
                        }

                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.06)).frame(width: 44, height: 44)
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 20)).foregroundColor(Colors.accentTeal)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Remind me when I arrive")
                                    .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                                Text("Push notification triggers upon entry")
                                    .font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: $remindOnArrival).tint(Colors.accentTeal).labelsHidden()
                        }
                        .padding(18)
                        .background(Color(hex: "#1C1C1E")).cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.07), lineWidth: 1))
                        .padding(.horizontal, 16)

                        if locationMgr.authStatus == .denied || locationMgr.authStatus == .restricted {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Colors.accentGold)
                                Text("Location permission denied. Enable in Settings → Privacy → Location.")
                                    .font(.system(size: 12)).foregroundColor(Colors.accentGold)
                                Spacer()
                                Button("Settings") {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .font(.system(size: 12, weight: .semibold)).foregroundColor(Colors.accentTeal)
                            }
                            .padding(14)
                            .background(Colors.accentGold.opacity(0.1)).cornerRadius(12)
                            .padding(.horizontal, 16)
                        }

                        if !saveError.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                                Text(saveError).font(.system(size: 13)).foregroundColor(.red)
                            }.padding(.horizontal, 20)
                        }

                        Button(action: saveReminder) {
                            ZStack {
                                if isSaving {
                                    HStack(spacing: 8) {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        Text("Saving...").font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                                    }
                                } else if saveSuccess {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Reminder Saved!")
                                            .font(.system(size: 16, weight: .bold))
                                    }.foregroundColor(.black)
                                } else {
                                    Text("Save Location Reminder")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(canSave ? .black : Colors.textSecondary)
                                }
                            }
                            .frame(maxWidth: .infinity).frame(height: 54)
                            .background(canSave ? Colors.accentTeal : Color(hex: "#1C1C1E"))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(canSave ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .disabled(!canSave || isSaving || saveSuccess)
                        .padding(.horizontal, 16).padding(.bottom, 40)
                    }
                    .animation(.easeInOut(duration: 0.3), value: showMap)
                    .animation(.easeInOut(duration: 0.2), value: showDropdown)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { locationMgr.requestLocation() }
        .onChange(of: locationMgr.userCoordinate) { newCoord in
            guard let coord = newCoord, !mapCenteredOnUser, selectedCoord == nil else { return }
            region = MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            mapCenteredOnUser = true
        }
    }


    private func clearAll() {
        searchText = ""; selectedName = ""; selectedCoord = nil
        showDropdown = false; showMap = false; saveError = ""
        saveSuccess = false; searchService.search(""); focused = false
    }

    private func centerOnUser() {
        guard let coord = locationMgr.userCoordinate else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }

    private func selectResult(_ result: MKLocalSearchCompletion) {
        showDropdown = false; focused = false
        searchText = result.title; saveError = ""
        Task {
            if let (coord, address) = await searchService.resolve(result) {
                await MainActor.run {
                    selectedCoord = coord
                    selectedName  = address
                    withAnimation(.easeInOut(duration: 0.45)) {
                        region = MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
                        )
                        showMap = true
                    }
                }
            } else {
                await MainActor.run {
                    saveError = "Could not find that location. Try a different search."
                }
            }
        }
    }


    private func saveReminder() {
        guard let coord = selectedCoord else { return }
        isSaving = true; saveError = ""

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    self.scheduleLocationNotification(coord: coord)
                } else {
                    self.saveError = "Notification permission denied. Enable in Settings."
                    self.isSaving = false
                }
            }
        }
    }

    private func scheduleLocationNotification(coord: CLLocationCoordinate2D) {
        let identifier = "loc_\(Int(coord.latitude * 10000))_\(Int(coord.longitude * 10000))"

        let content = UNMutableNotificationContent()
        content.title = event != nil
            ? "📍 You've arrived for \(event!.title)"
            : "📍 You've arrived!"
        content.body = event != nil
            ? "You're near \(selectedName) for your event \"\(event!.title)\"."
            : "You've reached \(selectedName). Your location reminder is active."
        content.sound = .default
        content.badge = 1

        let clRegion = CLCircularRegion(
            center: coord,
            radius: 300,
            identifier: identifier
        )
        clRegion.notifyOnEntry = true
        clRegion.notifyOnExit  = false

        let trigger = UNLocationNotificationTrigger(region: clRegion, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    self.saveError = "Could not schedule notification: \(error.localizedDescription)"
                } else {
                    self.saveSuccess = true
              
                    self.saveToLocalStorage(coord: coord, identifier: identifier)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.dismiss()
                    }
                }
            }
        }
    }

    private func saveToLocalStorage(coord: CLLocationCoordinate2D, identifier: String) {

        var reminders = UserDefaults.standard.array(forKey: "location_reminders") as? [[String: Any]] ?? []
        let entry: [String: Any] = [
            "id":          identifier,
            "name":        selectedName,
            "latitude":    coord.latitude,
            "longitude":   coord.longitude,
            "eventTitle":  event?.title ?? "",
            "createdAt":   ISO8601DateFormatter().string(from: Date())
        ]
        reminders.append(entry)
        UserDefaults.standard.set(reminders, forKey: "location_reminders")
    }
}


struct SelectedPin: Identifiable {
    let id = UUID()
    let coord: CLLocationCoordinate2D
}


extension View {
    func overflow(hidden: Bool) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: hidden ? 20 : 0))
    }
}
