//  SongListView.swift
//  Hookline (Songs inside Folder View)
//  Created by Pulkit Jain on 14/5/2025.
import SwiftUI
struct SongFolder: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var type: FolderType = .custom
    var songIDs: [UUID]
    enum FolderType: String, Codable {
        case custom
        case ep
        case album
    }
}
struct SongListView: View {
    enum GroupingMode: String, CaseIterable, Identifiable {
        case none = "None"
        case status = "Status"
        case mood = "Mood"
        case type = "Type"
        
        var id: String { self.rawValue }
    }
    @State private var groupingMode: GroupingMode = .status
    @State private var showAddSongsSheet = false
    @State private var selectedSongsToAdd = Set<UUID>()
    var folder: SongFolder
    @EnvironmentObject var store: SongStore
    var body: some View {
        ScrollView {
                VStack(spacing: 16) {
                    Picker("Group by", selection: $groupingMode) {
                        ForEach(GroupingMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .tint(.white)
                    ForEach(groupedSongs, id: \.groupTitle) { group in
                        if groupingMode != .none && group.groupTitle != "All Songs" {
                            HStack {
                                Text(group.groupTitle)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.12))
                                    .clipShape(Capsule())
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(group.songs) { song in
                                ZStack {
                                    NavigationLink(destination: SongEditorView(song: binding(for: song), isNew: false)) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(song.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            Text(song.type.rawValue.capitalized)
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        .padding()
                                    }
                                    .contextMenu {
                                        if folder.type == .custom {
                                            Button("Remove from Folder", role: .destructive) {
                                                store.removeSongFromFolder(song.id, folderID: folder.id)
                                            }
                                        }
                                    }
                                }
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: SongMood.from(raw: song.mood).gradient.map { $0.opacity(0.35) }),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "#10002B"), Color(hex: "#240046"), Color(hex: "#3C096C")]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 700
                )
                .ignoresSafeArea()
            )
            .navigationTitle(folder.name)
            .toolbar {
                if folder.type == .custom {
                    Button {
                        showAddSongsSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        .sheet(isPresented: $showAddSongsSheet) {
            NavigationView {
                List(selection: $selectedSongsToAdd) {
                    ForEach(store.songs.filter { !folder.songIDs.contains($0.id) }) { song in
                        HStack {
                            Text(song.title)
                                .foregroundColor(.white)
                            Spacer()
                            Text(song.type.rawValue.capitalized)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                }
                .scrollContentBackground(.hidden)
                .background(
                    RadialGradient(
                        gradient: Gradient(colors: [Color(hex: "#10002B"), Color(hex: "#240046")]),
                        center: .center,
                        startRadius: 100,
                        endRadius: 700
                    ).ignoresSafeArea()
                )
                .environment(\.editMode, .constant(.active))
                .navigationTitle("")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Add Songs")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showAddSongsSheet = false
                            selectedSongsToAdd.removeAll()
                        }
                        .foregroundColor(.red)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            if let folderIndex = store.folders.firstIndex(where: { $0.id == folder.id }) {
                                store.folders[folderIndex].songIDs.append(contentsOf: selectedSongsToAdd)
                            }
                            showAddSongsSheet = false
                            selectedSongsToAdd.removeAll()
                        }
                        .disabled(selectedSongsToAdd.isEmpty)
                        .foregroundColor(selectedSongsToAdd.isEmpty ? .gray : .green)
                    }
                }
            }
        }
    }
    private func binding(for song: Song) -> Binding<Song> {
        guard let index = store.songs.firstIndex(of: song) else {
            fatalError("Song not found")
        }
        return $store.songs[index]
    }
    private var folderSongs: [Song] {
        store.songs.filter { folder.songIDs.contains($0.id) }
    }
    private var groupedSongs: [(groupTitle: String, songs: [Song])] {
        switch groupingMode {
        case .status:
            let groups = Dictionary(grouping: folderSongs) { $0.status }
            return groups.map { ($0.key.isEmpty ? "Unknown Status" : $0.key, $0.value) }
                         .sorted { $0.groupTitle < $1.groupTitle }
        case .mood:
            let groups = Dictionary(grouping: folderSongs) { $0.mood }
            return groups.map { ($0.key.isEmpty ? "No Mood" : $0.key, $0.value) }
                         .sorted { $0.groupTitle < $1.groupTitle }
        case .type:
            let groups = Dictionary(grouping: folderSongs) { $0.type.rawValue }
            return groups.map { ($0.key.capitalized, $0.value) }
                         .sorted { $0.groupTitle < $1.groupTitle }
        case .none:
            return [("All Songs", folderSongs)]
        }
    }
}
func folderIcon(for type: SongFolder.FolderType) -> String {
    switch type {
    case .custom: return "folder.fill"
    case .ep: return "square.stack.3d.up.fill"
    case .album: return "rectangle.stack.fill"
    }
}
