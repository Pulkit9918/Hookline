//  SongStore.swift
//  Hookline
//  Created by Pulkit Jain on 15/4/2025.
//import Foundation
//import SwiftUI
//class SongStore: ObservableObject {
//    @Published var songs: [Song] = [] {
//        didSet { saveSongs() }
//    }
//    init() {
//        loadSongs()
//    }
//    func addSong(_ song: Song) {
//        songs.append(song)
//    }
//    func deleteSong(at offsets: IndexSet) {
//        songs.remove(atOffsets: offsets)
//    }
//    private func saveSongs() {
//        if let data = try? JSONEncoder().encode(songs) {
//            UserDefaults.standard.set(data, forKey: "SavedSongs")
//        }
//    }
//    private func loadSongs() {
//        if let data = UserDefaults.standard.data(forKey: "SavedSongs"),
//           let saved = try? JSONDecoder().decode([Song].self, from: data) {
//            songs = saved
//        }
//    }
//}
//import Foundation
//import SwiftUI
//class SongStore: ObservableObject {
//    @Published var songs: [Song] = [] {
//        didSet { saveSongs() }
//    }
//    init() {
//        loadFolders()
//        loadSongs()
//    }
//    func addSong(_ song: Song) {
//        songs.append(song)
//    }
//    func deleteSong(at offsets: IndexSet) {
//        songs.remove(atOffsets: offsets)
//    }
//    private func saveSongs() {
//        if let data = try? JSONEncoder().encode(songs) {
//            UserDefaults.standard.set(data, forKey: "SavedSongs")
//        }
//    }
//    private func loadSongs() {
//        if let data = UserDefaults.standard.data(forKey: "SavedSongs"),
//           let saved = try? JSONDecoder().decode([Song].self, from: data) {
//            songs = saved
//        }
//    }
//    @Published var folders: [SongFolder] = [] {
//        didSet { saveFolders() }
//    }
//
//    private func saveFolders() {
//        if let data = try? JSONEncoder().encode(folders) {
//            UserDefaults.standard.set(data, forKey: "SavedFolders")
//        }
//    }
//
//    private func loadFolders() {
//        if let data = UserDefaults.standard.data(forKey: "SavedFolders"),
//           let saved = try? JSONDecoder().decode([SongFolder].self, from: data) {
//            folders = saved
//        }
//    }
//}
import Foundation
import SwiftUI
class SongStore: ObservableObject {
    @Published var songs: [Song] = [] {
        didSet { saveSongs() }
    }
    @Published var folders: [SongFolder] = [] {
            didSet { saveFolders() }
    }
    init() {
        loadFolders()
        loadSongs()
    }
    func addSong(_ song: Song) {
        songs.append(song)
    }
    func deleteSong(at offsets: IndexSet) {
        songs.remove(atOffsets: offsets)
    }
    private func saveSongs() {
        if let data = try? JSONEncoder().encode(songs) {
            UserDefaults.standard.set(data, forKey: "SavedSongs")
        }
    }
    private func loadSongs() {
        if let data = UserDefaults.standard.data(forKey: "SavedSongs"),
           let saved = try? JSONDecoder().decode([Song].self, from: data) {
            songs = saved
        }
    }
    private func saveFolders() {
            if let data = try? JSONEncoder().encode(folders) {
                UserDefaults.standard.set(data, forKey: "SavedFolders")
            }
        }
        private func loadFolders() {
            if let data = UserDefaults.standard.data(forKey: "SavedFolders"),
               let saved = try? JSONDecoder().decode([SongFolder].self, from: data) {
                folders = saved
            }
        }
        func addSongToFolder(_ songID: UUID, folderID: UUID) {
            guard let index = folders.firstIndex(where: { $0.id == folderID }) else { return }
            if !folders[index].songIDs.contains(songID) {
                folders[index].songIDs.append(songID)
            }
        }
        func removeSongFromFolder(_ songID: UUID, folderID: UUID) {
            guard let index = folders.firstIndex(where: { $0.id == folderID }) else { return }
            folders[index].songIDs.removeAll { $0 == songID }
        }
        var autoCollections: [SongFolder] {
            let epGroups = Dictionary(grouping: songs.filter { $0.type == .ep }, by: \ .epOrAlbumName)
            let albumGroups = Dictionary(grouping: songs.filter { $0.type == .album }, by: \ .epOrAlbumName)
            let epFolders = epGroups.map { name, songs in
                SongFolder(name: name, type: .ep, songIDs: songs.map { $0.id })
            }
            let albumFolders = albumGroups.map { name, songs in
                SongFolder(name: name, type: .album, songIDs: songs.map { $0.id })
            }
            return epFolders + albumFolders
        }
}
