//  ChordReferenceView.swift
//  Hookline
//  Created by Pulkit Jain on 21/4/2025.
import SwiftUI
struct ChordReferenceView: View {
    @State private var selectedRoot: String = "C"
    @State private var selectedChordType: String = "Major"
    @State private var selectedAccidental: String = "♮"
    @State private var progression: [String] = []
    @State private var showRomanNumerals: Bool = false
    @State private var suggestedChords: [String] = []
    @State private var transposeOffset: Int = 0
    @State private var showCircleOfFifths = false
    @State private var selectedKey: String? = nil
    let rootNotes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let chordTypes = ["Major", "Minor", "7", "Maj7", "m7", "dim", "aug"]
    let enharmonicMap: [String: String] = [
        "B#": "C",  "Cb": "B",
        "E#": "F",  "Fb": "E",
        "D#": "Eb", "A#": "Bb", "G#": "Ab", "C#": "Db", "F#": "Gb",
        "Db": "C#", "Eb": "D#", "Gb": "F#", "Ab": "G#", "Bb": "A#"
    ]
    @ViewBuilder
    func chordDetailCard(for key: String) -> some View {
        let isMinor = key.contains("m") && !key.contains("maj")
        let displayKey = isMinor ? key : "\(key) major"
        let relative = isMinor ? relativeMajor(of: key) : relativeMinor(of: key)
        let parallel = isMinor ? key.replacingOccurrences(of: "m", with: "") : key + " minor"
        
        let chords: [(String, String, String)] = isMinor ? [
            ("i",     "tonic",        key),
            ("ii°",   "supertonic",   diminishedChord(from: key, offset: 2)),
            ("III",   "mediant",      majorChord(from: key, offset: 3)),
            ("iv",    "subdominant",  minorChord(from: key, offset: 5)),
            ("v",     "dominant",     minorChord(from: key, offset: 7)),
            ("VI",    "submediant",   majorChord(from: key, offset: 8)),
            ("VII",   "subtonic",     majorChord(from: key, offset: 10))
        ] : [
            ("I",    "tonic",        key),
            ("ii",   "supertonic",   minorChord(from: key, offset: 2)),
            ("iii",  "mediant",      minorChord(from: key, offset: 4)),
            ("IV",   "subdominant",  chord(from: key, offset: 5)),
            ("V",    "dominant",     chord(from: key, offset: 7)),
            ("vi",   "submediant",   minorChord(from: key, offset: 9)),
            ("vii°", "leading tone", diminishedChord(from: key, offset: 11))
        ]

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Key: \(displayKey)")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Relative key: \(relative). Parallel key: \(parallel).")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Button(action: {
                    withAnimation {
                        selectedKey = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(4)
                }
            }

            Divider().background(Color.white.opacity(0.1))

            VStack(spacing: 8) {
                HStack {
                    ForEach(chords, id: \.0) { (roman, _, _) in
                        Text(roman)
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                }
                HStack {
                    ForEach(chords, id: \.0) { (_, _, chord) in
                        Text(chord)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: "#10002B"), Color(hex: "#240046"), Color(hex: "#3C096C")]),
                center: .center,
                startRadius: 100,
                endRadius: 700
            )
            .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("Chord Reference")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        Spacer()
                        if !showCircleOfFifths, !progression.isEmpty {
                            HStack(spacing: 8) {
                                Button(action: { transpose(by: -1) }) {
                                    Text("−")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                }
                                Text("Transpose")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("\(transposeOffset >= 0 ? "+" : "")\(transposeOffset)")
                                            .font(.caption)
                                            .foregroundColor(transposeOffset == 0 ? .green : .white.opacity(0.7))
                                Button(action: { transpose(by: 1) }) {
                                    Text("+")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    VStack(spacing: 0) {
                        HStack {
                            Text(showCircleOfFifths ? "Circle of Fifths" : "Chord Compass")
                                .font(.title3.bold())
                                .foregroundColor(.white)

                            Spacer()

                            Button(action: {
//                                withAnimation { showCircleOfFifths.toggle() }
                                withAnimation {
                                        showCircleOfFifths.toggle()
                                        resetUIStateForViewSwitch()
                                    }
                            }) {
                                Image(systemName: "arrow.2.circlepath")
                                    .foregroundColor(.white.opacity(0.8))
                                    .imageScale(.medium)
                            }
                        }
                        .padding(.bottom, 8)
                        ZStack {
                            if !showCircleOfFifths {
                                chordCompassView
                                    .rotation3DEffect(.degrees(showCircleOfFifths ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                            } else {
                                circleOfFifthsView
                                    .rotation3DEffect(.degrees(showCircleOfFifths ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                            }
                        }
                        .animation(.easeInOut(duration: 0.6), value: showCircleOfFifths)
                        .frame(width: 320, height: 320)
                        if showCircleOfFifths, let key = selectedKey {
                            chordDetailCard(for: key)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .animation(.easeOut(duration: 0.4), value: selectedKey)
                                .padding(.top, 16)
                        }
                        if !showCircleOfFifths {
                            Button(action: addChord) {
                                Label("Add Chord", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .foregroundColor(.white)
                                    .background(Color.purple.opacity(0.8))
                                    .clipShape(Capsule())
                                    .shadow(color: .purple.opacity(0.4), radius: 6)
                            }
                            .padding(.top, 12)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.horizontal)
                    if !showCircleOfFifths, !progression.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Your Progression")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: {
                                    withAnimation { showRomanNumerals.toggle() }
                                }) {
                                    Image(systemName: "arrow.2.squarepath")
                                        .foregroundColor(.white)
                                        .imageScale(.medium)
                                        .rotationEffect(.degrees(showRomanNumerals ? 180 : 0))
                                }
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(progression.indices, id: \.self) { index in
                                        let chord = progression[index]
                                        let roman = romanNumeral(for: chord)
                                        let display = showRomanNumerals ? roman : chord
                                        let color = functionColor(roman)
                                        HStack(spacing: 6) {
                                            Text(display)
                                                .font(.subheadline)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(color.opacity(0.2))
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                            Button {
                                                progression.remove(at: index)
                                                if let lastChord = progression.last {
                                                    updateSuggestedChords(for: lastChord)
                                                } else {
                                                    suggestedChords = []
                                                }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            if !suggestedChords.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "wand.and.stars")
                                            .foregroundColor(.purple)
                                        Text("Suggested Next Chords")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white)
                                    }
                                    .padding(.leading)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(suggestedChords, id: \.self) { chord in
                                                Button(action: {
                                                    progression.append(chord)
                                                    updateSuggestedChords(for: chord)
                                                }) {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "plus.circle.fill")
                                                            .font(.caption)
                                                            .foregroundColor(.white.opacity(0.6))
                                                        Text(chord)
                                                            .font(.subheadline)
                                                    }
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 8)
                                                    .background(Color.purple.opacity(0.25))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                                    )
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.bottom)
                            }

                        }
                        .padding()
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        .padding(.horizontal)
                    }
                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
        }
    }
    var chordCompassView: some View {
        ZStack {
            RingOverlay(radius: 140, color: .blue)
            RingOverlay(radius: 95, color: .green)
            RadialDividers(count: rootNotes.count, radius: 140)
            ChordRing(items: rootNotes, radius: 140, selectedItem: $selectedRoot, color: .blue, font: .caption)
            ChordRing(items: chordTypes, radius: 95, selectedItem: $selectedChordType, color: .green, font: .caption2)

            VStack(spacing: 12) {
                ForEach(["♯", "♮", "♭"], id: \.self) { symbol in
                    Button(action: { selectedAccidental = symbol }) {
                        Text(symbol)
                            .font(.title2.bold())
                            .frame(width: 44, height: 44)
                            .background(selectedAccidental == symbol ? Color.purple.opacity(0.7) : Color.white.opacity(0.1))
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .frame(width: 320, height: 320)
    }
    var circleOfFifthsView: some View {
        let majorKeys = ["C", "G", "D", "A", "E", "B", "F♯", "D♭", "A♭", "E♭", "B♭", "F"]
        let minorKeys = ["Am", "Em", "Bm", "F♯m", "C♯m", "G♯m", "D♯m", "B♭m", "Fm", "Cm", "Gm", "Dm"]
        return ZStack {
            ForEach(0..<majorKeys.count, id: \.self) { i in
                let angle = Angle(degrees: Double(i) / Double(majorKeys.count) * 360.0 - 90)
                Text(majorKeys[i])
                    .font(.headline.bold())
                    .foregroundColor(selectedKey == majorKeys[i] ? .yellow : .white)
                    .scaleEffect(selectedKey == majorKeys[i] ? 1.2 : 1.0)
                    .onTapGesture {
                        selectedKey = majorKeys[i]
                    }
                    .position(
                        x: 160 + cos(angle.radians) * 110,
                        y: 160 + sin(angle.radians) * 110
                    )
            }
            ForEach(0..<minorKeys.count, id: \.self) { i in
                let angle = Angle(degrees: Double(i) / Double(minorKeys.count) * 360.0 - 90)
                Text(minorKeys[i])
                    .font(.caption)
                    .foregroundColor(selectedKey == minorKeys[i] ? .yellow : .white.opacity(0.75))
                    .scaleEffect(selectedKey == minorKeys[i] ? 1.15 : 1.0)
                    .onTapGesture {
                        selectedKey = minorKeys[i]
                    }
                    .position(
                        x: 160 + cos(angle.radians) * 75,
                        y: 160 + sin(angle.radians) * 75
                    )
            }
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 1.5)
                .frame(width: 220, height: 220)
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                .frame(width: 150, height: 150)
        }
        .frame(width: 320, height: 320)
    }
    func resetUIStateForViewSwitch() {
        if showCircleOfFifths {
            selectedKey = nil
        } else {
            progression = []
            transposeOffset = 0
            suggestedChords = []
            showRomanNumerals = false
        }
    }
    func addChord() {
        let accidental = selectedAccidental == "♮" ? "" : selectedAccidental
        let chord = "\(selectedRoot)\(accidental)\(chordSuffix(for: selectedChordType))"
        progression.append(chord)
        updateSuggestedChords(for: chord)
    }
    func chordSuffix(for type: String) -> String {
        switch type {
        case "Major": return ""
        case "Minor": return "m"
        default: return type
        }
    }
    func romanProgression() -> String {
        progression.map { romanNumeral(for: $0) }.joined(separator: " – ")
    }
    func romanNumeral(for chord: String) -> String {
        let base = chord.replacingOccurrences(of: "♯", with: "#").replacingOccurrences(of: "♭", with: "b")
        let root = base.prefix { $0.isLetter || $0 == "#" || $0 == "b" }
        let scale = ["C", "D", "E", "F", "G", "A", "B"]
        let numerals = ["I", "ii", "iii", "IV", "V", "vi", "vii°"]
        if let index = scale.firstIndex(of: String(root)) {
            return numerals[index]
        }
        return "–"
    }
    func functionColor(_ numeral: String) -> Color {
        switch numeral {
        case "I", "vi": return .green
        case "ii", "IV": return .blue
        case "V", "vii°": return .red
        default: return .gray
        }
    }
    func transpose(by semitones: Int) {
        progression = progression.map { chord in
            let base = chord.prefix { $0.isLetter || $0 == "#" || $0 == "b" }
            let suffix = chord.dropFirst(base.count)
            let currentIndex = rootNotes.firstIndex(of: String(base)) ?? 0
            let newIndex = (currentIndex + semitones + rootNotes.count) % rootNotes.count
            let newRoot = rootNotes[newIndex]
            return newRoot + suffix
        }
        transposeOffset += semitones
    }
    func relativeMajor(of key: String) -> String {
        let notes = rootNotes + rootNotes
        let base = normalizeKey(key)
        if let index = rootNotes.firstIndex(of: base) {
            return notes[(index + 3) % 12]
        }
        return "N/A"
    }
    func majorChord(from key: String, offset: Int) -> String {
        return chord(from: key, offset: offset)
    }
    func relativeMinor(of key: String) -> String {
        let notes = rootNotes + rootNotes
        let base = normalizeKey(key)
        if let index = rootNotes.firstIndex(of: base) {
            return notes[index + 9] + "m"
        }
        return "N/A"
    }
    func chord(from key: String, offset: Int) -> String {
        let notes = rootNotes + rootNotes
        let base = normalizeKey(key)
        guard let i = rootNotes.firstIndex(of: base) else { return "?" }
        return notes[i + offset]
    }
    func minorChord(from key: String, offset: Int) -> String {
        let root = chord(from: key, offset: offset)
        return root == "?" ? "?" : root + "m"
    }
    func diminishedChord(from key: String, offset: Int) -> String {
        let root = chord(from: key, offset: offset)
        return root == "?" ? "?" : root + "°"
    }
    func normalizeKey(_ key: String) -> String {
        let raw = key
                .replacingOccurrences(of: "♯", with: "#")
                .replacingOccurrences(of: "♭", with: "b")
                .replacingOccurrences(of: "m", with: "")
            return enharmonicMap[raw] ?? raw
    }
    func updateSuggestedChords(for chord: String) {
        let normalizedNotes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let base = chord.replacingOccurrences(of: "♯", with: "#").replacingOccurrences(of: "♭", with: "b")
        let root = String(base.prefix { $0.isLetter || $0 == "#" || $0 == "b" })
        guard let rootIndex = normalizedNotes.firstIndex(of: root) else {
            suggestedChords = []
            return
        }
        let modes: [String: ([Int], [String])] = [
            "Ionian":       ([0, 2, 4, 5, 7, 9, 11], ["", "m", "m", "", "", "m", "dim"]),
            "Dorian":       ([0, 2, 3, 5, 7, 9, 10], ["m", "m", "", "", "m", "dim", ""]),
            "Phrygian":     ([0, 1, 3, 5, 7, 8, 10], ["m", "", "", "m", "dim", "", "m"]),
            "Lydian":       ([0, 2, 4, 6, 7, 9, 11], ["", "", "m", "dim", "", "m", "m"]),
            "Mixolydian":   ([0, 2, 4, 5, 7, 9, 10], ["", "m", "dim", "", "m", "m", ""]),
            "Aeolian":      ([0, 2, 3, 5, 7, 8, 10], ["m", "dim", "", "m", "m", "", ""]),
            "Locrian":      ([0, 1, 3, 5, 6, 8, 10], ["dim", "", "m", "m", "", "", "m"]),
        ]
        let isMinorKey = chord.contains("m") && !chord.contains("maj")
        let modeName = isMinorKey ? "Aeolian" : "Ionian"
        let (intervals, chordTypes) = modes[modeName] ?? modes["Ionian"]!
        let scale = intervals.map { normalizedNotes[($0 + rootIndex) % 12] }
        let matchedIndex = scale.firstIndex { base.hasPrefix($0) } ?? 0
        let nextDegrees: [Int: [Int]] = [
            0: [3, 4, 5],
            5: [1, 3],
            1: [4],
            4: [0],
            3: [4, 5],
        ]
        let suggested = nextDegrees[matchedIndex] ?? [4, 0]
        suggestedChords = suggested.map { i in scale[i] + chordTypes[i] }
    }
}
