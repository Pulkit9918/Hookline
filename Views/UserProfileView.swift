//  UserProfileView.swift
//  Hookline
//  Created by Pulkit Jain on 16/4/2025.
import SwiftUI
import Charts
struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: SongStore

    @State private var isEditing = false
    @AppStorage("username") private var username: String = "Username"
    @AppStorage("bioNote") private var bioNote: String = ""

    @State private var errorMessage: String? = nil

    let existingUsernames: [String] = ["johnsmith", "musiclover", "Username"]

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
                        Text("Profile")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Button(isEditing ? "Done" : "Edit") {
                            if isEditing {
                                if validateInputs() {
                                    isEditing = false
                                }
                            } else {
                                withAnimation { isEditing.toggle() }
                                errorMessage = nil
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.top, 6)
                    VStack(spacing: 16) {
                        if isEditing {
                            TextField("Username", text: $username)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            
                            TextField("Artist Bio (optional)", text: $bioNote, axis: .vertical)
                                .lineLimit(3...5)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        } else {
                            Text(username)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            
                            if !bioNote.isEmpty {
                                Text(bioNote)
                                    .font(.custom("Palatino-Italic", size: 18))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        Text("Songwriting Progress")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        
                        HStack(spacing: 32) {
                            SpiralProgressView(title: "Total", count: store.songs.count, color: .blue, max: max(1, store.songs.count))
                            SpiralProgressView(title: "Completed", count: completedSongs.count, color: .green, max: max(1, store.songs.count))
                            SpiralProgressView(title: "Drafts", count: draftSongs.count, color: .yellow, max: max(1, store.songs.count))

                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal)
                    VStack(spacing: 16) {
                        Text("Extras")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        
                        statRow(title: "Total Words", value: "\(totalWords)")
                        statRow(title: "Longest Song", value: longestSong?.title ?? "—")
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("Song Types")
                                    .foregroundColor(.white)
                                    .bold()
                                    .padding(.bottom, 4)

                                Chart(songTypeDistribution) { data in
                                    SectorMark(
                                        angle: .value("Count", data.count),
                                        innerRadius: .ratio(0.5),
                                        angularInset: 1.5
                                    )
                                    .foregroundStyle(by: .value("Type", data.type))
                                }
                                .chartLegend(.visible)
                                .frame(height: 180)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)

                            VStack(alignment: .leading) {
                                Text("Mood Usage")
                                    .foregroundColor(.white)
                                    .bold()
                                    .padding(.bottom, 4)

                                Chart(moodDistribution) { data in
                                    SectorMark(
                                        angle: .value("Count", data.count),
                                        innerRadius: .ratio(0.5),
                                        angularInset: 1.5
                                    )
                                    .foregroundStyle(by: .value("Mood", data.mood))
                                }
                                .chartLegend(.visible)
                                .frame(height: 180)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)


                    }
                    Spacer()
                }
            }
            .padding(.top)
        }
    }
    var completedSongs: [Song] {
        store.songs.filter { $0.status == "Completed" }
    }

    var draftSongs: [Song] {
        store.songs.filter { $0.status == "Draft" || $0.status == "In Progress" }
    }

    var totalWords: Int {
        store.songs
            .map { $0.lyrics.split { $0.isWhitespace || $0.isNewline }.count }
            .reduce(0, +)
    }

    var longestSong: Song? {
        store.songs.max {
            $0.lyrics.split { $0.isWhitespace || $0.isNewline }.count <
            $1.lyrics.split { $0.isWhitespace || $0.isNewline }.count
        }
    }
    
    struct SongTypeData: Identifiable {
        let id = UUID()
        let type: String
        let count: Int
    }

    struct MoodData: Identifiable {
        let id = UUID()
        let mood: String
        let count: Int
    }

    var songTypeDistribution: [SongTypeData] {
        let grouped = Dictionary(grouping: store.songs, by: { $0.type.rawValue.capitalized })
        return grouped.map { SongTypeData(type: $0.key, count: $0.value.count) }
    }

    var moodDistribution: [MoodData] {
        let grouped = Dictionary(grouping: store.songs.map(\.mood), by: { $0 })
        return grouped.map { MoodData(mood: $0.key.capitalized, count: $0.value.count) }
    }

    func validateInputs() -> Bool {
        if existingUsernames.contains(username) && username != "Username" {
            errorMessage = "This username is already taken."
            return false
        }
        errorMessage = nil
        return true
    }

    func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .bold()
        }
        .padding()
        .background(Color.white.opacity(0.04))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
