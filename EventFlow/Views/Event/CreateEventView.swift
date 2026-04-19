//
//  CreateEventView.swift
//  EventFlow
//
//  Created by Thiya on 2026-04-19.
//


import SwiftUI

struct CreateEventView: View {
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss


    @State private var eventName = ""
    @State private var selectedDate = Date()
    @State private var selectedHour = 9
    @State private var selectedMinute = 30
    @State private var selectedPeriod = 0

    @State private var isSaving     = false
    @State private var showSuccess  = false

    private var stripDates: [Date] {
        (-2...2).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: Date()) }
    }


    private var builtStartDate: Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        var hour  = selectedHour % 12
        if selectedPeriod == 1 { hour += 12 }
        comps.hour   = hour
        comps.minute = selectedMinute
        return Calendar.current.date(from: comps) ?? selectedDate
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                 
                    HStack {
                        Button { dismiss(); onDismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                        }
                        Text("New Event")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.leading, 16)
                        Spacer()
                    }
                    .padding(.bottom, 32)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("EVENT ESSENCE")
                            .font(.system(size: 12))
                            .kerning(1)
                            .foregroundColor(Colors.textSecondary)
                        TextField("What are we planning?", text: $eventName)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .accentColor(Colors.accentTeal)
                        Divider().background(Color(hex: "#333333"))
                    }
                    .padding(.bottom, 32)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            HStack(spacing: 8) {
                                Circle().fill(Colors.accentTeal).frame(width: 8, height: 8)
                                Text("SELECT DATE")
                                    .font(.system(size: 12)).kerning(1)
                                    .foregroundColor(Colors.accentTeal)
                            }
                            Spacer()
                            Text(selectedDate, format: .dateTime.month(.wide).year())
                                .font(.system(size: 12))
                                .foregroundColor(Colors.textSecondary)
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(stripDates, id: \.self) { d in
                                    let isSelected = Calendar.current.isDate(d, inSameDayAs: selectedDate)
                                    let day = Calendar.current.component(.weekday, from: d) - 1
                                    let num = Calendar.current.component(.day, from: d)
                                    let dNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

                                    Button { selectedDate = d } label: {
                                        VStack(spacing: 4) {
                                            Text(dNames[day])
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(isSelected ? Color.black.opacity(0.7) : Color.white.opacity(0.5))
                                            Text("\(num)")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(isSelected ? .black : .white)
                                        }
                                        .frame(width: 56, height: 72)
                                        .background(isSelected ? Colors.accentTeal : Colors.bgSecondary)
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 32)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Circle().fill(Colors.accentTeal).frame(width: 8, height: 8)
                            Text("SET TIME")
                                .font(.system(size: 12)).kerning(1)
                                .foregroundColor(Colors.accentTeal)
                        }

                        let hrs  = (1...12).map { String(format: "%02d", $0) }
                        let mins = stride(from: 0, to: 60, by: 5).map { String(format: "%02d", $0) }

                        Text("\(hrs[selectedHour - 1]):\(mins[selectedMinute / 5]) \(selectedPeriod == 0 ? "AM" : "PM")")
                            .font(.system(size: 13))
                            .foregroundColor(Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)

                        HStack(spacing: 4) {
                            Picker("Hour", selection: $selectedHour) {
                                ForEach(1...12, id: \.self) { h in
                                    Text(String(format: "%02d", h)).tag(h)
                                        .font(.system(size: 24, weight: .bold))
                                }
                            }
                            .pickerStyle(.wheel).frame(width: 72).clipped()

                            Text(":").font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.4))

                            Picker("Minute", selection: $selectedMinute) {
                                ForEach(stride(from: 0, to: 60, by: 5).map { $0 }, id: \.self) { m in
                                    Text(String(format: "%02d", m)).tag(m)
                                        .font(.system(size: 24, weight: .bold))
                                }
                            }
                            .pickerStyle(.wheel).frame(width: 72).clipped()

                            Divider()
                                .frame(width: 1, height: 60)
                                .background(Color.white.opacity(0.07))

                            Picker("Period", selection: $selectedPeriod) {
                                Text("AM").tag(0)
                                Text("PM").tag(1)
                            }
                            .pickerStyle(.wheel).frame(width: 72).clipped()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.07), lineWidth: 1))
                    }
                    .padding(.bottom, 32)

                    HStack(spacing: 16) {
                        NavigationLink(destination: AddTaskView()) {
                            Text("+ ATTACH TASKS")
                                .font(.system(size: 10, weight: .semibold)).kerning(1)
                                .foregroundColor(Colors.accentTeal)
                                .frame(maxWidth: .infinity).padding(12)
                                .background(Colors.bgSecondary).cornerRadius(16)
                        }
                        NavigationLink(destination: AddMembersView()) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 14)).foregroundColor(Colors.accentTeal)
                                Text("INVITE")
                                    .font(.system(size: 10, weight: .semibold)).kerning(1)
                                    .foregroundColor(Colors.accentTeal)
                            }
                            .frame(maxWidth: .infinity).padding(12)
                            .background(Colors.bgSecondary).cornerRadius(16)
                        }
                    }
                    .padding(.bottom, 16)

                    HStack(spacing: 16) {

                        Button {
                            guard !eventName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            isSaving = true
                            Task {
                                let start = builtStartDate
                                let end   = Calendar.current.date(byAdding: .hour, value: 1, to: start) ?? start
                                await store.createEvent(
                                    title:     eventName,
                                    tag:       "EVENT",
                                    location:  "",
                                    startTime: start,
                                    endTime:   end
                                )
                                isSaving    = false
                                showSuccess = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        .scaleEffect(0.8)
                                }
                                Text(isSaving ? "Saving..." : "Create Event")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(eventName.isEmpty ? Colors.accentTeal.opacity(0.5) : Colors.accentTeal)
                            .cornerRadius(12)
                        }
                        .disabled(eventName.isEmpty || isSaving)
                        .navigationDestination(isPresented: $showSuccess) {
                            SuccessView()
                        }
  
                        NavigationLink(destination: AddLocationView()) {
                            Text("Add Location")
                                .font(.system(size: 14, weight: .semibold)).foregroundColor(.black)
                                .frame(maxWidth: .infinity).padding(16)
                                .background(Color(hex: "#8E9092")).cornerRadius(12)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .background(Colors.bgPrimary)
        }
    }
}
