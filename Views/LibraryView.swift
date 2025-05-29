//  LibraryView.swift
//  Hookline (Main Page when opening app)
//  Created by Pulkit Jain on 15/4/2025.
import SwiftUI
import Combine
struct LibraryView: View {
    @EnvironmentObject var store: SongStore
    @State private var searchText = ""
    @State private var editMode = EditMode.inactive
    @State private var selection = Set<UUID>()
    @State private var selectedTypeFilter: SongType? = nil
    @FocusState private var searchFocused: Bool
    @State private var keyboardVisible: Bool = false
    @State private var newSong = Song(title: "", type: .single, lyrics: "")
    @State private var selectedTab: Int = 1
    @State private var showProfile = false
    @State private var showScratchPad = false
    @State private var showShareSheet = false
    @State private var shareContent: String = ""
    @State private var showTemplatePicker = false
    @State private var navigateToNewSong = false
    @State private var selectedSongForContextMenu: Song? = nil
    @State private var selectedMetadataSong: Song? = nil
    @State private var showMetadataSheet: Bool = false
    @State private var selectedTagFilter: String? = nil
    @State private var showChordReference = false
    @State private var showAudioRecorder = false
    @State private var showingFolders: Bool = false
    @State private var showRenameAlert = false
    @State private var renamingFolder: SongFolder?
    @State private var renameText = ""
    enum SortOption: String, CaseIterable, Identifiable {
        case title = "Title"
        case dateCreated = "Date Created"
        case type = "Song Type"
        var id: String { self.rawValue }
    }
    @State private var selectedSortOption: SortOption = .dateCreated
    var allTags: [String] {
        var tagSet = Set<String>()
        for song in store.songs {
            tagSet.formUnion(song.tags)
        }
        return Array(tagSet).sorted()
    }
    var body: some View {
        NavigationStack {
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "#10002B"), Color(hex: "#240046"), Color(hex: "#3C096C")]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 700
                )
                .ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        if editMode == .active {
                            Button("Delete") {
                                if showingFolders {
                                    deleteSelectedFolders()
                                } else {
                                    deleteSelectedSongs()
                                }
                            }
                            .disabled(selection.isEmpty)
                            .foregroundColor(selection.isEmpty ? .gray : .red)
                        } else {
                            Button(action: {
                                showAudioRecorder = true
                            }) {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Quick Audio Recorder")
                            
                            Button(action: {
                                showingFolders.toggle()
                            }) {
                                Image(systemName: showingFolders ? "music.note.list" : "folder.fill")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Toggle Folders")
                            
                            if showingFolders {
                                Button(action: {
                                    let newFolder = SongFolder(name: "Untitled Folder", songIDs: [])
                                    store.folders.append(newFolder)
                                }) {
                                    Image(systemName: "folder.badge.plus")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.green)
                                        .clipShape(Circle())
                                }
                                .accessibilityLabel("Add Folder")
                            }
                        }
                        
                        Spacer()
                        
                        Text(showingFolders ? "Folders" : "My Songs")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        EditButton()
                            .foregroundColor(.white)
                            .frame(width: 60, alignment: .trailing)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.5))
                        TextField("", text: $searchText)
                            .textFieldStyle(.plain)
                            .focused($searchFocused)
                            .foregroundColor(.white)
                            .disableAutocorrection(true)
                            .placeholder(when: searchText.isEmpty) {
                                Text("Search songs...")
                                    .foregroundColor(.white.opacity(0.4))
                            }
                    }
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.top, 6)
                    tagAndTypeFilters
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if showingFolders {
                                foldersSection
                                collectionsSection
                            } else {
                                ForEach(filteredSongs) { song in
                                    let isSelected = selection.contains(song.id)
                                    ZStack {
                                        HStack(spacing: 10) {
                                            if editMode == .active {
                                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(isSelected ? .green : .gray)
                                                    .onTapGesture {
                                                        toggleSelection(for: song)
                                                    }
                                            }
                                            NavigationLink(destination: SongEditorView(song: binding(for: song), isNew: false)) {
                                                HStack(spacing: 10) {
                                                    Image(systemName: iconForType(song.type))
                                                        .foregroundColor(.white.opacity(0.9))
                                                    VStack(alignment: .leading, spacing: 0) {
                                                        Spacer(minLength: 0)
                                                        HStack(spacing: 4) {
                                                            Text(song.title)
                                                                .font(.subheadline.weight(.semibold))
                                                                .foregroundColor(.white)
                                                                .lineLimit(1)
                                                            if song.isPinned {
                                                                Image(systemName: "pin.fill")
                                                                    .font(.caption)
                                                                    .foregroundColor(.yellow)
                                                            }
                                                        }
                                                        Spacer(minLength: 0)
                                                        HStack(spacing: 4) {
                                                            Text(song.type.rawValue.capitalized)
                                                                .font(.caption2)
                                                                .foregroundColor(.white.opacity(0.6))
                                                            if song.type == .ep || song.type == .album {
                                                                Text(": \(song.epOrAlbumName)")
                                                                    .font(.caption2)
                                                                    .foregroundColor(.white.opacity(0.5))
                                                            }
                                                            if !song.status.isEmpty {
                                                                Circle()
                                                                    .fill(statusColor(song.status))
                                                                    .frame(width: 5, height: 5)
                                                                Text(song.status)
                                                                    .font(.caption2)
                                                                    .foregroundColor(.white.opacity(0.7))
                                                            }
                                                        }
                                                        Spacer(minLength: 0)
                                                        if !song.tags.isEmpty {
                                                            ScrollView(.horizontal, showsIndicators: false) {
                                                                HStack(spacing: 4) {
                                                                    ForEach(song.tags, id: \.self) { tag in
                                                                        Text("#\(tag)")
                                                                            .font(.caption2)
                                                                            .foregroundColor(.white.opacity(0.85))
                                                                            .padding(.horizontal, 6)
                                                                            .padding(.vertical, 2)
                                                                            .background(Color.white.opacity(0.08))
                                                                            .cornerRadius(6)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        Spacer(minLength: 0)
                                                    }
                                                    .frame(height: 65)
                                                    Spacer()
                                                    VStack(alignment: .trailing, spacing: 8) {
                                                        if !SongMood.from(raw: song.mood).emoji.isEmpty {
                                                            Text(SongMood.from(raw: song.mood).emoji)
                                                                .font(.title3)
                                                                .padding(6)
                                                                .background(Color.black.opacity(0.3))
                                                                .clipShape(Circle())
                                                        }
                                                        Spacer()
                                                        Text(song.updatedAt.formatted(date: .abbreviated, time: .omitted))
                                                            .font(.caption2)
                                                            .foregroundColor(.white.opacity(0.4))
                                                    }
                                                }
                                                .frame(height: 72)
                                                .padding()
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
                                    .cornerRadius(22)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1.5)
                                    )
                                    .contextMenu {
                                        Button {
                                            togglePinned(for: song)
                                        } label: {
                                            Label(song.isPinned ? "Unpin" : "Pin", systemImage: "pin")
                                        }
                                        
                                        Menu {
                                            ForEach(["Draft", "In Progress", "Completed"], id: \.self) { status in
                                                Button {
                                                    updateSongStatus(song, to: status)
                                                } label: {
                                                    Label(status, systemImage: song.status == status ? "checkmark.circle.fill" : "circle")
                                                }
                                            }
                                        } label: {
                                            Label("Set Status", systemImage: "flag.fill")
                                        }
                                        
                                        Divider()
                                        
                                        Button(role: .destructive) {
                                            deleteSong(song)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            duplicateSong(song)
                                        } label: {
                                            Label("Duplicate", systemImage: "doc.on.doc")
                                        }
                                    }
                                }
                                
                            }
                        }
                        .padding(.top, 12)
                        .padding(.horizontal)
                    }
                    Spacer(minLength: 60)
                    if !keyboardVisible {
                        HStack {
                            Spacer()
                            Button {
                                showProfile = true
                            } label: {
                                Image(systemName: "person.crop.circle")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Menu {
                                Picker("Sort By", selection: $selectedSortOption) {
                                    ForEach(SortOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Button {
                                showTemplatePicker = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 54, height: 54)
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .font(.title2.bold())
                                }
                            }
                            Spacer()
                            Button {
                                showChordReference = true
                            } label: {
                                Image(systemName: "music.note.list")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Button {
                                showScratchPad = true
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    NavigationLink(destination: SongEditorView(song: $newSong, isNew: true), isActive: $navigateToNewSong) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(destination: UserProfileView(), isActive: $showProfile) {
                        EmptyView()
                    }
                    .hidden()
                    NavigationLink(destination: ScratchPadView(), isActive: $showScratchPad) {
                        EmptyView()
                    }
                    .hidden()
                    NavigationLink(destination: ChordReferenceView(), isActive: $showChordReference) {
                        EmptyView()
                    }
                    .hidden()
                    NavigationLink(destination: AudioRecorderView(), isActive: $showAudioRecorder) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .sheet(isPresented: $showTemplatePicker) {
                NavigationView {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(SongTemplate.allCases) { template in
                                Button(action: {
                                    newSong = Song(title: "", type: .single, lyrics: template.defaultLyrics)
                                    navigateToNewSong = true
                                    showTemplatePicker = false
                                }) {
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(template.rawValue)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text(template.previewLine)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                    .background(
                        RadialGradient(
                            gradient: Gradient(colors: [Color(hex: "#10002B"), Color(hex: "#240046")]),
                            center: .center,
                            startRadius: 100,
                            endRadius: 700
                        ).ignoresSafeArea()
                    )
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Choose a Template")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                }
            }
            .alert("Rename Folder", isPresented: $showRenameAlert, actions: {
                TextField("Folder Name", text: $renameText)
                Button("Save") {
                    if let folderIndex = store.folders.firstIndex(where: { $0.id == renamingFolder?.id }) {
                        store.folders[folderIndex].name = renameText
                    }
                }
                Button("Cancel", role: .cancel) { }
            }, message: {
                Text("Enter a new name for the folder.")
            })
            .environment(\.editMode, $editMode)
            .onTapGesture {
                searchFocused = false
            }
            .onReceive(Publishers.keyboardHeight) { height in
                keyboardVisible = height > 0
            }
        }
    }
    
    private var groupedCollections: [String: [Song]] {
        let relevant = store.songs.filter { $0.type == .ep || $0.type == .album }
        return Dictionary(grouping: relevant) { song in
            song.epOrAlbumName.isEmpty ? "Untitled Collection" : song.epOrAlbumName
        }
    }
    private var filteredSongs: [Song] {
        let base = store.songs.filter { song in
            let searchLowercased = searchText.lowercased()
            let matchesTitle = song.title.lowercased().contains(searchLowercased)
            let matchesLyrics = song.lyrics.lowercased().contains(searchLowercased)
            let matchesStatus = song.status.lowercased().contains(searchLowercased)
            let matchesAlbum = song.epOrAlbumName.lowercased().contains(searchLowercased)
            
            return (selectedTypeFilter == nil || song.type == selectedTypeFilter!) &&
            (searchText.isEmpty || matchesTitle || matchesLyrics || matchesStatus || matchesAlbum)
        }
        
        let filtered: [Song]
        switch selectedTab {
        case 3:
            filtered = base.filter { $0.isPinned }
        default:
            filtered = base
        }
        
        let sorted: [Song]
        switch selectedSortOption {
        case .title:
            sorted = filtered.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .dateCreated:
            sorted = filtered.sorted { $0.createdAt > $1.createdAt }
        case .type:
            sorted = filtered.sorted { $0.type.rawValue < $1.type.rawValue }
        }
        return sorted.filter { song in
            selectedTagFilter == nil || song.tags.contains(selectedTagFilter!)
        }
    }
    
    private func toggleSelection(for song: Song) {
        if selection.contains(song.id) {
            selection.remove(song.id)
        } else {
            selection.insert(song.id)
        }
    }
    
    private func deleteSelectedSongs() {
        store.songs.removeAll { selection.contains($0.id) }
        selection.removeAll()
    }
    private func deleteSong(_ song: Song) {
        store.songs.removeAll { $0.id == song.id }
    }
    private func updateSongStatus(_ song: Song, to status: String) {
        if let index = store.songs.firstIndex(where: { $0.id == song.id }) {
            store.songs[index].status = status
        }
    }
    private func binding(for song: Song) -> Binding<Song> {
        guard let index = store.songs.firstIndex(of: song) else {
            fatalError("Song not found")
        }
        return $store.songs[index]
    }
    private func iconForType(_ type: SongType) -> String {
        switch type {
        case .single: return "music.note"
        case .ep: return "square.stack.3d.up"
        case .album: return "rectangle.stack"
        }
    }
    
    private func togglePinned(for song: Song) {
        if let index = store.songs.firstIndex(of: song) {
            store.songs[index].isPinned.toggle()
        }
    }
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Draft": return .yellow
        case "In Progress": return .orange
        case "Completed": return .green
        default: return .gray
        }
    }
    
    private func duplicateSong(_ song: Song) {
        var baseTitle = song.title
        if baseTitle.contains(" Copy") {
            baseTitle = baseTitle.components(separatedBy: " Copy").first ?? baseTitle
        }
        
        var copyCount = 2
        var newTitle = "\(baseTitle) Copy"
        
        while store.songs.contains(where: { $0.title == newTitle }) {
            newTitle = "\(baseTitle) Copy \(copyCount)"
            copyCount += 1
        }
        
        let newCopy = Song(
            title: newTitle,
            type: song.type,
            lyrics: song.lyrics,
            createdAt: Date(),
            status: song.status,
            epOrAlbumName: song.epOrAlbumName,
            isPinned: song.isPinned
        )
        
        store.songs.insert(newCopy, at: 0)
    }
    
    
    private func filterChip(title: String, type: SongType) -> some View {
        Button(action: {
            withAnimation {
                selectedTypeFilter = (selectedTypeFilter == type) ? nil : type
            }
        }) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(selectedTypeFilter == type ? .white : .white.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selectedTypeFilter == type ? Color.white.opacity(0.2) : Color.clear)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
extension LibraryView {
    private var foldersSection: some View {
        Group {
            if store.folders.isEmpty {
                Text("No folders yet")
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 80)
            } else {
                ForEach(store.folders) { folder in
                    NavigationLink {
                        SongListView(folder: folder)
                    } label: {
                        HStack {
                            Image(systemName: folderIcon(for: folder.type))
                                .font(.title2)
                                .foregroundColor(folder.type == .custom ? .yellow : .blue)
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text(folder.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.white)
                                if folder.type != .custom {
                                    Text(folder.type.rawValue.capitalized)
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            Spacer()
                            Text("\(folder.songIDs.count)")
                                .font(.headline.weight(.medium))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.05), Color.white.opacity(0.02)]),
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
                    .contextMenu {
                        if folder.type == .custom {
                            Button("Rename") {
                                renamingFolder = folder
                                renameText = folder.name
                                showRenameAlert = true
                            }
                            Button(role: .destructive) {
                                deleteFolder(folder)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onTapGesture {
                        if editMode == .active {
                            toggleFolderSelection(for: folder)
                        }
                    }
                }
            }
        }
    }
    
    private var collectionsSection: some View {
        Group {
            Divider().padding(.vertical)
            
            Text("Collections")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)
            
            ForEach(groupedCollections.keys.sorted(), id: \.self) { key in
                let songs = groupedCollections[key] ?? []
                let type: SongFolder.FolderType = songs.first?.type == .album ? .album : .ep
                let displayTitle = "\(key) (\(type.rawValue.capitalized))"
                
                NavigationLink {
                    SongListView(folder: SongFolder(name: key, type: type, songIDs: songs.map { $0.id }))
                } label: {
                    HStack {
                        Image(systemName: folderIcon(for: type))
                            .foregroundColor(.blue)
                        Text(displayTitle)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var tagAndTypeFilters: some View {
        Group {
            if !showingFolders {
                HStack {
                    Spacer()
                    HStack(spacing: 12) {
                        ForEach(SongType.allCases) { type in
                            filterChip(title: type.rawValue.capitalized, type: type)
                        }
                        Toggle(isOn: Binding(
                            get: { selectedTab == 3 },
                            set: { selectedTab = $0 ? 3 : 1 }
                        )) {
                            Image(systemName: "pin.fill")
                        }
                        .toggleStyle(.button)
                        .tint(.yellow)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 6)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(allTags, id: \.self) { tag in
                            Button(action: {
                                selectedTagFilter = (selectedTagFilter == tag) ? nil : tag
                            }) {
                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(selectedTagFilter == tag ? Color.blue.opacity(0.3) : Color.white.opacity(0.08))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func toggleFolderSelection(for folder: SongFolder) {
        if selection.contains(folder.id) {
            selection.remove(folder.id)
        } else {
            selection.insert(folder.id)
        }
    }
    private func deleteFolder(_ folder: SongFolder) {
        store.folders.removeAll { $0.id == folder.id && $0.type == .custom }
    }
    private func deleteSelectedFolders() {
        store.folders.removeAll { folder in
            selection.contains(folder.id) && folder.type == .custom
        }
        selection.removeAll()
    }
}
struct ScratchPadView: View {
    @AppStorage("scratchText") private var scratchText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: "#10002B"), Color(hex: "#240046"), Color(hex: "#3C096C")]),
                center: .center,
                startRadius: 100,
                endRadius: 700
            )
            .ignoresSafeArea()
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("🧠 Creative Cache")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Jot ideas, fragments, or random sparks")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                ZStack(alignment: .topLeading) {
                    if scratchText.isEmpty {
                        Text("Start typing your thoughts...")
                            .foregroundColor(.white.opacity(0.3))
                            .padding(18)
                            .font(.body)
                    }
                    TextEditor(text: $scratchText)
                        .font(.body)
                        .padding(.horizontal, 8)
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($isFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isFocused = false
                                }
                                .foregroundColor(.blue)
                            }
                        }
                }
                .padding(.horizontal, 8)
                Spacer()
            }
        }
    }
}
