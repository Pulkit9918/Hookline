//  SongTemplate.swift
//  Hookline
//  Created by Pulkit Jain on 17/4/2025.
import Foundation
enum SongTemplate: String, CaseIterable, Identifiable {
    case blank = "Start from Scratch"
    case pop = "Pop Template"
    case rap = "Rap Template"
    case verseChorus = "Verse–Chorus Structure"
    case acoustic = "Acoustic Storytelling"
    case edm = "EDM Drop"
    case rnb = "R&B Soul"
    var id: String { rawValue }
    var defaultLyrics: String {
        switch self {
        case .blank: return ""
        case .pop: return "[Intro]\n[Verse 1]\n[Chorus]\n[Verse 2]\n[Chorus]\n[Bridge]\n[Chorus]"
        case .rap: return "[Verse 1]\n[Verse 2]\n[Hook]\n[Verse 3]"
        case .verseChorus: return "[Verse 1]\n[Chorus]\n[Verse 2]\n[Chorus]\n[Bridge]\n[Chorus]"
        case .acoustic: return "[Verse 1]\n[Verse 2]\n[Bridge]\n[Outro]"
        case .edm: return "[Intro]\n[Build Up]\n[Drop]\n[Verse]\n[Build Up]\n[Drop]\n[Outro]"
        case .rnb: return "[Verse]\n[Chorus]\n[Verse]\n[Bridge]\n[Chorus]"
        }
    }
    var previewLine: String {
        switch self {
        case .blank: return "Empty song to begin with"
        case .pop: return "Intro, Verse, Chorus, Bridge"
        case .rap: return "Verses and Hook"
        case .verseChorus: return "Classic modern structure"
        case .acoustic: return "Verses with emotional bridge"
        case .edm: return "Drop and build-up pattern"
        case .rnb: return "Smooth emotional flow"
        }
    }
}
