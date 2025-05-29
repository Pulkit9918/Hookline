//  HooklineApp.swift
//  Hookline
//  Created by Pulkit Jain on 15/4/2025.
import SwiftUI
@main
struct HooklineApp: App {
    @StateObject private var store = SongStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
