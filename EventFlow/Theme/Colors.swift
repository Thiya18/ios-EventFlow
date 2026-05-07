// Colors.swift
// EventFlow design tokens — mirrors src/theme/colors.ts

import SwiftUI

enum Colors {
    static let bgPrimary      = Color(hex: "#09090D")
    static let bgSecondary    = Color(hex: "#1C1C1E")
    static let accentTeal     = Color(hex: "#00CCBB")
    static let accentTealHover = Color(hex: "#00B3A4")
    static let accentGold     = Color(hex: "#FFC107")
    static let textPrimary    = Color(hex: "#FFFFFF")
    static let textSecondary  = Color(hex: "#8E8E93")
    static let navBg          = Color(hex: "#151515")
    static let error          = Color(hex: "#FF3B30")
    static let success        = Color(hex: "#30D158")
    static let purple         = Color(hex: "#6C63FF")
    static let pink           = Color(hex: "#E040FB")
    static let red            = Color(hex: "#FF453A")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
