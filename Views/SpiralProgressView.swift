//  SpiralProgressView.swift
//  Hookline
//  Created by Pulkit Jain on 19/4/2025.
import SwiftUI
struct SpiralProgressView: View {
    let title: String
    let count: Int
    let color: Color
    let max: Int

    @State private var animate = false

    var percentage: Double {
        guard max > 0 else { return 0 }
        return Double(count) / Double(max)
    }

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: animate ? percentage : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1), value: animate)

                Text("\(count)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(width: 60, height: 60)
            .onAppear {
                animate = true
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

