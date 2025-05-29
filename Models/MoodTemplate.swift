//
//  MoodTemplate.swift
//  Hookline
//
//  Created by Pulkit Jain on 19/4/2025.
import SwiftUI
enum SongMood: String, CaseIterable, Identifiable {
    case none = "No Mood"
    case joyful, optimistic, carefree
    case sad, heartbroken, melancholy
    case angry, frustrated, rebellious
    case thoughtful, nostalgic, wistful
    case mysterious, ethereal, surreal
    case empowering, romantic, playful
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "No Mood"
        case .custom: return "Custom"
        default: return rawValue.capitalized
        }
    }

    var category: String {
        switch self {
        case .joyful, .optimistic, .carefree:
            return "Happy & Uplifting"
        case .sad, .heartbroken, .melancholy:
            return "Sad & Melancholic"
        case .angry, .frustrated, .rebellious:
            return "Angry & Intense"
        case .thoughtful, .nostalgic, .wistful:
            return "Reflective & Introspective"
        case .mysterious, .ethereal, .surreal:
            return "Mysterious & Ethereal"
        case .empowering, .romantic, .playful:
            return "Other"
        case .custom:
            return "Other"
        case .none:
            return "None"
        }
    }

    var gradient: [Color] {
        switch self {
        case .none: return [Color(hex: "#10002B"), Color(hex: "#3C096C")]
        case .joyful: return [.yellow, .orange]
        case .optimistic: return [.mint, .yellow]
        case .carefree: return [.teal, .cyan]

        case .sad: return [.gray, .blue]
        case .heartbroken: return [.blue, .black]
        case .melancholy: return [.indigo, .gray]

        case .angry: return [.red, .black]
        case .frustrated: return [.orange, .gray]
        case .rebellious: return [.purple, .black]

        case .thoughtful: return [.blue.opacity(0.6), .gray.opacity(0.5)]
        case .nostalgic: return [.orange, .brown]
        case .wistful: return [.blue.opacity(0.4), .purple.opacity(0.5)]

        case .mysterious: return [.indigo, .black]
        case .ethereal: return [.purple, .white]
        case .surreal: return [.pink, .indigo]

        case .empowering: return [.blue, .yellow]
        case .romantic: return [.pink, .red]
        case .playful: return [.yellow, .mint]

        case .custom: return [Color.pink.opacity(0.4), Color.purple.opacity(0.4)]
        }
    }
    
    var emoji: String {
        switch self {
        case .joyful: return "😄"
        case .optimistic: return "🌞"
        case .carefree: return "🛼"
        case .sad: return "😢"
        case .heartbroken: return "💔"
        case .melancholy: return "🌧"
        case .angry: return "😠"
        case .frustrated: return "😤"
        case .rebellious: return "🧨"
        case .thoughtful: return "🤔"
        case .nostalgic: return "📼"
        case .wistful: return "🌙"
        case .mysterious: return "🕵️‍♂️"
        case .ethereal: return "🧚‍♀️"
        case .surreal: return "🌀"
        case .empowering: return "💪"
        case .romantic: return "❤️"
        case .playful: return "🎠"
        case .custom: return "🎨"
        case .none: return ""
        }
    }
    var color: Color {
        switch self {
        case .none: return Color.gray
        case .joyful: return Color.orange
        case .optimistic: return Color.mint
        case .carefree: return Color.teal

        case .sad: return Color.blue
        case .heartbroken: return Color.purple
        case .melancholy: return Color.indigo

        case .angry: return Color.red
        case .frustrated: return Color.orange
        case .rebellious: return Color.black

        case .thoughtful: return Color.blue.opacity(0.6)
        case .nostalgic: return Color.brown
        case .wistful: return Color.purple.opacity(0.6)

        case .mysterious: return Color.indigo
        case .ethereal: return Color.purple
        case .surreal: return Color.pink

        case .empowering: return Color.yellow
        case .romantic: return Color.pink
        case .playful: return Color.mint

        case .custom: return Color.pink.opacity(0.5)
        }
    }

    static func grouped() -> [String: [SongMood]] {
        let base = Self.allCases.filter { $0 != .custom && $0 != .none }
        var grouped = Dictionary(grouping: base, by: { $0.category })
        grouped["Other", default: []].append(.custom)
        grouped["None"] = [.none]
        return grouped
    }
    static func from(raw: String) -> SongMood {
        if raw.isEmpty || raw == "No Mood" {
            return .none
        } else if let mood = SongMood(rawValue: raw) {
            return mood
        } else {
            return .custom
        }
    }
}
