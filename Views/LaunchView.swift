//  LaunchView.swift
//  Hookline (Launch Screen when the app opens)
//  Created by Pulkit Jain on 22/4/2025.
import SwiftUI
struct LaunchView: View {
    @State private var isActive = false
    @EnvironmentObject var store: SongStore
    private let quotes = [
        "“Lyrics are just poetry with a melody.”",
        "“You can't write if you don't read. You can't create if you don't feel.”",
        "“A songwriter writes his autobiography in his songs.”",
        "“Good songwriting tells the truth, even when it hurts.”",
        "“When the words fail, the chords carry the message.”",
        "“A song is a conversation between your soul and the world.”",
        "“Write drunk. Edit sober. Then turn it into a song.”",
        "“Your first draft won’t be perfect. That’s why we rewrite… and rhyme.”",
        "“Music is feeling. Words give it shape.”",
        "“Start with truth. Add rhythm. That's a song.”",
        "“If it doesn’t move you, it won’t move them.”",
        "“Write something only you can write — that’s where the magic is.”"
    ]
    private var randomQuote: String {
        quotes.randomElement() ?? ""
    }
    @State private var opacity: Double = 1.0
    @State private var showLibrary = false
    private let selectedQuote: String
    init() {
        self.selectedQuote = quotes.randomElement() ?? ""
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
            VStack(spacing: 24) {
                Spacer()
                Image("HLLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .scaleEffect(isActive ? 1.0 : 1.2)
                    .opacity(isActive ? 1 : 0.8)
                    .animation(.easeInOut(duration: 1.2), value: isActive)
                Text("Hookline")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                Text(selectedQuote)
                    .font(.footnote.italic())
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .transition(.opacity)
                Spacer()
            }
            .opacity(opacity)
            if showLibrary {
                LibraryView()
                    .environmentObject(store)
                    .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                isActive = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        self.showLibrary = true
                    }
                }
            }
        }
    }
}
