// SplashView.swift

import SwiftUI

struct SplashView: View {
    let onExplore: () -> Void

    var body: some View {
        ZStack {
            Colors.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
    
                HStack(spacing: 0) {
                    Text("Event")
                        .foregroundColor(Colors.textPrimary)
                    Text("Flow")
                        .foregroundColor(Colors.accentTeal)
                }
                .font(.system(size: 42, weight: .black))
                .kerning(-0.5)
                .padding(.bottom, 16)

                Text("Smart reminders where it matters")
                    .foregroundColor(Colors.textPrimary)
                    .font(.system(size: 15))
                    .padding(.bottom, 48)

                Button(action: onExplore) {
                    Text("Explore")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 200)
                        .padding(.vertical, 16)
                        .background(Colors.accentTeal)
                        .cornerRadius(12)
                }
            }
        }
    }
}
