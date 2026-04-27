//
//  MapView.swift
//  EventFlow
//
//  Created by Thiya on 2026-04-27.
//

// MapView.swift
// EventFlow — Map with Real User Location + Location Reminder sheet

import SwiftUI
import MapKit
import CoreLocation
internal import Combine

// MARK: - LocationManager

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var objectWillChange = ObservableObjectPublisher()

    static let shared = LocationManager()

    private let manager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D? = nil
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String = ""

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 50
    }

    func requestPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            locationError = "Location access denied. Enable it in Settings → Privacy → Location."
        @unknown default:
            break
        }
    }

    func startUpdating() { manager.startUpdatingLocation() }
    func stopUpdating()  { manager.stopUpdatingLocation() }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation  = loc.coordinate
            self.locationError = ""
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.locationError = "Location access denied. Enable it in Settings → Privacy → Location."
            }
        default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = "Location error: \(error.localizedDescription)"
        }
    }
}

// MARK: - MapView

struct MapView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var locationManager = LocationManager.shared
    @State private var searchText    = ""
    @State private var activeEventId: Int? = nil

    // ── Location reminder sheet ──
    @State private var reminderEvent: EventModel? = nil
    @State private var showReminderSheet = false

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
        span:   MKCoordinateSpan(latitudeDelta: 2.5, longitudeDelta: 2.5)
    )

    var filteredAnnotations: [EventAnnotation] {
        let offsets: [(Double, Double)] = [
            (6.9271, 79.8612), (7.2906, 80.6337), (6.0535, 80.2210),
            (7.4818, 80.3609), (8.3114, 80.4037), (7.9403, 81.0188), (6.8270, 81.0393),
        ]
        let base = store.events.enumerated().compactMap { index, event -> EventAnnotation? in
            let pos = offsets[index % offsets.count]
            return EventAnnotation(
                id: event.id, title: event.title, tag: event.tag,
                time: event.time, location: event.location, color: event.accent,
                coordinate: CLLocationCoordinate2D(latitude: pos.0, longitude: pos.1)
            )
        }
        guard !searchText.isEmpty else { return base }
        return base.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText) ||
            $0.tag.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack(alignment: .top) {

            // ── Map ───────────────────────────────────────────────────────
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: filteredAnnotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    EventPinView(
                        annotation: annotation,
                        isActive: activeEventId == annotation.id,
                        onTap: {
                            withAnimation(.spring()) {
                                activeEventId = activeEventId == annotation.id ? nil : annotation.id
                            }
                        }
                    )
                }
            }
            .ignoresSafeArea()

            // ── Search bar ────────────────────────────────────────────────
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass").foregroundColor(Colors.textSecondary)
                    TextField("Search events nearby...", text: $searchText)
                        .foregroundColor(.white).font(.system(size: 14, weight: .medium))
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundColor(Colors.textSecondary)
                        }
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).fill(Colors.accentTeal).frame(width: 32, height: 32)
                        Image(systemName: "square.3.layers.3d").font(.system(size: 14)).foregroundColor(.black)
                    }
                }
                .padding(14)
                .background(Color(hex: "#1C1C1E").opacity(0.95))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
                .padding(.horizontal, 16).padding(.top, 16)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 4)

                if !locationManager.locationError.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "location.slash.fill").foregroundColor(.orange)
                        Text(locationManager.locationError).font(.system(size: 12)).foregroundColor(.orange)
                        Spacer()
                        Button("Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.system(size: 12, weight: .semibold)).foregroundColor(Colors.accentTeal)
                    }
                    .padding(12)
                    .background(Color(hex: "#1C1C1E").opacity(0.95)).cornerRadius(12)
                    .padding(.horizontal, 16).padding(.top, 8)
                }
                Spacer()
            }

            // ── FABs + event count ────────────────────────────────────────
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    HStack(spacing: 8) {
                        Circle().fill(Colors.accentTeal).frame(width: 8, height: 8)
                        Text("\(filteredAnnotations.count) event\(filteredAnnotations.count == 1 ? "" : "s")")
                            .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color(hex: "#1C1C1E").opacity(0.95)).cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))

                    Spacer()

                    VStack(spacing: 12) {
                        Button {
                            withAnimation {
                                if let coord = locationManager.userLocation {
                                    region = MKCoordinateRegion(
                                        center: coord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    )
                                } else {
                                    locationManager.requestPermission()
                                    region = MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
                                        span: MKCoordinateSpan(latitudeDelta: 2.5, longitudeDelta: 2.5)
                                    )
                                }
                            }
                        } label: {
                            Image(systemName: locationManager.userLocation != nil ? "location.fill" : "location")
                                .font(.system(size: 20)).foregroundColor(.black)
                                .frame(width: 52, height: 52).background(Colors.accentTeal).clipShape(Circle())
                                .shadow(color: Colors.accentTeal.opacity(0.35), radius: 12, y: 8)
                        }

                        Button {
                            withAnimation {
                                region = MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
                                    span: MKCoordinateSpan(latitudeDelta: 4.0, longitudeDelta: 4.0)
                                )
                            }
                        } label: {
                            Image(systemName: "mappin")
                                .font(.system(size: 20)).foregroundColor(.white)
                                .frame(width: 52, height: 52)
                                .background(Color(hex: "#1C1C1E").opacity(0.92)).clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }

            // ── Selected event detail card ─────────────────────────────────
            if let id = activeEventId,
               let event = store.events.first(where: { $0.id == id }) {
                VStack {
                    Spacer()
                    EventDetailCard(
                        event: event,
                        onClose: { withAnimation { activeEventId = nil } },
                        onAddLocationReminder: {
                            reminderEvent       = event
                            showReminderSheet   = true
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 110)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear { locationManager.requestPermission() }
        .onDisappear { locationManager.stopUpdating() }
        // ── Location Reminder sheet ────────────────────────────────────────
        .sheet(isPresented: $showReminderSheet) {
            AddLocationReminderView(event: reminderEvent)
        }
    }
}

// MARK: - Map Annotation Model

struct EventAnnotation: Identifiable {
    let id:         Int
    let title:      String
    let tag:        String
    let time:       String
    let location:   String
    let color:      Color
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Event Pin View

struct EventPinView: View {
    let annotation: EventAnnotation
    let isActive:   Bool
    let onTap:      () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                if isActive {
                    Text(annotation.title)
                        .font(.system(size: 11, weight: .semibold)).foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color(hex: "#1C1C1E").opacity(0.95)).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(annotation.color.opacity(0.5), lineWidth: 1))
                        .shadow(color: .black.opacity(0.3), radius: 6)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.bottom, 4)
                }
                ZStack {
                    Circle()
                        .fill(annotation.color.opacity(0.2))
                        .frame(width: isActive ? 48 : 36, height: isActive ? 48 : 36)
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: isActive ? 32 : 26))
                        .foregroundColor(annotation.color)
                        .shadow(color: annotation.color.opacity(0.5), radius: 8)
                }
                .animation(.spring(response: 0.3), value: isActive)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Event Detail Card

struct EventDetailCard: View {
    let event:                 EventModel
    let onClose:               () -> Void
    var onAddLocationReminder: (() -> Void)? = nil

    // Demo coordinates per event
    private var eventCoords: (Double, Double) {
        let coords: [(Double, Double)] = [
            (6.9271, 79.8612), (7.2906, 80.6337), (6.0535, 80.2210),
            (7.4818, 80.3609), (8.3114, 80.4037), (7.9403, 81.0188), (6.8270, 81.0393),
        ]
        return coords[event.id % coords.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header row
            HStack {
                Text(event.tag)
                    .font(.system(size: 10, weight: .bold)).kerning(1)
                    .foregroundColor(event.accent)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(event.accent.opacity(0.15)).cornerRadius(10)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold)).foregroundColor(Colors.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.08)).clipShape(Circle())
                }
            }
            .padding(.bottom, 12)

            Text(event.title)
                .font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
                .padding(.bottom, 10)

            HStack(spacing: 8) {
                Image(systemName: "clock").font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                Text(event.time).font(.system(size: 13)).foregroundColor(Colors.textSecondary)
            }.padding(.bottom, 6)

            HStack(spacing: 8) {
                Image(systemName: "mappin").font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                Text(event.location.isEmpty ? "No location set" : event.location)
                    .font(.system(size: 13)).foregroundColor(Colors.textSecondary)
            }.padding(.bottom, 6)

            HStack(spacing: 8) {
                Image(systemName: "person.2").font(.system(size: 13)).foregroundColor(Colors.textSecondary)
                Text("\(event.members) member\(event.members == 1 ? "" : "s")")
                    .font(.system(size: 13)).foregroundColor(Colors.textSecondary)
            }.padding(.bottom, 14)

            // ── Add Location Reminder button ──────────────────────────────
            if let addReminder = onAddLocationReminder {
                Button(action: addReminder) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                        Text("Add Location Reminder")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Colors.accentTeal)
                    .cornerRadius(12)
                }
                .padding(.bottom, 14)
            }

            Rectangle()
                .fill(event.accent).frame(height: 3).cornerRadius(4)
        }
        .padding(20)
        .background(Color(hex: "#1C1C1E").opacity(0.97))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(event.accent.opacity(0.25), lineWidth: 1))
        .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
    }
}
