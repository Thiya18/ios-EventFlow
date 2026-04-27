//
//  AddLocationReminderView.swift
//  EventFlow
//
//  Created by Thiya on 2026-04-27.
//


import SwiftUI
import MapKit
import CoreLocation
internal import Combine

// MARK: - Location Reminder Model

struct LocationReminder: Codable, Identifiable {
    let id: String?
    let userId: String
    let locationName: String
    let latitude: Double
    let longitude: Double
    let radiusMeters: Double
    let eventId: String?
    let eventTitle: String?
    let createdAt: Date
    
    init(id: String? = nil, userId: String, locationName: String, latitude: Double, longitude: Double, radiusMeters: Double, eventId: String? = nil, eventTitle: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
        self.eventId = eventId
        self.eventTitle = eventTitle
        self.createdAt = createdAt
    }
}

// MARK: - Location Reminder Service

class LocationReminderService: ObservableObject {
    static let shared = LocationReminderService()
    
    private let baseURL = "https://your-backend-url.com/api/reminders" // Replace with your actual backend URL
    
    private init() {}
    
    func saveReminder(locationName: String, latitude: Double, longitude: Double, radiusMeters: Double, eventId: String? = nil, eventTitle: String? = nil, completion: @escaping (Result<LocationReminder, Error>) -> Void) {
        
        // Get current user ID (you'll need to implement this based on your auth system)
        guard let userId = AuthManager.shared.currentUserId else {
            completion(.failure(NSError(domain: "LocationReminder", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let reminder = LocationReminder(
            userId: userId,
            locationName: locationName,
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters,
            eventId: eventId,
            eventTitle: eventTitle
        )
        
        // Convert to dictionary
        let parameters: [String: Any] = [
            "userId": reminder.userId,
            "locationName": reminder.locationName,
            "latitude": reminder.latitude,
            "longitude": reminder.longitude,
            "radiusMeters": reminder.radiusMeters,
            "eventId": reminder.eventId ?? NSNull(),
            "eventTitle": reminder.eventTitle ?? NSNull(),
            "createdAt": ISO8601DateFormatter().string(from: reminder.createdAt)
        ]
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "LocationReminder", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "LocationReminder", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                var savedReminder = reminder
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let id = json["id"] as? String {
                    savedReminder = LocationReminder(
                        id: id,
                        userId: reminder.userId,
                        locationName: reminder.locationName,
                        latitude: reminder.latitude,
                        longitude: reminder.longitude,
                        radiusMeters: reminder.radiusMeters,
                        eventId: reminder.eventId,
                        eventTitle: reminder.eventTitle,
                        createdAt: reminder.createdAt
                    )
                }
                completion(.success(savedReminder))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Auth Manager (placeholder - replace with your actual auth)

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    var currentUserId: String? {
        // Return the current user's ID from your authentication system
        // For example: UserDefaults.standard.string(forKey: "userId")
        return UserDefaults.standard.string(forKey: "userId") ?? "test_user_id"
    }
    
    private init() {}
}



class LocationNotificationManager {
    static let shared = LocationNotificationManager()
    
    private init() {}
    
    func scheduleLocationNotification(identifier: String, title: String, body: String, latitude: Double, longitude: Double, radiusMeters: Double) {
        // Implement your local notification scheduling here
        print("Scheduling location notification: \(title)")
        print("Location: \(latitude), \(longitude) with radius \(radiusMeters)m")
        
        // Request notification permissions if needed
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // Create the geographic region
                let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let region = CLCircularRegion(center: center, radius: radiusMeters, identifier: identifier)
                region.notifyOnEntry = true
                region.notifyOnExit = false
                
                // Create the trigger
                let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
                
                // Create the notification content
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                
                // Create the request
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                // Schedule the notification
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    } else {
                        print("Location notification scheduled successfully")
                    }
                }
            }
        }
    }
}

// MARK: - Equatable fix for onChange

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Location Search Service

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
        let search  = MKLocalSearch(request: request)
        guard let response = try? await search.start(),
              let item = response.mapItems.first else { return nil }
        let placemark = item.placemark
        let parts = [placemark.name, placemark.locality, placemark.administrativeArea, placemark.country]
            .compactMap { $0 }.filter { !$0.isEmpty }
        var seen = Set<String>()
        let unique = parts.filter { seen.insert($0).inserted }
        let address = unique.prefix(3).joined(separator: ", ")
        return (placemark.coordinate, address)
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
        manager.requestAlwaysAuthorization()
    }

    func requestLocation() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async { self.userCoordinate = loc.coordinate }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authStatus = manager.authorizationStatus
            switch manager.authorizationStatus {
            case .authorizedWhenInUse:
                manager.requestAlwaysAuthorization()
                manager.requestLocation()
            case .authorizedAlways:
                manager.requestLocation()
            default:
                break
            }
        }
    }
}


// MARK: - Main View

struct AddLocationReminderView: View {
    var event: EventModel? = nil

    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var searchService   = LocationSearchService()
    @StateObject private var locationMgr     = UserLocationManager()
    @StateObject private var reminderService = LocationReminderService.shared

    @State private var searchText     = ""
    @State private var showDropdown   = false
    @FocusState private var focused: Bool

    @State private var selectedName   = ""
    @State private var selectedCoord: CLLocationCoordinate2D? = nil
    @State private var showMap        = false

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
            span:   MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )

    @State private var remindOnArrival   = true
    @State private var isSaving          = false
    @State private var saveSuccess       = false
    @State private var saveError         = ""
    @State private var mapCenteredOnUser = false

    // DB save result feedback
    @State private var savedReminder: LocationReminder? = nil

    private var canSave: Bool { selectedCoord != nil && remindOnArrival }

    var body: some View {
        ZStack(alignment: .top) {
            Colors.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Nav bar ──────────────────────────────────────────────
                HStack(spacing: 12) {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Text("Add Location")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    if showMap, locationMgr.userCoordinate != nil {
                        Button { centerOnUser() } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill").font(.system(size: 11))
                                Text("My Location").font(.system(size: 12, weight: .medium))
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // ── Search bar ───────────────────────────────────
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
                                .onChange(of: searchText) { q in
                                    showDropdown = !q.isEmpty
                                    if !q.isEmpty && q != selectedName {
                                        selectedCoord = nil
                                        showMap = false
                                    }
                                    searchService.search(q)
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

                        // ── Dropdown ─────────────────────────────────────
                        if showDropdown {
                            VStack(spacing: 0) {
                                if searchService.isSearching {
                                    HStack(spacing: 10) {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Colors.accentTeal)).scaleEffect(0.8)
                                        Text("Searching...").font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                                        Spacer()
                                    }.padding(16)
                                } else if searchService.results.isEmpty {
                                    HStack(spacing: 10) {
                                        Image(systemName: "magnifyingglass").foregroundColor(Colors.textSecondary)
                                        Text("No results found").font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                                        Spacer()
                                    }.padding(16)
                                } else {
                                    ForEach(Array(searchService.results.prefix(6).enumerated()), id: \.offset) { idx, result in
                                        Button { selectResult(result) } label: {
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    Circle().fill(Colors.accentTeal.opacity(0.15)).frame(width: 36, height: 36)
                                                    Image(systemName: "mappin.circle.fill").foregroundColor(Colors.accentTeal).font(.system(size: 17))
                                                }
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(result.title).font(.system(size: 14, weight: .semibold)).foregroundColor(.white).lineLimit(1)
                                                    if !result.subtitle.isEmpty {
                                                        Text(result.subtitle).font(.system(size: 12)).foregroundColor(Colors.textSecondary).lineLimit(1)
                                                    }
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right").font(.system(size: 11)).foregroundColor(Colors.textSecondary.opacity(0.6))
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

                        // ── Map section ──────────────────────────────────
                        if showMap {
                            VStack(spacing: 0) {
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(Colors.accentTeal).font(.system(size: 16))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Selected Location").font(.system(size: 11)).foregroundColor(Colors.textSecondary)
                                        Text(selectedName).font(.system(size: 13, weight: .semibold)).foregroundColor(.white).lineLimit(2)
                                    }
                                    Spacer()
                                    Button { clearAll() } label: {
                                        Image(systemName: "xmark.circle.fill").foregroundColor(Colors.textSecondary).font(.system(size: 18))
                                    }
                                }
                                .padding(.horizontal, 16).padding(.vertical, 12)
                                .background(Colors.accentTeal.opacity(0.1))

                                ZStack(alignment: .bottomTrailing) {
                                    Map(position: $cameraPosition) {
                                        UserAnnotation()
                                        if let coord = selectedCoord {
                                            Annotation("", coordinate: coord, anchor: .bottom) {
                                                VStack(spacing: 0) {
                                                    ZStack {
                                                        Circle().fill(Colors.accentTeal).frame(width: 44, height: 44).shadow(color: Colors.accentTeal.opacity(0.7), radius: 12)
                                                        Image(systemName: "mappin.fill").font(.system(size: 22, weight: .bold)).foregroundColor(.black)
                                                    }
                                                    Rectangle().fill(Colors.accentTeal).frame(width: 3, height: 12)
                                                    Circle().fill(Colors.accentTeal.opacity(0.4)).frame(width: 8, height: 8)
                                                }
                                            }
                                        }
                                    }
                                    .mapStyle(.standard(elevation: .realistic))
                                    .frame(height: 260)

                                    if locationMgr.userCoordinate != nil {
                                        Button { centerOnUser() } label: {
                                            ZStack {
                                                Circle().fill(Color(hex: "#1C1C1E")).frame(width: 38, height: 38).shadow(color: .black.opacity(0.4), radius: 6)
                                                Image(systemName: "location.fill").font(.system(size: 15)).foregroundColor(Colors.accentTeal)
                                            }
                                        }.padding(10)
                                    }
                                }
                            }
                            .background(Color(hex: "#1C1C1E"))
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Colors.accentTeal.opacity(0.4), lineWidth: 1))
                            .padding(.horizontal, 16)
                            .transition(.opacity.combined(with: .scale(scale: 0.97)))

                            HStack(spacing: 8) {
                                Image(systemName: "circle.dashed").foregroundColor(Colors.accentTeal).font(.system(size: 13))
                                Text("You'll be notified when you enter a 300 m radius of this location.")
                                    .font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                            }
                            .padding(.horizontal, 20)
                            .transition(.opacity)

                            // ── Saved reminder info (after DB save) ─────
                            if let saved = savedReminder {
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.seal.fill").foregroundColor(Colors.accentTeal)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Saved to Database").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                                        if let id = saved.id {
                                            Text("ID: \(id)").font(.system(size: 10)).foregroundColor(Colors.textSecondary).lineLimit(1)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .background(Colors.accentTeal.opacity(0.1))
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Colors.accentTeal.opacity(0.3), lineWidth: 1))
                                .padding(.horizontal, 16)
                                .transition(.opacity.combined(with: .scale(scale: 0.97)))
                            }

                        } else if !showDropdown {
                            VStack(spacing: 14) {
                                ZStack {
                                    Circle().fill(Colors.accentTeal.opacity(0.1)).frame(width: 72, height: 72)
                                    Image(systemName: "mappin.and.ellipse").font(.system(size: 32)).foregroundColor(Colors.accentTeal.opacity(0.6))
                                }
                                Text("Search for a location above").font(.system(size: 14, weight: .medium)).foregroundColor(Colors.textSecondary)
                                Text("Map will appear after selecting a result").font(.system(size: 12)).foregroundColor(Colors.textSecondary.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity).frame(height: 200)
                            .background(Color(hex: "#1C1C1E")).cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07), lineWidth: 1))
                            .padding(.horizontal, 16)
                        }

                        // ── Remind toggle ────────────────────────────────
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.06)).frame(width: 44, height: 44)
                                Image(systemName: "arrow.right.circle").font(.system(size: 20)).foregroundColor(Colors.accentTeal)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Remind me\nwhen I arrive").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                                Text("Alert triggers\nupon entry").font(.system(size: 12)).foregroundColor(Colors.textSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: $remindOnArrival).tint(Colors.accentTeal).labelsHidden()
                        }
                        .padding(18)
                        .background(Color(hex: "#1C1C1E")).cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.07), lineWidth: 1))
                        .padding(.horizontal, 16)

                        // Permission warning
                        if locationMgr.authStatus == .denied || locationMgr.authStatus == .restricted {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Colors.accentGold)
                                Text("Location permission denied. Enable in Settings.").font(.system(size: 12)).foregroundColor(Colors.accentGold)
                            }
                            .padding(14).background(Colors.accentGold.opacity(0.1)).cornerRadius(12).padding(.horizontal, 16)
                        }

                        // Error
                        if !saveError.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(Colors.error)
                                Text(saveError).font(.system(size: 13)).foregroundColor(Colors.error)
                            }.padding(.horizontal, 20)
                        }

                        // ── Save button ──────────────────────────────────
                        Button(action: saveReminder) {
                            ZStack {
                                if isSaving {
                                    HStack(spacing: 8) {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        Text("Saving to Database…").font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                                    }
                                } else if saveSuccess {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Reminder Saved!").font(.system(size: 16, weight: .bold))
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
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(canSave ? Color.clear : Color.white.opacity(0.1), lineWidth: 1))
                        }
                        .disabled(!canSave || isSaving || saveSuccess)
                        .padding(.horizontal, 16).padding(.bottom, 40)
                    }
                    .animation(.easeInOut(duration: 0.3), value: showMap)
                    .animation(.easeInOut(duration: 0.2), value: showDropdown)
                    .animation(.easeInOut(duration: 0.3), value: savedReminder?.id)
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: locationMgr.userCoordinate) { coord in
            guard let coord = coord, !mapCenteredOnUser, selectedCoord == nil else { return }
            cameraPosition = .region(MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)))
            mapCenteredOnUser = true
        }
        .onAppear { locationMgr.requestLocation() }
    }

    // MARK: - Actions

    private func clearAll() {
        searchText = ""; selectedName = ""; selectedCoord = nil
        showDropdown = false; showMap = false; saveError = ""
        savedReminder = nil; saveSuccess = false
        searchService.search(""); focused = false
    }

    private func centerOnUser() {
        guard let coord = locationMgr.userCoordinate else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .region(MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
        }
    }

    private func selectResult(_ result: MKLocalSearchCompletion) {
        showDropdown = false; focused = false; searchText = result.title; saveError = ""
        Task {
            if let (coord, address) = await searchService.resolve(result) {
                await MainActor.run {
                    selectedCoord = coord
                    selectedName  = address.isEmpty ? result.title : address
                    withAnimation(.easeInOut(duration: 0.45)) {
                        cameraPosition = .region(MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)))
                        showMap = true
                    }
                }
            } else {
                await MainActor.run { saveError = "Could not find that location. Please try a different search." }
            }
        }
    }

    // MARK: - Save to Firebase (via backend)

    private func saveReminder() {
        guard let coord = selectedCoord else { return }
        isSaving = true; saveError = ""

        // 1. Schedule the local geofence notification
        let identifier = "loc_\(Int(coord.latitude * 10000))_\(Int(coord.longitude * 10000))"
        let notifTitle = event != nil ? "📍 You've arrived at \(selectedName)" : "📍 You've arrived!"
        let notifBody  = event != nil
            ? "You're at your destination for \"\(event!.title)\". Have a great time!"
            : "You've reached \(selectedName). Your location reminder is now complete."

        NotificationManager.shared.scheduleLocationNotification(
            identifier:   identifier,
            title:        notifTitle,
            body:         notifBody,
            latitude:     coord.latitude,
            longitude:    coord.longitude,
            radiusMeters: 300
        )

        // 2. Persist to Firebase via REST API
        LocationReminderService.shared.saveReminder(
            locationName: selectedName,
            latitude:     coord.latitude,
            longitude:    coord.longitude,
            radiusMeters: 300,
            eventId:      event != nil ? "\(event!.id)" : nil,
            eventTitle:   event?.title
        ) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success(let reminder):
                    savedReminder = reminder
                    saveSuccess   = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
                case .failure(let error):
                    // Still show success for local notification but flag DB error
                    saveError = "Saved locally but database error: \(error.localizedDescription)"
                    saveSuccess = true // local notif still set
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
