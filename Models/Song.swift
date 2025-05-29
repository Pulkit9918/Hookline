//  Song.swift
//  Hookline
//  Created by Pulkit Jain on 15/4/2025.
import Foundation
struct Song: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var type: SongType
    var lyrics: String
    var createdAt: Date = Date()
    var customTags: [String] = []
    var genre: String = ""       
    var key: String = ""
    var tempo: String = ""
    var mood: String = ""
    var comments: String = ""
    var status: String = "Draft"
    var epOrAlbumName: String = ""
    var isPinned: Bool = false
    var tags: [String] = []
    var updatedAt: Date = Date()
}
enum SongType: String, CaseIterable, Codable, Identifiable {
    case single, ep, album
    var id: String { rawValue }
}
