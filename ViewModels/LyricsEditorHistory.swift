//  LyricsEditorHistory.swift
//  Hookline
//  Created by Pulkit Jain on 14/5/2025.
import Foundation
import Combine
class LyricsEditorHistory: ObservableObject {
    @Published var lyrics: String = ""
    private(set) var undoStack: [String] = []
    private(set) var redoStack: [String] = []
    func updateLyrics(_ newValue: String) {
        guard lyrics != newValue else { return }
        undoStack.append(lyrics)
        if undoStack.count > 50 {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
        lyrics = newValue
    }
    func undo() {
        guard let last = undoStack.popLast() else { return }
        redoStack.append(lyrics)
        lyrics = last
    }
    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(lyrics)
        lyrics = next
    }
    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }
    func reset(with currentLyrics: String) {
        lyrics = currentLyrics
        undoStack.removeAll()
        redoStack.removeAll()
    }
}
