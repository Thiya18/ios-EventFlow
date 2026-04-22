//
//  EventDetailsView.swift
//  EventFlow
//
//  Created by Thiya on 2026-04-23.
//


import SwiftUI

struct EventDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22)).foregroundColor(.white)
                        }
                        Text("Event Details")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
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

                // Event card
                VStack(alignment: .leading, spacing: 0) {
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=800&q=80")) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Rectangle().fill(Colors.bgSecondary)
                    }
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .opacity(0.6)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("REVIEW")
                            .font(.system(size: 10, weight: .bold)).kerning(1)
                            .foregroundColor(.black)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Colors.accentTeal)
                            .cornerRadius(12)

                        Text("Final QA Review")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            Image(systemName: "clock").font(.system(size: 16)).foregroundColor(Colors.textSecondary)
                            Text("02:00 PM — 03:00 PM").font(.system(size: 14)).foregroundColor(Colors.textSecondary)
                        }
                        HStack(spacing: 12) {
                            Image(systemName: "video").font(.system(size: 16)).foregroundColor(Colors.textSecondary)
                            Text("Google Meet").font(.system(size: 14)).foregroundColor(Colors.textSecondary)
                        }
                    }
                    .padding(24)
                }
                .background(Colors.bgSecondary)
                .cornerRadius(24)
                .clipped()
                .padding(.bottom, 32)

                // Tasks
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Tasks")
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                        Spacer()
                        Text("1/2 Done")
                            .font(.system(size: 14, weight: .semibold)).foregroundColor(Colors.accentTeal)
                    }
                    .padding(.bottom, 24)

                    // Task items
                    DetailTaskRow(title: "Finalize UI and Prototypes", sub: "Due at 12:00 PM", subColor: Color(hex: "#FF5C5C"), done: false)
                    DetailTaskRow(title: "Design Documentation",       sub: "Completed",       subColor: Colors.textSecondary,   done: true)
                        .opacity(0.4)

                    NavigationLink(destination: AddTaskView()) {
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
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(Colors.bgPrimary)
        .navigationBarHidden(true)
    }
}

struct DetailTaskRow: View {
    let title: String
    let sub: String
    let subColor: Color
    let done: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "square")
                .font(.system(size: 20)).foregroundColor(Colors.textSecondary)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.system(size: 15)).foregroundColor(.white)
                HStack(spacing: 6) {
                    if !done {
                        Image(systemName: "alarm").font(.system(size: 12)).foregroundColor(subColor)
                    }
                    Text(sub).font(.system(size: 12)).foregroundColor(subColor)
                }
            }
            Spacer()
        }
        .padding(20)
        .background(Color(hex: "#252527"))
        .cornerRadius(16)
        .padding(.bottom, 12)
    }
}
