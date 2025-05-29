//  CircleRing.swift
//  Hookline
//  Created by Pulkit Jain on 21/4/2025.
import SwiftUI
struct ChordRing: View {
    let items: [String]
    let radius: CGFloat
    @Binding var selectedItem: String
    var color: Color
    var font: Font

    var body: some View {
        ZStack {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                let angle = Angle(degrees: Double(index) / Double(items.count) * 360)
                let x = cos(angle.radians) * radius
                let y = sin(angle.radians) * radius

                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedItem = item
                    }
                }) {
                    Text(item)
                        .font(font)
                        .foregroundColor(selectedItem == item ? .black : .white.opacity(0.85))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(selectedItem == item ? color.opacity(0.85) : Color.clear)
                                .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                                .shadow(color: selectedItem == item ? color.opacity(0.4) : .clear, radius: 5)
                        )
                        .scaleEffect(selectedItem == item ? 1.2 : 1)
                }
                .position(x: 160 + x, y: 160 + y)
            }
        }
    }
}
struct RingOverlay: View {
    let radius: CGFloat
    let color: Color

    var body: some View {
        Circle()
            .stroke(color.opacity(0.15), lineWidth: 2)
            .frame(width: radius * 2, height: radius * 2)
    }
}
struct RadialDividers: View {
    let count: Int
    let radius: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 1, height: radius)
                    .offset(y: -radius / 2)
                    .rotationEffect(.degrees(Double(i) / Double(count) * 360))
            }
        }
    }
}
