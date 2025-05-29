//  ChordPickerView.swift
//  Hookline
//  Created by Pulkit Jain on 21/4/2025.
import SwiftUI
struct ChordPickerView: View {
    let onInsert: (String) -> Void
    let mood: SongMood

    @Environment(\.dismiss) var dismiss
    @State private var selectedRoot: String = "C"
    @State private var selectedType: String = ""

    let rootNotes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let chordTypes = ["", "m", "7", "5", "dim", "dim7", "aug", "sus2", "sus4", "maj7", "m7", "7sus4"]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: mood.gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                            .padding()
                    }
                }

                Text("Select Chord")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                HStack(spacing: 16) {
                    Picker("Root", selection: $selectedRoot) {
                        ForEach(rootNotes, id: \.self) { Text($0) }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                    .clipped()

                    Picker("Type", selection: $selectedType) {
                        ForEach(chordTypes, id: \.self) {
                            Text($0.isEmpty ? "maj" : $0)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 120)
                    .clipped()
                }

                Text("Result: \(selectedRoot)\(selectedType)")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top)

                Button(action: {
                    onInsert("\(selectedRoot)\(selectedType)")
                    dismiss()
                }) {
                    Text("Insert Chord")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)

                Spacer()
            }
        }
    }
}
