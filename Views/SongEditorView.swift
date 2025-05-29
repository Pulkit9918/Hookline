//  SongEditorView.swift
//  Hookline
//  Created by Pulkit Jain on 15/4/2025.
//import SwiftUI
//import PDFKit
//import UIKit
//import Combine
//import NaturalLanguage
//struct CustomTextView: UIViewRepresentable {
//    @Binding var text: String
//    @Binding var dynamicHeight: CGFloat
//    var onTextChange: ((String) -> Void)? = nil
//    class Coordinator: NSObject, UITextViewDelegate {
//        var parent: CustomTextView
//        init(_ parent: CustomTextView) {
//            self.parent = parent
//        }
//        func textViewDidChange(_ textView: UITextView) {
//            let originalText = textView.text ?? ""
//            let selectedRange = textView.selectedRange
//            let lines = originalText.components(separatedBy: .newlines)
//            
//            let convertedLines = lines.map { line -> String in
//                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//                switch trimmed {
//                case "verse:", "verse":
//                    return "[Verse]"
//                case "chorus:", "chorus":
//                    return "[Chorus]"
//                case "bridge:", "bridge":
//                    return "[Bridge]"
//                case "intro:", "intro":
//                    return "[Intro]"
//                case "hook:", "hook":
//                    return "[Hook]"
//                case "pre-chorus:", "pre-chorus":
//                    return "[Pre-Chorus]"
//                case "post-chorus:", "post-chorus":
//                    return "[Post-Chorus]"
//                case "outro:", "outro":
//                    return "[Outro]"
//                default:
//                    return line
//                }
//            }
//            let newText = convertedLines.joined(separator: "\n")
//            if newText != originalText {
//                textView.attributedText = parent.formatText(newText)
//                textView.selectedRange = selectedRange
//            }
//            if parent.text != newText {
//                parent.text = newText
//                parent.onTextChange?(newText)
//            }
//            textView.typingAttributes = [
//                .foregroundColor: UIColor.white,
//                .font: UIFont.systemFont(ofSize: 16)
//            ]
//            let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
//            DispatchQueue.main.async {
//                self.parent.dynamicHeight = newSize.height
//            }
//        }
//    }
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    func makeUIView(context: Context) -> UITextView {
//        let textView = UITextView()
//        textView.delegate = context.coordinator
//        textView.isScrollEnabled = false
//        textView.backgroundColor = .clear
//        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        textView.textColor = .white
//        textView.font = UIFont.systemFont(ofSize: 16)
//        textView.typingAttributes = [
//            .foregroundColor: UIColor.white,
//            .font: UIFont.systemFont(ofSize: 16)
//        ]
//        return textView
//    }
//    func updateUIView(_ uiView: UITextView, context: Context) {
//        if uiView.text != text {
//            let selectedRange = uiView.selectedRange
//            uiView.attributedText = formatText(text)
//            uiView.selectedRange = selectedRange
//        }
//        DispatchQueue.main.async {
//            CustomTextView.recalculateHeight(view: uiView, result: &dynamicHeight)
//        }
//    }
//    static func recalculateHeight(view: UITextView, result: inout CGFloat) {
//        let size = view.sizeThatFits(CGSize(width: view.frame.size.width, height: .greatestFiniteMagnitude))
//        if result != size.height {
//            result = size.height
//        }
//    }
//    private func formatText(_ raw: String) -> NSAttributedString {
//        let fullString = NSMutableAttributedString()
//        let lines = raw.components(separatedBy: .newlines)
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 6
//        paragraphStyle.paragraphSpacing = 8
//        paragraphStyle.headIndent = 8
//        paragraphStyle.firstLineHeadIndent = 0
//        let tagRegex = "\\[(Intro|Verse|Chorus|Bridge|Hook|Outro|Pre-Chorus|Post-Chorus)\\]"
//        for line in lines {
//            let attrLine = NSMutableAttributedString()
//            if let match = try? NSRegularExpression(pattern: tagRegex)
//                .firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count)) {
//                let matchRange = match.range
//                let nsLine = line as NSString
//                let tag = nsLine.substring(with: matchRange)
//                let restOfLine = nsLine.replacingCharacters(in: matchRange, with: "").trimmingCharacters(in: .whitespaces)
//                let shadow = NSShadow()
//                shadow.shadowColor = colorForTag(tag)?.withAlphaComponent(0.5)
//                shadow.shadowBlurRadius = 2
//                shadow.shadowOffset = CGSize(width: 0.5, height: 1)
//                let tagAttr = NSMutableAttributedString(string: tag + " ")
//                tagAttr.addAttributes([
//                    .foregroundColor: colorForTag(tag) ?? .white,
//                    .font: UIFont.boldSystemFont(ofSize: 17),
//                    .shadow: shadow
//                ], range: NSRange(location: 0, length: tagAttr.length))
//                attrLine.append(tagAttr)
//                let contentAttr = NSMutableAttributedString(string: restOfLine)
//                contentAttr.addAttributes([
//                    .foregroundColor: UIColor.white,
//                    .font: UIFont(name: "Charter-Italic", size: 17) ?? UIFont.systemFont(ofSize: 17)
//                ], range: NSRange(location: 0, length: contentAttr.length))
//                attrLine.append(contentAttr)
//            } else {
//                let normalLine = NSMutableAttributedString(string: line)
//                normalLine.addAttributes([
//                    .foregroundColor: UIColor.white,
//                    .font: UIFont(name: "Charter-Italic", size: 17) ?? UIFont.systemFont(ofSize: 17)
//                ], range: NSRange(location: 0, length: normalLine.length))
//                attrLine.append(normalLine)
//            }
//            attrLine.addAttributes([
//                .paragraphStyle: paragraphStyle
//            ], range: NSRange(location: 0, length: attrLine.length))
//            fullString.append(attrLine)
//            fullString.append(NSAttributedString(string: "\n"))
//        }
//        return fullString
//    }
//    private func colorForTag(_ tag: String) -> UIColor? {
//        switch tag {
//        case "[Intro]": return .systemRed
//        case "[Verse]": return .systemPurple
//        case "[Chorus]": return .systemBlue
//        case "[Bridge]": return .systemOrange
//        case "[Outro]": return .lightGray
//        case "[Hook]": return .systemPink
//        case "[Pre-Chorus]": return .systemTeal
//        case "[Post-Chorus]": return .systemYellow
//        default: return nil
//        }
//    }
//}
//struct SongEditorView: View {
//    @EnvironmentObject var store: SongStore
//    @Environment(\.dismiss) private var dismiss
//    @Binding var song: Song
//    var isNew: Bool = false
//    @State private var showAlert = false
//    @State private var showMetadataSheet = false
//    @State private var showShareSheet = false
//    @State private var shareURL: URL?
//    @FocusState private var isLyricsFocused: Bool
//    @State private var keyboardVisible: Bool = false
//    @State private var lyricsTextEditorID = UUID()
//    @State private var lyricsHeight: CGFloat = 300
//    @State private var showCustomTagField = false
//    @State private var customTagInput = ""
//    @State private var keyboardHeight: CGFloat = 0
//    @State private var customMoodText: String = ""
//    @State private var tagInput: String = ""
//    @State private var scrollOffset: CGFloat = 0
//    @State private var isLyricsExpanded: Bool = false
//    @State private var showFullLyricsEditor = false
//    @State private var lyricsScrollTrigger = UUID()
//    @State private var showInsightsSheet = false
//    @State private var showRecorder = false
//    @StateObject private var audioRecorderVM = AudioRecorderViewModel()
//    @State private var quickNote: String = ""
//    @State private var showQuickNote = false
//    @State private var undoStack: [String] = []
//    @State private var redoStack: [String] = []
//    @State private var lyricsEditorID = UUID()
//    let sectionTags = ["[Intro]", "[Verse]", "[Chorus]", "[Bridge]", "[Outro]", "[Hook]", "[Pre-Chorus]", "[Post-Chorus]"]
//    let statusOptions = ["Draft", "In Progress", "Completed"]
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            backgroundGradient
//            mainContent
//                .onAppear {
//                    quickNote = UserDefaults.standard.string(forKey: "note_\(song.id.uuidString)") ?? ""
//                }
//                .onChange(of: quickNote) { newValue in
//                    UserDefaults.standard.set(newValue, forKey: "note_\(song.id.uuidString)")
//                }
//            if isLyricsFocused { dismissKeyboardButton }
//        }
//        .onReceive(Publishers.keyboardHeight) { height in
//            keyboardVisible = height > 0
//        }
//        .sheet(isPresented: $showMetadataSheet) { metadataSheet }
//        .sheet(isPresented: $showShareSheet) {
//            if let url = shareURL {
//                ShareSheet(activityItems: [url])
//            }
//        }
//        .sheet(isPresented: $showInsightsSheet) {
//            SongInsightsView(lyrics: song.lyrics)
//        }
//        .sheet(isPresented: $showQuickNote) {
//            VStack(spacing: 16) {
//                HStack {
//                    Spacer()
//                    Text("📝 Quick Note")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                    Spacer()
//                    Button(action: { showQuickNote = false }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.title2)
//                            .foregroundColor(.white.opacity(0.7))
//                    }
//                }
//                .padding(.top, 20)
//                TextEditor(text: $quickNote)
//                    .font(.body)
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 8)
//                    .frame(maxHeight: .infinity)
//                    .scrollContentBackground(.hidden)
//                    .background(Color.clear)
//                Spacer()
//            }
//            .padding(.horizontal, 8)
//            .background(
//                RadialGradient(
//                    gradient: Gradient(colors: [Color(hex: "#10002B"), Color(hex: "#240046"), Color(hex: "#3C096C")]),
//                    center: .center,
//                    startRadius: 100,
//                    endRadius: 700
//                ).ignoresSafeArea()
//            )
//        }
//        .presentationDetents([.fraction(1.0)])
//        .presentationDragIndicator(.hidden)
//        .alert("Title Required", isPresented: $showAlert) {
//            Button("OK", role: .cancel) {}
//        } message: {
//            Text("Please enter a song title before saving.")
//        }
//    }
//    private var backgroundGradient: some View {
//        RadialGradient(
//            gradient: Gradient(colors: [Color(hex: "#10002B"), Color(hex: "#240046"), Color(hex: "#3C096C")]),
//            center: .center,
//            startRadius: 100,
//            endRadius: 700
//        ).ignoresSafeArea()
//    }
//    private var mainContent: some View {
//        VStack(spacing: 0) {
//            VStack(alignment: .leading, spacing: 10) {
//                sectionHeader(title: "Song Info", icon: "music.note")
//                titleAndTypeRow
//                Group {
//                    if song.type == .ep || song.type == .album {
//                        VStack(spacing: 6) {
//                            epOrAlbumNameField
//                        }
//                        .transition(.asymmetric(
//                            insertion: .scale(scale: 0.95).combined(with: .opacity),
//                            removal: .scale(scale: 0.95).combined(with: .opacity)
//                        ))
//                    }
//                }
//                .animation(.easeInOut(duration: 0.25), value: song.type)
//                Divider().background(Color.white.opacity(0.05)).padding(.vertical, 4)
//                VStack(alignment: .leading, spacing: 4) {
//                    sectionTagsScroll
//                }
//                VStack(alignment: .leading, spacing: 4) {
//                    tagsInputBar
//                }
//            }
//            .padding(.horizontal)
//            .padding(.top, 10)
//            lyricsEditor
//                .layoutPriority(1)
//                .frame(minHeight: 160, maxHeight: .infinity)
//            Spacer(minLength: 10)
//            if !keyboardVisible {
//                bottomToolbar
//            }
//        }
//    }
//    private var titleAndTypeRow: some View {
//        HStack(spacing: 12) {
//            TextField("", text: $song.title)
//                .placeholder(when: song.title.isEmpty) {
//                    Text("New Song Title")
//                        .foregroundColor(.white.opacity(0.4))
//                        .padding(.leading, 12)
//                }
//                .font(.title2.bold())
//                .padding(10)
//                .background(Color.white.opacity(0.05))
//                .cornerRadius(10)
//                .foregroundColor(.white)
//            Menu {
//                ForEach(SongType.allCases) { option in
//                    Button(option.rawValue.capitalized) {
//                        withAnimation {
//                            song.type = option
//                        }
//                    }
//                }
//            } label: {
//                HStack {
//                    Text(song.type.rawValue.capitalized)
//                        .font(.subheadline)
//                        .padding(.horizontal, 10)
//                        .padding(.vertical, 6)
//                        .background(Color.white.opacity(0.08))
//                        .cornerRadius(8)
//                        .foregroundColor(.white)
//                    Image(systemName: "chevron.down")
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.7))
//                }
//            }
//        }
//    }
//    private var epOrAlbumNameField: some View {
//        TextField("", text: $song.epOrAlbumName)
//            .placeholder(when: song.epOrAlbumName.isEmpty) {
//                Text("Enter \(song.type.rawValue.capitalized) Name")
//                    .foregroundColor(.white.opacity(0.4))
//                    .padding(.leading, 12)
//            }
//            .font(.subheadline)
//            .padding(10)
//            .background(Color.white.opacity(0.05))
//            .cornerRadius(10)
//            .foregroundColor(.white)
//    }
//    private var sectionTagsScroll: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 10) {
//                ForEach(sectionTags, id: \.self) { tag in
//                    Button(action: { insertTag(tag) }) {
//                        Text(tag)
//                            .font(.caption)
//                            .padding(.horizontal, 10)
//                            .padding(.vertical, 6)
//                            .background(tagColor(for: tag).opacity(0.25))
//                            .cornerRadius(8)
//                            .foregroundColor(tagColor(for: tag))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(tagColor(for: tag).opacity(0.5), lineWidth: 1)
//                            )
//                    }
//                }
//                if showCustomTagField {
//                    HStack(spacing: 6) {
//                        TextField("Tag", text: $customTagInput)
//                            .textFieldStyle(PlainTextFieldStyle())
//                            .padding(.horizontal, 8)
//                            .frame(width: 120)
//                            .foregroundColor(.white)
//                            .background(Color.white.opacity(0.08))
//                            .cornerRadius(6)
//                        Button(action: {
//                            if !customTagInput.trimmingCharacters(in: .whitespaces).isEmpty {
//                                insertTag("[\(customTagInput)]")
//                                customTagInput = ""
//                                showCustomTagField = false
//                            }
//                        }) {
//                            Image(systemName: "checkmark")
//                                .foregroundColor(.blue)
//                        }
//                    }
//                    .transition(.opacity)
//                } else {
//                    Button(action: {
//                        withAnimation { showCustomTagField = true }
//                    }) {
//                        Image(systemName: "plus")
//                            .foregroundColor(.white)
//                            .padding(6)
//                            .background(Color.white.opacity(0.08))
//                            .cornerRadius(6)
//                    }
//                }
//            }
//        }
//    }
//    private func sectionHeader(title: String, icon: String) -> some View {
//        HStack(spacing: 8) {
//            Image(systemName: icon)
//                .foregroundColor(.white.opacity(0.6))
//            Text(title)
//                .font(.caption.bold())
//                .foregroundColor(.white.opacity(0.6))
//        }
//        .padding(.horizontal, 4)
//        .padding(.top, 8)
//    }
//    private var tagsInputBar: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            HStack {
//                TextField("#tags", text: $tagInput, onCommit: addTagFromInput)
//                    .textFieldStyle(PlainTextFieldStyle())
//                    .foregroundColor(.white)
//                    .padding(8)
//                    .background(Color.white.opacity(0.05))
//                    .cornerRadius(10)
//                    .overlay(
//                        Group {
//                            if tagInput.isEmpty {
//                                Text("")
//                                    .foregroundColor(.white.opacity(0.3))
//                                    .padding(.horizontal, 14)
//                                    .padding(.vertical, 8)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                            }
//                        }
//                    )
//                Button(action: addTagFromInput) {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.blue)
//                }
//            }
//            if !song.tags.isEmpty {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 6) {
//                        ForEach(song.tags, id: \.self) { tag in
//                            Text("#\(tag)")
//                                .font(.caption)
//                                .foregroundColor(.white.opacity(0.9))
//                            Button(action: {
//                                withAnimation {
//                                    song.tags.removeAll { $0 == tag }
//                                }
//                            }) {
//                                Image(systemName: "xmark.circle.fill")
//                                    .font(.caption2)
//                                    .foregroundColor(.white.opacity(0.5))
//                            }
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 4)
//                            .background(Color.white.opacity(0.1))
//                            .cornerRadius(8)
//                        }
//                    }
//                }
//                .transition(.opacity)
//            }
//            Divider()
//                .background(Color.white.opacity(0.2))
//        }
//        .padding(.top, 4)
//    }
//    private var lyricsEditor: some View {
//        let mood = SongMood.from(raw: song.mood)
//        return VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text("Lyrics")
//                    .font(.headline)
//                    .foregroundColor(.white.opacity(0.8))
//                
//                Spacer()
//                
//                Button(action: {
//                    withAnimation(.easeInOut(duration: 0.25)) {
//                        showFullLyricsEditor = true
//                    }
//                }) {
//                    Image(systemName: "arrow.up.left.and.arrow.down.right")
//                        .font(.subheadline)
//                        .foregroundColor(.white.opacity(0.7))
//                        .padding(6)
//                        .background(Color.white.opacity(0.08))
//                        .clipShape(Circle())
//                }
//                Button(action: {
//                    showRecorder = true
//                }) {
//                    Image(systemName: "mic.circle")
//                        .font(.title2)
//                        .foregroundColor(.white.opacity(0.8))
//                        .padding(6)
//                        .background(Color.white.opacity(0.08))
//                        .clipShape(Circle())
//                }
//            }
//            .padding(.horizontal)
//            ZStack {
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(
//                        LinearGradient(
//                            gradient: Gradient(colors: mood.gradient),
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                        .opacity(mood == .none ? 0 : 0.35)
//                    )
//                    .background(Color.white.opacity(0.05))
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
//                ScrollViewReader { proxy in
//                    ScrollView {
//                        VStack(alignment: .leading, spacing: 0) {
//                            CustomTextView(
//                                text: $song.lyrics,
//                                dynamicHeight: $lyricsHeight,
//                                onTextChange: { newValue in
//                                    guard undoStack.last != newValue else { return }
//                                    undoStack.append(newValue)
//                                    redoStack.removeAll()
//                                    lyricsEditorID = UUID() // Force UI refresh
//                                }
//                            )
//                            .id(lyricsEditorID)
//                                .disabled(true)
//                                .frame(minHeight: lyricsHeight)
//                                .padding(12)
//                                .contentShape(Rectangle())
//                                .onTapGesture {
//                                    withAnimation(.easeInOut(duration: 0.25)) {
//                                        showFullLyricsEditor = true
//                                    }
//                                }
//                            
//                            Color.clear
//                                .frame(height: 1)
//                                .id("LyricsBottom")
//                        }
//                    }
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                    .onChange(of: lyricsScrollTrigger) { _ in
//                        withAnimation {
//                            proxy.scrollTo("LyricsBottom", anchor: .bottom)
//                        }
//                    }
//                }
//            }
//            .frame(minHeight: 180, maxHeight: .infinity)
//            .padding(.horizontal)
//            HStack {
//                Button(action: {
//                    showQuickNote = true
//                }) {
//                    Label("Quick Note", systemImage: "note.text")
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.6))
//                        .underline()
//                }
//                Spacer()
//                Button(action: {
//                    showInsightsSheet = true
//                }) {
//                    Label("View Song Insights", systemImage: "chart.bar.doc.horizontal")
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.6))
//                        .underline()
//                }
//            }
//            .padding(.horizontal)
//        }
//        .padding(.top)
//        .fullScreenCover(isPresented: $showFullLyricsEditor) {
//            FullscreenLyricsView(song: $song, isPresented: $showFullLyricsEditor)
//                .transition(.move(edge: .bottom).combined(with: .opacity))
//        }
//        .sheet(isPresented: $showRecorder) {
//            AudioRecorderView(viewModel: audioRecorderVM, section: nil)
//        }
//    }
//    private var bottomToolbar: some View {
//        HStack(spacing: 16) {
//            Button(action: { dismiss() }) {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.title3)
//                    .foregroundColor(.red)
//                    .frame(width: 44, height: 44)
//                    .background(.ultraThinMaterial)
//                    .clipShape(Circle())
//                    .shadow(color: Color.red.opacity(0.2), radius: 4, x: 0, y: 2)
//            }
//            Spacer()
//            Button(action: { showMetadataSheet = true }) {
//                Image(systemName: "info.circle")
//                    .font(.title3)
//                    .foregroundColor(.white.opacity(0.85))
//                    .frame(width: 44, height: 44)
//                    .background(.ultraThinMaterial)
//                    .clipShape(Circle())
//                    .shadow(color: Color.white.opacity(0.1), radius: 4, x: 0, y: 2)
//            }
//            Button(action: {
//                shareURL = exportSongAsPDF()
//                showShareSheet = true
//            }) {
//                Image(systemName: "square.and.arrow.up")
//                    .font(.title3)
//                    .foregroundColor(.white.opacity(0.85))
//                    .frame(width: 44, height: 44)
//                    .background(.ultraThinMaterial)
//                    .clipShape(Circle())
//                    .shadow(color: Color.white.opacity(0.1), radius: 4, x: 0, y: 2)
//            }
//            Spacer()
//            Button(action: {
//                if song.title.trimmingCharacters(in: .whitespaces).isEmpty {
//                    showAlert = true
//                    return
//                }
//                addTagFromInput()
//                song.updatedAt = Date()
//                if isNew {
//                    store.addSong(song)
//                }
//                dismiss()
//            }) {
//                Image(systemName: "checkmark.circle.fill")
//                    .font(.title3)
//                    .foregroundColor(.blue)
//                    .frame(width: 44, height: 44)
//                    .background(.ultraThinMaterial)
//                    .clipShape(Circle())
//                    .shadow(color: Color.blue.opacity(0.2), radius: 4, x: 0, y: 2)
//            }
//        }
//        .padding(.horizontal, 24)
//        .padding(.vertical, 10)
//        .background(Color.clear)
//    }
//    private var dismissKeyboardButton: some View {
//        HStack {
//            Spacer()
//            Button(action: { isLyricsFocused = false }) {
//                Image(systemName: "keyboard.chevron.compact.down")
//                    .font(.title2)
//                    .padding(12)
//                    .background(Color.white.opacity(0.1))
//                    .foregroundColor(.blue)
//                    .clipShape(Circle())
//                    .padding(.bottom, keyboardVisible ? 10 : -100)
//            }
//            .padding(.trailing)
//        }
//        .padding(.bottom, keyboardHeight + 12)
//        .transition(.move(edge: .bottom).combined(with: .opacity))
//    }
//    private var metadataSheet: some View {
//        let accent = SongMood.from(raw: song.mood).gradient.first ?? .blue
//        
//        return ScrollView {
//            VStack(spacing: 28) {
//                HStack {
//                    Spacer()
//                    Text("Song Metadata")
//                        .font(.title3.bold())
//                        .foregroundColor(.white)
//                    Spacer()
//                    Button(action: { showMetadataSheet = false }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.title2)
//                            .foregroundColor(.white.opacity(0.7))
//                    }
//                }
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Status")
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.6))
//                    
//                    Picker("Status", selection: $song.status) {
//                        ForEach(statusOptions, id: \.self) { Text($0) }
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    .padding(8)
//                    .background(.ultraThinMaterial)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(accent.opacity(0.3), lineWidth: 1)
//                    )
//                }
//                Group {
//                    metadataField(title: "Genre", text: $song.genre, accent: accent)
//                    metadataField(title: "Key", text: $song.key, accent: accent)
//                    metadataField(title: "Tempo (BPM)", text: $song.tempo, accent: accent)
//                }
//                moodPickerSection(accent: accent)
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Comments")
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.6))
//                    TextEditor(text: $song.comments)
//                        .frame(height: 90)
//                        .padding(12)
//                        .background(.ultraThinMaterial)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
//                        )
//                        .foregroundColor(.white)
//                        .scrollContentBackground(.hidden)
//                }
//                Spacer(minLength: 40)
//            }
//            .padding()
//        }
//        .background {
//            ZStack {
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color(hex: "#14002B"),
//                        Color(hex: "#2E1452"),
//                        Color(hex: "#392F7D")
//                    ]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//                Ellipse()
//                    .fill(accent.opacity(0.18))
//                    .frame(width: 400, height: 280)
//                    .blur(radius: 120)
//                    .offset(x: 120, y: -200)
//                Ellipse()
//                    .fill(accent.opacity(0.12))
//                    .frame(width: 300, height: 200)
//                    .blur(radius: 100)
//                    .offset(x: -80, y: 250)
//                Circle()
//                    .fill(Color.white.opacity(0.03))
//                    .frame(width: 600, height: 600)
//                    .blur(radius: 150)
//                    .offset(x: -150, y: -300)
//            }
//        }
//    }
//    private func insertTag(_ tag: String) {
//        song.lyrics += "\n\(tag)\n"
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            lyricsScrollTrigger = UUID()
//        }
//    }
//    private func addTagFromInput() {
//        let cleanedTags = tagInput
//            .split(separator: " ")
//            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "") }
//            .filter { !$0.isEmpty && !song.tags.contains($0) }
//        
//        if !cleanedTags.isEmpty {
//            song.tags.append(contentsOf: cleanedTags)
//        }
//        tagInput = ""
//    }
//    private func tagColor(for tag: String) -> Color {
//        switch tag {
//        case "[Verse]": return .purple
//        case "[Chorus]": return .blue
//        case "[Bridge]": return .orange
//        case "[Hook]": return .pink
//        case "[Outro]": return .gray
//        case "[Pre-Chorus]": return .mint
//        case "[Intro]": return .red
//        case "[Post-Chorus]": return .yellow
//        default: return .white
//        }
//    }
//    private func metadataField(title: String, text: Binding<String>, accent: Color) -> some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(title)
//                .font(.caption)
//                .foregroundColor(.white.opacity(0.6))
//            
//            TextField("", text: text)
//                .placeholder(when: text.wrappedValue.isEmpty) {
//                    Text("Enter \(title.lowercased())")
//                        .foregroundColor(.white.opacity(0.4))
//                }
//                .padding(12)
//                .background(.ultraThinMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(accent.opacity(0.25), lineWidth: 1)
//                )
//                .foregroundColor(.white)
//        }
//    }
//    private func moodPickerSection(accent: Color) -> some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Mood")
//                .font(.caption)
//                .foregroundColor(.white.opacity(0.6))
//            
//            HStack(spacing: 12) {
//                Picker("Select Mood", selection: Binding(
//                    get: {
//                        SongMood.from(raw: song.mood).rawValue == "custom" ? "custom" : song.mood
//                    },
//                    set: { newValue in
//                        if newValue == "custom" {
//                            song.mood = "custom"
//                        } else {
//                            song.mood = newValue
//                            customMoodText = ""
//                        }
//                    }
//                )) {
//                    ForEach(SongMood.grouped().sorted(by: { $0.key < $1.key }), id: \.key) { category, moods in
//                        Section(header: Text(category).foregroundColor(.white.opacity(0.4))) {
//                            ForEach(moods) { mood in
//                                Text(mood.displayName).tag(mood.rawValue)
//                            }
//                        }
//                    }
//                }
//                .pickerStyle(MenuPickerStyle())
//                .padding(12)
//                .background(.ultraThinMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(accent.opacity(0.3), lineWidth: 1)
//                )
//                .foregroundColor(.white)
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Created")
//                        .font(.caption2)
//                        .foregroundColor(.white.opacity(0.5))
//                    Text(song.createdAt.formatted(date: .abbreviated, time: .omitted))
//                        .font(.caption)
//                        .foregroundColor(.white)
//                }
//                .padding(10)
//                .background(.ultraThinMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
//                )
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Updated")
//                        .font(.caption2)
//                        .foregroundColor(.white.opacity(0.5))
//                    Text(song.updatedAt.formatted(date: .abbreviated, time: .omitted))
//                        .font(.caption)
//                        .foregroundColor(.white)
//                }
//                .padding(10)
//                .background(.ultraThinMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
//                )
//            }
//            if SongMood.from(raw: song.mood) == .custom {
//                TextField("", text: Binding(
//                    get: { customMoodText },
//                    set: {
//                        customMoodText = $0
//                        song.mood = $0.isEmpty ? "custom" : $0
//                    }
//                ))
//                .placeholder(when: customMoodText.isEmpty) {
//                    Text("Enter your custom mood")
//                        .foregroundColor(.white.opacity(0.4))
//                }
//                .padding(12)
//                .background(.ultraThinMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(accent.opacity(0.2), lineWidth: 1)
//                )
//                .foregroundColor(.white)
//            }
//        }
//    }
//    private var wordCount: Int {
//        song.lyrics.split { $0.isWhitespace || $0.isNewline }.count
//    }
//    private var characterCount: Int {
//        song.lyrics.count
//    }
//    private func exportSongAsPDF() -> URL? {
//        let pdfMeta = """
//        Title: \(song.title)
//        Type: \(song.type.rawValue.capitalized)
//        EP/Album: \(song.epOrAlbumName)
//        Genre: \(song.genre)
//        Key: \(song.key)
//        Tempo: \(song.tempo)
//        Mood: \(song.mood)
//        Status: \(song.status)
//        Comments: \(song.comments)
//        Lyrics:
//        \(song.lyrics)
//        """
//        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
//        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(song.title)-Lyrics.pdf")
//        do {
//            try renderer.writePDF(to: url) { context in
//                context.beginPage()
//                let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
//                pdfMeta.draw(in: CGRect(x: 20, y: 20, width: 572, height: 752), withAttributes: attrs)
//            }
//            return url
//        } catch {
//            print("Failed to write PDF: \(error)")
//            return nil
//        }
//    }
//}
//struct RhymeLineGroup: Identifiable {
//    let id = UUID()
//    let line: String
//    let groupColor: Color
//}
//struct FullscreenLyricsView: View {
//    @Binding var song: Song
//    @Binding var isPresented: Bool
//    @FocusState private var isLyricsFocused: Bool
//    @State private var lyricsHeight: CGFloat = 300
//    @State private var lyricsScrollTrigger = UUID()
//    @State private var keyboardVisible: Bool = false
//    @State private var undoStack: [String] = []
//    @State private var redoStack: [String] = []
//    @State private var sectionMeta: [String: (tempo: Int, chords: String)] = [:]
//    @State private var selectedTag: String = ""
//    @State private var showTagMetaEditor = false
//    @State private var showTempoKeyLabels = true
//    @State private var enablePulse = true
//    @State private var pulseAnimation = false
//    @State private var nightFocusMode = false
//    @State private var showRhymeScheme = false
//    @State private var lyricsEditorID = UUID()
//    private var rhymeGroups: [RhymeLineGroup] {
//        let lines = song.lyrics.components(separatedBy: .newlines)
//            .map { $0.trimmingCharacters(in: .whitespaces) }
//        var profiles: [(index: Int, word: String, profile: (String, String, String))] = []
//        for (i, line) in lines.enumerated() {
//            if line.isEmpty || (line.hasPrefix("[") && line.hasSuffix("]")) {
//                profiles.append((i, "", ("", "", "")))
//                continue
//            }
//            let lastWord = line.components(separatedBy: .whitespaces).last ?? ""
//            profiles.append((i, lastWord, phoneticProfile(for: lastWord)))
//        }
//        var colors = Array([Color.green, .yellow, .blue, .purple, .gray])
//        var assignedColors = Array(repeating: Color.white, count: lines.count)
//        for i in 0..<profiles.count {
//            for j in (i+1)..<profiles.count {
//                let (v1, c1, s1) = profiles[i].profile
//                let (v2, c2, s2) = profiles[j].profile
//                let color: Color
//                if s1 == s2 && s1 != "" {
//                    color = .green
//                } else if v1 == v2 && c1 == c2 {
//                    color = .yellow
//                } else if v1 == v2 {
//                    color = .blue
//                } else if c1 == c2 {
//                    color = .purple
//                } else {
//                    continue
//                }
//                assignedColors[profiles[i].index] = color
//                assignedColors[profiles[j].index] = color
//            }
//        }
//        return lines.enumerated().map { (i, line) in
//            let color = assignedColors[i] == .white ? .white.opacity(0.6) : assignedColors[i]
//            return RhymeLineGroup(line: line, groupColor: color)
//        }
//    }
//    private var rhymeLegend: some View {
//        HStack(spacing: 14) {
//            legendItem(color: .green, label: "Perfect")
//            legendItem(color: .yellow, label: "Slant")
//            legendItem(color: .blue, label: "Assonance")
//            legendItem(color: .purple, label: "Consonance")
//            legendItem(color: .white.opacity(0.6), label: "None")
//        }
//        .padding(.horizontal)
//        .padding(.bottom, 4)
//    }
//    private func legendItem(color: Color, label: String) -> some View {
//        HStack(spacing: 4) {
//            Circle()
//                .fill(color)
//                .frame(width: 10, height: 10)
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.white.opacity(0.8))
//        }
//    }
//    private func phoneticProfile(for word: String) -> (vowelCluster: String, consonantCluster: String, suffix: String) {
//        let vowels = "aeiou"
//        let cleaned = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
//        let suffix = String(cleaned.suffix(3))
//        let reversed = cleaned.reversed()
//        let vowel = reversed.first { vowels.contains($0) } ?? "-"
//        let consonant = reversed.first { !vowels.contains($0) } ?? "-"
//        return (String(vowel), String(consonant), suffix)
//    }
//    private func tagColor(for tag: String) -> Color {
//        switch tag {
//        case "[Verse]": return .purple
//        case "[Chorus]": return .blue
//        case "[Bridge]": return .orange
//        case "[Hook]": return .pink
//        case "[Outro]": return .gray
//        case "[Pre-Chorus]": return .mint
//        case "[Intro]": return .red
//        case "[Post-Chorus]": return .yellow
//        default: return .white
//        }
//    }
//    private func pulseAttributes(for mood: String) -> (speed: Double, opacity: Double) {
//        switch mood {
//        case "sad", "heartbroken", "melancholy": return (3.5, 0.07)
//        case "angry", "frustrated", "rebellious": return (1.0, 0.2)
//        case "joyful", "optimistic", "carefree": return (1.5, 0.15)
//        case "thoughtful", "nostalgic", "wistful": return (2.5, 0.1)
//        case "mysterious", "ethereal", "surreal": return (2.2, 0.13)
//        case "empowering", "romantic", "playful": return (1.4, 0.12)
//        default: return (2.0, 0.1)
//        }
//    }
//    private var dismissKeyboardButton: some View {
//        HStack {
//            Spacer()
//            Button(action: { isLyricsFocused = false }) {
//                Image(systemName: "keyboard.chevron.compact.down")
//                    .font(.title2)
//                    .padding(12)
//                    .background(Color.white.opacity(0.1))
//                    .foregroundColor(.blue)
//                    .clipShape(Circle())
//                    .padding(.bottom, keyboardVisible ? 10 : -100)
//            }
//            .animation(.easeInOut, value: keyboardVisible)
//            .padding(.trailing)
//        }
//    }
//    let sectionTags = ["[Intro]", "[Verse]", "[Chorus]", "[Bridge]", "[Hook]", "[Pre-Chorus]", "[Post-Chorus]", "[Outro]"]
//    var body: some View {
//        let mood = SongMood.from(raw: song.mood)
//        let attributes = pulseAttributes(for: song.mood)
//        ZStack(alignment: .topTrailing) {
//            ZStack {
//                if nightFocusMode {
//                    Color.black.ignoresSafeArea()
//                } else {
//                    LinearGradient(
//                        gradient: Gradient(colors: mood.gradient),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                    .ignoresSafeArea()
//                    .opacity(mood == .none ? 0.3 : 0.4)
//                    if enablePulse {
//                        LinearGradient(
//                            gradient: Gradient(colors: mood.gradient),
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                        .ignoresSafeArea()
//                        .opacity(pulseAnimation ? attributes.opacity : 0.02)
//                        .animation(
//                            Animation.easeInOut(duration: attributes.speed)
//                                .repeatForever(autoreverses: true),
//                            value: pulseAnimation
//                        )
//                    }
//                }
//            }
//            VStack(spacing: 0) {
//                HStack {
//                    HStack(spacing: 16) {
//                        if !nightFocusMode {
//                            squareToolbarButton(systemName: showTempoKeyLabels ? "eye.fill" : "eye") {
//                                withAnimation(.easeInOut(duration: 0.25)) {
//                                    showTempoKeyLabels.toggle()
//                                }
//                            }
//                            squareToolbarButton(systemName: "arrow.uturn.backward", disabled: undoStack.count <= 1) {
//                                undo()
//                            }
//                            squareToolbarButton(systemName: "arrow.uturn.forward", disabled: redoStack.isEmpty) {
//                                redo()
//                            }
//                            squareToolbarButton(systemName: "waveform.path.ecg", tint: enablePulse ? .blue : .white.opacity(0.7)) {
//                                withAnimation(.easeInOut(duration: 0.25)) {
//                                    enablePulse.toggle()
//                                }
//                            }
//                            squareToolbarButton(systemName: "textformat", tint: showRhymeScheme ? .green : .white.opacity(0.7)) {
//                                withAnimation(.easeInOut(duration: 0.3)) {
//                                    showRhymeScheme.toggle()
//                                }
//                            }
//                        }
//                        squareToolbarButton(systemName: nightFocusMode ? "moon.stars.fill" : "moon.stars", tint: nightFocusMode ? .mint : .white.opacity(0.7)) {
//                            withAnimation(.easeInOut(duration: 0.25)) {
//                                nightFocusMode.toggle()
//                            }
//                        }
//                    }
//                    Spacer()
//                    if !nightFocusMode {
//                        Button(action: {
//                            saveMetadata()
//                            withAnimation(.easeInOut(duration: 0.25)) {
//                                isPresented = false
//                            }
//                        }) {
//                            Image(systemName: "xmark")
//                                .font(.title2)
//                                .foregroundColor(.white)
//                                .frame(width: 36, height: 36)
//                        }
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 10)
//                if !nightFocusMode {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 10) {
//                            ForEach(sectionTags, id: \.self) { tag in
//                                HStack(spacing: 6) {
//                                    Button(action: {
//                                        song.lyrics += "\n\(tag)\n"
//                                        lyricsScrollTrigger = UUID()
//                                    }) {
//                                        HStack(spacing: 6) {
//                                            Text(tag)
//                                                .font(.caption)
//                                            if showTempoKeyLabels, let meta = sectionMeta[tag] {
//                                                Text("\(meta.tempo) BPM • \(meta.chords)")
//                                                    .font(.caption2)
//                                                    .foregroundColor(.white.opacity(0.6))
//                                            }
//                                        }
//                                    }
//                                    Button(action: {
//                                        selectedTag = tag
//                                        showTagMetaEditor = true
//                                    }) {
//                                        Image(systemName: "slider.horizontal.3")
//                                            .font(.caption)
//                                            .foregroundColor(.blue)
//                                    }
//                                }
//                                .padding(.horizontal, 10)
//                                .padding(.vertical, 6)
//                                .background(tagColor(for: tag).opacity(0.25))
//                                .cornerRadius(8)
//                                .foregroundColor(tagColor(for: tag))
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .stroke(tagColor(for: tag).opacity(0.5), lineWidth: 1)
//                                )
//                            }
//                        }
//                        .padding(.horizontal)
//                        .padding(.bottom, 6)
//                    }
//                }
//                ScrollViewReader { proxy in
//                    ScrollView {
//                        VStack(alignment: .leading, spacing: 8) {
//                            if showRhymeScheme {
//                                VStack(alignment: .leading, spacing: 8) {
//                                    rhymeLegend
//                                        .transition(.opacity.combined(with: .move(edge: .top)))
//                                    ForEach(rhymeGroups) { group in
//                                        Text(group.line)
//                                            .foregroundColor(group.groupColor)
//                                            .font(.body)
//                                            .padding(.horizontal)
//                                            .transition(.opacity.combined(with: .slide))
//                                    }
//                                }
//                                .animation(.easeInOut(duration: 0.25), value: showRhymeScheme)
//                            } else {
//                                CustomTextView(text: $song.lyrics, dynamicHeight: $lyricsHeight)
//                                    .focused($isLyricsFocused)
//                                    .frame(minHeight: lyricsHeight, maxHeight: .infinity)
//                                    .padding(.horizontal, 20)
//                                    .padding(.top, 10)
//                                    .transition(.opacity)
//                            }
//                            Color.clear
//                                .frame(height: 1)
//                                .id("LyricsBottom")
//                        }
//                    }
//                    .onChange(of: lyricsScrollTrigger) { _ in
//                        withAnimation {
//                            proxy.scrollTo("LyricsBottom", anchor: .bottom)
//                        }
//                    }
//                }
//                Text("\(song.lyrics.split { $0.isWhitespace || $0.isNewline }.count) words • \(song.lyrics.count) characters")
//                    .font(.caption)
//                    .foregroundColor(.white.opacity(0.6))
//                    .padding(.bottom, 24)
//            }
//            VStack {
//                Spacer()
//                if keyboardVisible {
//                    dismissKeyboardButton
//                        .animation(.easeInOut(duration: 0.25), value: keyboardVisible)
//                }
//            }
//        }
//        .sheet(isPresented: $showTagMetaEditor) {
//            TagMetaEditorView(
//                tag: selectedTag,
//                initialTempo: sectionMeta[selectedTag]?.tempo ?? 120,
//                initialChords: sectionMeta[selectedTag]?.chords ?? ""
//            ) { tempo, chords in
//                sectionMeta[selectedTag] = (tempo, chords)
//            }
//        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                isLyricsFocused = true
//                undoStack = [song.lyrics]
//            }
//            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
//                keyboardVisible = true
//            }
//            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
//                keyboardVisible = false
//            }
//            loadMetadata()
//        }
//        .onChange(of: song.lyrics) { newValue in
//            guard undoStack.last != newValue else { return }
//            undoStack.append(newValue)
//            redoStack.removeAll()
//        }
//        .onDisappear {
//            saveMetadata()
//            NotificationCenter.default.removeObserver(self)
//        }
//    }
//    private func undo() {
//        guard undoStack.count > 1 else { return }
//        let current = undoStack.removeLast()
//        redoStack.append(current)
//        song.lyrics = undoStack.last ?? ""
//        lyricsEditorID = UUID() // force redraw
//    }
//    private func redo() {
//        guard let redoItem = redoStack.popLast() else { return }
//        undoStack.append(redoItem)
//        song.lyrics = redoItem
//        lyricsEditorID = UUID() // force redraw
//    }
//    private func saveMetadata() {
//        let encoded = sectionMeta.map { tag, data in
//            "\(tag)|\(data.tempo)||\(data.chords)"
//        }.joined(separator: "~~~")
//        let pattern = "<!--sectionMeta:(.*?)-->"
//        if let regex = try? NSRegularExpression(pattern: pattern),
//           let match = regex.firstMatch(in: song.comments, range: NSRange(song.comments.startIndex..., in: song.comments)),
//           let range = Range(match.range, in: song.comments) {
//            song.comments.removeSubrange(range)
//        }
//        song.comments += "\n<!--sectionMeta:\(encoded)-->"
//    }
//    private func loadMetadata() {
//        let pattern = "<!--sectionMeta:(.*?)-->"
//        guard let regex = try? NSRegularExpression(pattern: pattern),
//              let match = regex.firstMatch(in: song.comments, range: NSRange(song.comments.startIndex..., in: song.comments)),
//              let range = Range(match.range(at: 1), in: song.comments) else {
//            return
//        }
//        let dataString = String(song.comments[range])
//        let entries = dataString.components(separatedBy: "~~~")
//        for entry in entries {
//            let parts = entry.components(separatedBy: "||")
//            if parts.count == 2 {
//                let tagAndTempo = parts[0].components(separatedBy: "|")
//                if tagAndTempo.count == 2 {
//                    let tag = tagAndTempo[0]
//                    let tempo = Int(tagAndTempo[1]) ?? 120
//                    let chords = parts[1]
//                    sectionMeta[tag] = (tempo, chords)
//                }
//            }
//        }
//    }
//}
//@ViewBuilder
//private func squareToolbarButton(systemName: String, tint: Color = .white.opacity(0.8), disabled: Bool = false, action: @escaping () -> Void) -> some View {
//    Button(action: action) {
//        Image(systemName: systemName)
//            .font(.title2)
//            .foregroundColor(disabled ? .gray : tint)
//            .frame(width: 36, height: 36)
//    }
//    .disabled(disabled)
//}
//struct TagMetaEditorView: View {
//    var tag: String
//    var initialTempo: Int
//    var initialChords: String
//    var onSave: (Int, String) -> Void
//    @Environment(\.dismiss) private var dismiss
//    @State private var tempo: Int = 120
//    @State private var chords: String = ""
//    var body: some View {
//        let mood = SongMood.from(raw: tag)
//        let gradientColors = mood.gradient
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: gradientColors),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//            VStack(spacing: 20) {
//                Text(tag)
//                    .font(.title2.bold())
//                    .foregroundColor(.white)
//                VStack(spacing: 16) {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Tempo")
//                            .font(.caption)
//                            .foregroundColor(.white.opacity(0.7))
//                        Stepper("\(tempo) BPM", value: $tempo, in: 40...200)
//                            .padding()
//                            .background(Color.white.opacity(0.1))
//                            .cornerRadius(10)
//                            .foregroundColor(.white)
//                    }
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Chords")
//                            .font(.caption)
//                            .foregroundColor(.white.opacity(0.7))
//                        TextField("e.g. C G Am F", text: $chords)
//                            .padding()
//                            .background(Color.white.opacity(0.1))
//                            .cornerRadius(10)
//                            .foregroundColor(.white)
//                            .autocapitalization(.allCharacters)
//                    }
//                }
//                .padding()
//                Button(action: {
//                    onSave(tempo, chords)
//                    dismiss()
//                }) {
//                    Text("Done")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 30)
//                        .padding(.vertical, 12)
//                        .background(Color.white.opacity(0.2))
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
//                        )
//                }
//                Spacer()
//            }
//            .padding()
//        }
//    }
//}
//extension Array where Element: Hashable {
//    func uniqued() -> [Element] {
//        Array(Set(self)).sorted { lhs, rhs in
//            self.firstIndex(of: lhs)! < self.firstIndex(of: rhs)!
//        }
//    }
//}
//struct VisualEffectView: UIViewRepresentable {
//    var effect: UIVisualEffect?
//    func makeUIView(context: Context) -> UIVisualEffectView {
//        UIVisualEffectView(effect: effect)
//    }
//    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
//        uiView.effect = effect
//    }
//}
import SwiftUI
import PDFKit
import UIKit
import Combine
import NaturalLanguage
struct CustomTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var dynamicHeight: CGFloat
    var onTextChange: ((String) -> Void)? = nil
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView
        init(_ parent: CustomTextView) {
            self.parent = parent
        }
        func textViewDidChange(_ textView: UITextView) {
            let originalText = textView.text ?? ""
            let selectedRange = textView.selectedRange
            let lines = originalText.components(separatedBy: .newlines)
            
            let convertedLines = lines.map { line -> String in
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                switch trimmed {
                case "verse:", "verse":
                    return "[Verse]"
                case "chorus:", "chorus":
                    return "[Chorus]"
                case "bridge:", "bridge":
                    return "[Bridge]"
                case "intro:", "intro":
                    return "[Intro]"
                case "hook:", "hook":
                    return "[Hook]"
                case "pre-chorus:", "pre-chorus":
                    return "[Pre-Chorus]"
                case "post-chorus:", "post-chorus":
                    return "[Post-Chorus]"
                case "outro:", "outro":
                    return "[Outro]"
                default:
                    return line
                }
            }
            let newText = convertedLines.joined(separator: "\n")
            if newText != originalText {
                textView.attributedText = parent.formatText(newText)
                textView.selectedRange = selectedRange
            }
            if parent.text != newText {
                parent.text = newText
                parent.onTextChange?(newText)
            }
            textView.typingAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 16)
            ]
            let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
            DispatchQueue.main.async {
                self.parent.dynamicHeight = newSize.height
            }
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.typingAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16)
        ]
        return textView
    }
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            let selectedRange = uiView.selectedRange
            uiView.attributedText = formatText(text)
            uiView.selectedRange = selectedRange
        }
        DispatchQueue.main.async {
            CustomTextView.recalculateHeight(view: uiView, result: &dynamicHeight)
        }
    }
    static func recalculateHeight(view: UITextView, result: inout CGFloat) {
        let size = view.sizeThatFits(CGSize(width: view.frame.size.width, height: .greatestFiniteMagnitude))
        if result != size.height {
            result = size.height
        }
    }
    private func formatText(_ raw: String) -> NSAttributedString {
        let fullString = NSMutableAttributedString()
        let lines = raw.components(separatedBy: .newlines)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.headIndent = 8
        paragraphStyle.firstLineHeadIndent = 0
        let tagRegex = "\\[(Intro|Verse|Chorus|Bridge|Hook|Outro|Pre-Chorus|Post-Chorus)\\]"
        for line in lines {
            let attrLine = NSMutableAttributedString()
            if let match = try? NSRegularExpression(pattern: tagRegex)
                .firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count)) {
                let matchRange = match.range
                let nsLine = line as NSString
                let tag = nsLine.substring(with: matchRange)
                let restOfLine = nsLine.replacingCharacters(in: matchRange, with: "").trimmingCharacters(in: .whitespaces)
                let shadow = NSShadow()
                shadow.shadowColor = colorForTag(tag)?.withAlphaComponent(0.5)
                shadow.shadowBlurRadius = 2
                shadow.shadowOffset = CGSize(width: 0.5, height: 1)
                let tagAttr = NSMutableAttributedString(string: tag + " ")
                tagAttr.addAttributes([
                    .foregroundColor: colorForTag(tag) ?? .white,
                    .font: UIFont.boldSystemFont(ofSize: 17),
                    .shadow: shadow
                ], range: NSRange(location: 0, length: tagAttr.length))
                attrLine.append(tagAttr)
                let contentAttr = NSMutableAttributedString(string: restOfLine)
                contentAttr.addAttributes([
                    .foregroundColor: UIColor.white,
                    .font: UIFont(name: "Charter-Italic", size: 17) ?? UIFont.systemFont(ofSize: 17)
                ], range: NSRange(location: 0, length: contentAttr.length))
                attrLine.append(contentAttr)
            } else {
                let normalLine = NSMutableAttributedString(string: line)
                normalLine.addAttributes([
                    .foregroundColor: UIColor.white,
                    .font: UIFont(name: "Charter-Italic", size: 17) ?? UIFont.systemFont(ofSize: 17)
                ], range: NSRange(location: 0, length: normalLine.length))
                attrLine.append(normalLine)
            }
            attrLine.addAttributes([
                .paragraphStyle: paragraphStyle
            ], range: NSRange(location: 0, length: attrLine.length))
            fullString.append(attrLine)
            fullString.append(NSAttributedString(string: "\n"))
        }
        return fullString
    }
    private func colorForTag(_ tag: String) -> UIColor? {
        switch tag {
        case "[Intro]": return .systemRed
        case "[Verse]": return .systemPurple
        case "[Chorus]": return .systemBlue
        case "[Bridge]": return .systemOrange
        case "[Outro]": return .lightGray
        case "[Hook]": return .systemPink
        case "[Pre-Chorus]": return .systemTeal
        case "[Post-Chorus]": return .systemYellow
        default: return nil
        }
    }
}
struct SongEditorView: View {
    @EnvironmentObject var store: SongStore
    @Environment(\.dismiss) private var dismiss
    @Binding var song: Song
    var isNew: Bool = false
    @State private var showAlert = false
    @State private var showMetadataSheet = false
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    @FocusState private var isLyricsFocused: Bool
    @State private var keyboardVisible: Bool = false
    @State private var lyricsTextEditorID = UUID()
    @State private var lyricsHeight: CGFloat = 300
    @State private var showCustomTagField = false
    @State private var customTagInput = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var customMoodText: String = ""
    @State private var tagInput: String = ""
    @State private var scrollOffset: CGFloat = 0
    @State private var isLyricsExpanded: Bool = false
    @State private var showFullLyricsEditor = false
    @State private var lyricsScrollTrigger = UUID()
    @State private var showInsightsSheet = false
    @State private var showRecorder = false
    @StateObject private var audioRecorderVM = AudioRecorderViewModel()
    @State private var quickNote: String = ""
    @State private var showQuickNote = false
    @State private var undoStack: [String] = []
    @State private var redoStack: [String] = []
    @State private var lyricsEditorID = UUID()
    @State private var showCreativeToolkit = false
    @State private var selectedToolkitTab: String = "Scratch"
    @State private var savedHooks: [String] = []
    @State private var lyricsFragments: [String] = []
    @State private var phrases: [String: [String]] = [:]
    let sectionTags = ["[Intro]", "[Verse]", "[Chorus]", "[Bridge]", "[Outro]", "[Hook]", "[Pre-Chorus]", "[Post-Chorus]"]
    let statusOptions = ["Draft", "In Progress", "Completed"]
    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundGradient
            mainContent
                .onAppear {
                    quickNote = UserDefaults.standard.string(forKey: "note_\(song.id.uuidString)") ?? ""
                }
                .onChange(of: quickNote) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "note_\(song.id.uuidString)")
                }
            if isLyricsFocused { dismissKeyboardButton }
        }
        .onReceive(Publishers.keyboardHeight) { height in
            keyboardVisible = height > 0
        }
        .sheet(isPresented: $showMetadataSheet) { metadataSheet }
        .sheet(isPresented: $showShareSheet) {
            if let url = shareURL {
                ShareSheet(activityItems: [url])
            }
        }
        .sheet(isPresented: $showInsightsSheet) {
            SongInsightsView(lyrics: song.lyrics)
        }
        .sheet(isPresented: $showCreativeToolkit) {
            CreativeToolkitDrawer(
                isPresented: $showCreativeToolkit,
                scratchPadText: $quickNote,
                savedHooks: $savedHooks,
                savedFragments: $lyricsFragments,
                phraseBuilderData: $phrases,
                onInsert: { inserted in
                    song.lyrics += "\n" + inserted
                }
            )
            .presentationDetents([.fraction(1.0)])
            .presentationDragIndicator(.hidden)
        }
        .presentationDetents([.fraction(1.0)])
        .presentationDragIndicator(.hidden)
        .alert("Title Required", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a song title before saving.")
        }
    }
    private var backgroundGradient: some View {
        RadialGradient(
            gradient: Gradient(colors: [Color(hex: "#10002B"), Color(hex: "#240046"), Color(hex: "#3C096C")]),
            center: .center,
            startRadius: 100,
            endRadius: 700
        ).ignoresSafeArea()
    }
    private var mainContent: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(title: "Song Info", icon: "music.note")
                titleAndTypeRow
                Group {
                    if song.type == .ep || song.type == .album {
                        VStack(spacing: 6) {
                            epOrAlbumNameField
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .scale(scale: 0.95).combined(with: .opacity)
                        ))
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: song.type)
                Divider().background(Color.white.opacity(0.05)).padding(.vertical, 4)
                VStack(alignment: .leading, spacing: 4) {
                    sectionTagsScroll
                }
                VStack(alignment: .leading, spacing: 4) {
                    tagsInputBar
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            lyricsEditor
                .layoutPriority(1)
                .frame(minHeight: 160, maxHeight: .infinity)
            Spacer(minLength: 10)
            if !keyboardVisible {
                bottomToolbar
            }
        }
    }
    private var titleAndTypeRow: some View {
        HStack(spacing: 12) {
            TextField("", text: $song.title)
                .placeholder(when: song.title.isEmpty) {
                    Text("New Song Title")
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.leading, 12)
                }
                .font(.title2.bold())
                .padding(10)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
                .foregroundColor(.white)
            Menu {
                ForEach(SongType.allCases) { option in
                    Button(option.rawValue.capitalized) {
                        withAnimation {
                            song.type = option
                        }
                    }
                }
            } label: {
                HStack {
                    Text(song.type.rawValue.capitalized)
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    private var epOrAlbumNameField: some View {
        TextField("", text: $song.epOrAlbumName)
            .placeholder(when: song.epOrAlbumName.isEmpty) {
                Text("Enter \(song.type.rawValue.capitalized) Name")
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.leading, 12)
            }
            .font(.subheadline)
            .padding(10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
            .foregroundColor(.white)
    }
    private var sectionTagsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(sectionTags, id: \.self) { tag in
                    Button(action: { insertTag(tag) }) {
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(tagColor(for: tag).opacity(0.25))
                            .cornerRadius(8)
                            .foregroundColor(tagColor(for: tag))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(tagColor(for: tag).opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                if showCustomTagField {
                    HStack(spacing: 6) {
                        TextField("Tag", text: $customTagInput)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 8)
                            .frame(width: 120)
                            .foregroundColor(.white)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(6)
                        Button(action: {
                            if !customTagInput.trimmingCharacters(in: .whitespaces).isEmpty {
                                insertTag("[\(customTagInput)]")
                                customTagInput = ""
                                showCustomTagField = false
                            }
                        }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .transition(.opacity)
                } else {
                    Button(action: {
                        withAnimation { showCustomTagField = true }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(6)
                    }
                }
            }
        }
    }
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.6))
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }
    private var tagsInputBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TextField("#tags", text: $tagInput, onCommit: addTagFromInput)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                    .overlay(
                        Group {
                            if tagInput.isEmpty {
                                Text("")
                                    .foregroundColor(.white.opacity(0.3))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    )
                Button(action: addTagFromInput) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            if !song.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(song.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                            Button(action: {
                                withAnimation {
                                    song.tags.removeAll { $0 == tag }
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .transition(.opacity)
            }
            Divider()
                .background(Color.white.opacity(0.2))
        }
        .padding(.top, 4)
    }
    private var lyricsEditor: some View {
        let mood = SongMood.from(raw: song.mood)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Lyrics")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showFullLyricsEditor = true
                    }
                }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(6)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                Button(action: {
                    showRecorder = true
                }) {
                    Image(systemName: "mic.circle")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(6)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: mood.gradient),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .opacity(mood == .none ? 0 : 0.35)
                    )
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            CustomTextView(
                                text: $song.lyrics,
                                dynamicHeight: $lyricsHeight,
                                onTextChange: { newValue in
                                    guard undoStack.last != newValue else { return }
                                    undoStack.append(newValue)
                                    redoStack.removeAll()
                                    lyricsEditorID = UUID() // Force UI refresh
                                }
                            )
                            .id(lyricsEditorID)
                                .disabled(true)
                                .frame(minHeight: lyricsHeight)
                                .padding(12)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        showFullLyricsEditor = true
                                    }
                                }
                            
                            Color.clear
                                .frame(height: 1)
                                .id("LyricsBottom")
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .onChange(of: lyricsScrollTrigger) { _ in
                        withAnimation {
                            proxy.scrollTo("LyricsBottom", anchor: .bottom)
                        }
                    }
                }
            }
            .frame(minHeight: 180, maxHeight: .infinity)
            .padding(.horizontal)
            HStack {
                Button(action: {
                    showCreativeToolkit = true
                }) {
                    Label("Creative Toolkit", systemImage: "rectangle.3.offgrid")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .underline()
                }
                Spacer()
                Button(action: {
                    showInsightsSheet = true
                }) {
                    Label("View Song Insights", systemImage: "chart.bar.doc.horizontal")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .underline()
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
        .fullScreenCover(isPresented: $showFullLyricsEditor) {
            FullscreenLyricsView(song: $song, isPresented: $showFullLyricsEditor)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .sheet(isPresented: $showRecorder) {
            AudioRecorderView(viewModel: audioRecorderVM, section: nil)
        }
    }
    private var bottomToolbar: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: Color.red.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            Spacer()
            Button(action: { showMetadataSheet = true }) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.85))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: Color.white.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            Button(action: {
                shareURL = exportSongAsPDF()
                showShareSheet = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.85))
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: Color.white.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            Spacer()
            Button(action: {
                if song.title.trimmingCharacters(in: .whitespaces).isEmpty {
                    showAlert = true
                    return
                }
                addTagFromInput()
                song.updatedAt = Date()
                if isNew {
                    store.addSong(song)
                }
                dismiss()
            }) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: Color.blue.opacity(0.2), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(Color.clear)
    }
    private var dismissKeyboardButton: some View {
        HStack {
            Spacer()
            Button(action: { isLyricsFocused = false }) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.title2)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.blue)
                    .clipShape(Circle())
                    .padding(.bottom, keyboardVisible ? 10 : -100)
            }
            .padding(.trailing)
        }
        .padding(.bottom, keyboardHeight + 12)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    private var metadataSheet: some View {
        let accent = SongMood.from(raw: song.mood).gradient.first ?? .blue
        
        return ScrollView {
            VStack(spacing: 28) {
                HStack {
                    Spacer()
                    Text("Song Metadata")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { showMetadataSheet = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Picker("Status", selection: $song.status) {
                        ForEach(statusOptions, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(accent.opacity(0.3), lineWidth: 1)
                    )
                }
                Group {
                    metadataField(title: "Genre", text: $song.genre, accent: accent)
                    metadataField(title: "Key", text: $song.key, accent: accent)
                    metadataField(title: "Tempo (BPM)", text: $song.tempo, accent: accent)
                }
                moodPickerSection(accent: accent)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Comments")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    TextEditor(text: $song.comments)
                        .frame(height: 90)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                }
                Spacer(minLength: 40)
            }
            .padding()
        }
        .background {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#14002B"),
                        Color(hex: "#2E1452"),
                        Color(hex: "#392F7D")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                Ellipse()
                    .fill(accent.opacity(0.18))
                    .frame(width: 400, height: 280)
                    .blur(radius: 120)
                    .offset(x: 120, y: -200)
                Ellipse()
                    .fill(accent.opacity(0.12))
                    .frame(width: 300, height: 200)
                    .blur(radius: 100)
                    .offset(x: -80, y: 250)
                Circle()
                    .fill(Color.white.opacity(0.03))
                    .frame(width: 600, height: 600)
                    .blur(radius: 150)
                    .offset(x: -150, y: -300)
            }
        }
    }
    private func insertTag(_ tag: String) {
        song.lyrics += "\n\(tag)\n"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            lyricsScrollTrigger = UUID()
        }
    }
    private func addTagFromInput() {
        let cleanedTags = tagInput
            .split(separator: " ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "") }
            .filter { !$0.isEmpty && !song.tags.contains($0) }
        
        if !cleanedTags.isEmpty {
            song.tags.append(contentsOf: cleanedTags)
        }
        tagInput = ""
    }
    private func tagColor(for tag: String) -> Color {
        switch tag {
        case "[Verse]": return .purple
        case "[Chorus]": return .blue
        case "[Bridge]": return .orange
        case "[Hook]": return .pink
        case "[Outro]": return .gray
        case "[Pre-Chorus]": return .mint
        case "[Intro]": return .red
        case "[Post-Chorus]": return .yellow
        default: return .white
        }
    }
    private func metadataField(title: String, text: Binding<String>, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            TextField("", text: text)
                .placeholder(when: text.wrappedValue.isEmpty) {
                    Text("Enter \(title.lowercased())")
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accent.opacity(0.25), lineWidth: 1)
                )
                .foregroundColor(.white)
        }
    }
    private func moodPickerSection(accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mood")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 12) {
                Picker("Select Mood", selection: Binding(
                    get: {
                        SongMood.from(raw: song.mood).rawValue == "custom" ? "custom" : song.mood
                    },
                    set: { newValue in
                        if newValue == "custom" {
                            song.mood = "custom"
                        } else {
                            song.mood = newValue
                            customMoodText = ""
                        }
                    }
                )) {
                    ForEach(SongMood.grouped().sorted(by: { $0.key < $1.key }), id: \.key) { category, moods in
                        Section(header: Text(category).foregroundColor(.white.opacity(0.4))) {
                            ForEach(moods) { mood in
                                Text(mood.displayName).tag(mood.rawValue)
                            }
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accent.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Created")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    Text(song.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Updated")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                    Text(song.updatedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
            }
            if SongMood.from(raw: song.mood) == .custom {
                TextField("", text: Binding(
                    get: { customMoodText },
                    set: {
                        customMoodText = $0
                        song.mood = $0.isEmpty ? "custom" : $0
                    }
                ))
                .placeholder(when: customMoodText.isEmpty) {
                    Text("Enter your custom mood")
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accent.opacity(0.2), lineWidth: 1)
                )
                .foregroundColor(.white)
            }
        }
    }
    private var wordCount: Int {
        song.lyrics.split { $0.isWhitespace || $0.isNewline }.count
    }
    private var characterCount: Int {
        song.lyrics.count
    }
    private func exportSongAsPDF() -> URL? {
        let pdfMeta = """
        Title: \(song.title)
        Type: \(song.type.rawValue.capitalized)
        EP/Album: \(song.epOrAlbumName)
        Genre: \(song.genre)
        Key: \(song.key)
        Tempo: \(song.tempo)
        Mood: \(song.mood)
        Status: \(song.status)
        Comments: \(song.comments)
        Lyrics:
        \(song.lyrics)
        """
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(song.title)-Lyrics.pdf")
        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
                pdfMeta.draw(in: CGRect(x: 20, y: 20, width: 572, height: 752), withAttributes: attrs)
            }
            return url
        } catch {
            print("Failed to write PDF: \(error)")
            return nil
        }
    }
}
struct RhymeLineGroup: Identifiable {
    let id = UUID()
    let line: String
    let groupColor: Color
}
struct FullscreenLyricsView: View {
    @Binding var song: Song
    @Binding var isPresented: Bool
    @FocusState private var isLyricsFocused: Bool
    @State private var lyricsHeight: CGFloat = 300
    @State private var lyricsScrollTrigger = UUID()
    @State private var keyboardVisible: Bool = false
    @State private var undoStack: [String] = []
    @State private var redoStack: [String] = []
    @State private var sectionMeta: [String: (tempo: Int, chords: String)] = [:]
    @State private var selectedTag: String = ""
    @State private var showTagMetaEditor = false
    @State private var showTempoKeyLabels = true
    @State private var enablePulse = true
    @State private var pulseAnimation = false
    @State private var nightFocusMode = false
    @State private var showRhymeScheme = false
    @State private var lyricsEditorID = UUID()
    private var rhymeGroups: [RhymeLineGroup] {
        let lines = song.lyrics.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        var profiles: [(index: Int, word: String, profile: (String, String, String))] = []
        for (i, line) in lines.enumerated() {
            if line.isEmpty || (line.hasPrefix("[") && line.hasSuffix("]")) {
                profiles.append((i, "", ("", "", "")))
                continue
            }
            let lastWord = line.components(separatedBy: .whitespaces).last ?? ""
            profiles.append((i, lastWord, phoneticProfile(for: lastWord)))
        }
        var colors = Array([Color.green, .yellow, .blue, .purple, .gray])
        var assignedColors = Array(repeating: Color.white, count: lines.count)
        for i in 0..<profiles.count {
            for j in (i+1)..<profiles.count {
                let (v1, c1, s1) = profiles[i].profile
                let (v2, c2, s2) = profiles[j].profile
                let color: Color
                if s1 == s2 && s1 != "" {
                    color = .green
                } else if v1 == v2 && c1 == c2 {
                    color = .yellow
                } else if v1 == v2 {
                    color = .blue
                } else if c1 == c2 {
                    color = .purple
                } else {
                    continue
                }
                assignedColors[profiles[i].index] = color
                assignedColors[profiles[j].index] = color
            }
        }
        return lines.enumerated().map { (i, line) in
            let color = assignedColors[i] == .white ? .white.opacity(0.6) : assignedColors[i]
            return RhymeLineGroup(line: line, groupColor: color)
        }
    }
    private var rhymeLegend: some View {
        HStack(spacing: 14) {
            legendItem(color: .green, label: "Perfect")
            legendItem(color: .yellow, label: "Slant")
            legendItem(color: .blue, label: "Assonance")
            legendItem(color: .purple, label: "Consonance")
            legendItem(color: .white.opacity(0.6), label: "None")
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    private func phoneticProfile(for word: String) -> (vowelCluster: String, consonantCluster: String, suffix: String) {
        let vowels = "aeiou"
        let cleaned = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
        let suffix = String(cleaned.suffix(3))
        let reversed = cleaned.reversed()
        let vowel = reversed.first { vowels.contains($0) } ?? "-"
        let consonant = reversed.first { !vowels.contains($0) } ?? "-"
        return (String(vowel), String(consonant), suffix)
    }
    private func tagColor(for tag: String) -> Color {
        switch tag {
        case "[Verse]": return .purple
        case "[Chorus]": return .blue
        case "[Bridge]": return .orange
        case "[Hook]": return .pink
        case "[Outro]": return .gray
        case "[Pre-Chorus]": return .mint
        case "[Intro]": return .red
        case "[Post-Chorus]": return .yellow
        default: return .white
        }
    }
    private func pulseAttributes(for mood: String) -> (speed: Double, opacity: Double) {
        switch mood {
        case "sad", "heartbroken", "melancholy": return (3.5, 0.07)
        case "angry", "frustrated", "rebellious": return (1.0, 0.2)
        case "joyful", "optimistic", "carefree": return (1.5, 0.15)
        case "thoughtful", "nostalgic", "wistful": return (2.5, 0.1)
        case "mysterious", "ethereal", "surreal": return (2.2, 0.13)
        case "empowering", "romantic", "playful": return (1.4, 0.12)
        default: return (2.0, 0.1)
        }
    }
    private var dismissKeyboardButton: some View {
        HStack {
            Spacer()
            Button(action: { isLyricsFocused = false }) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.title2)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.blue)
                    .clipShape(Circle())
                    .padding(.bottom, keyboardVisible ? 10 : -100)
            }
            .animation(.easeInOut, value: keyboardVisible)
            .padding(.trailing)
        }
    }
    let sectionTags = ["[Intro]", "[Verse]", "[Chorus]", "[Bridge]", "[Hook]", "[Pre-Chorus]", "[Post-Chorus]", "[Outro]"]
    var body: some View {
        let mood = SongMood.from(raw: song.mood)
        let attributes = pulseAttributes(for: song.mood)
        ZStack(alignment: .topTrailing) {
            ZStack {
                if nightFocusMode {
                    Color.black.ignoresSafeArea()
                } else {
                    LinearGradient(
                        gradient: Gradient(colors: mood.gradient),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    .opacity(mood == .none ? 0.3 : 0.4)
                    if enablePulse {
                        LinearGradient(
                            gradient: Gradient(colors: mood.gradient),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        .opacity(pulseAnimation ? attributes.opacity : 0.02)
                        .animation(
                            Animation.easeInOut(duration: attributes.speed)
                                .repeatForever(autoreverses: true),
                            value: pulseAnimation
                        )
                    }
                }
            }
            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: 16) {
                        if !nightFocusMode {
                            squareToolbarButton(systemName: showTempoKeyLabels ? "eye.fill" : "eye") {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showTempoKeyLabels.toggle()
                                }
                            }
                            squareToolbarButton(systemName: "arrow.uturn.backward", disabled: undoStack.count <= 1) {
                                undo()
                            }
                            squareToolbarButton(systemName: "arrow.uturn.forward", disabled: redoStack.isEmpty) {
                                redo()
                            }
                            squareToolbarButton(systemName: "waveform.path.ecg", tint: enablePulse ? .blue : .white.opacity(0.7)) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    enablePulse.toggle()
                                }
                            }
                            squareToolbarButton(systemName: "textformat", tint: showRhymeScheme ? .green : .white.opacity(0.7)) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showRhymeScheme.toggle()
                                }
                            }
                        }
                        squareToolbarButton(systemName: nightFocusMode ? "moon.stars.fill" : "moon.stars", tint: nightFocusMode ? .mint : .white.opacity(0.7)) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                nightFocusMode.toggle()
                            }
                        }
                    }
                    Spacer()
                    if !nightFocusMode {
                        Button(action: {
                            saveMetadata()
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                if !nightFocusMode {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(sectionTags, id: \.self) { tag in
                                HStack(spacing: 6) {
                                    Button(action: {
                                        song.lyrics += "\n\(tag)\n"
                                        lyricsScrollTrigger = UUID()
                                    }) {
                                        HStack(spacing: 6) {
                                            Text(tag)
                                                .font(.caption)
                                            if showTempoKeyLabels, let meta = sectionMeta[tag] {
                                                Text("\(meta.tempo) BPM • \(meta.chords)")
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.6))
                                            }
                                        }
                                    }
                                    Button(action: {
                                        selectedTag = tag
                                        showTagMetaEditor = true
                                    }) {
                                        Image(systemName: "slider.horizontal.3")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(tagColor(for: tag).opacity(0.25))
                                .cornerRadius(8)
                                .foregroundColor(tagColor(for: tag))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(tagColor(for: tag).opacity(0.5), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 6)
                    }
                }
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            if showRhymeScheme {
                                VStack(alignment: .leading, spacing: 8) {
                                    rhymeLegend
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    ForEach(rhymeGroups) { group in
                                        Text(group.line)
                                            .foregroundColor(group.groupColor)
                                            .font(.body)
                                            .padding(.horizontal)
                                            .transition(.opacity.combined(with: .slide))
                                    }
                                }
                                .animation(.easeInOut(duration: 0.25), value: showRhymeScheme)
                            } else {
                                CustomTextView(text: $song.lyrics, dynamicHeight: $lyricsHeight)
                                    .focused($isLyricsFocused)
                                    .frame(minHeight: lyricsHeight, maxHeight: .infinity)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 10)
                                    .transition(.opacity)
                            }
                            Color.clear
                                .frame(height: 1)
                                .id("LyricsBottom")
                        }
                    }
                    .onChange(of: lyricsScrollTrigger) { _ in
                        withAnimation {
                            proxy.scrollTo("LyricsBottom", anchor: .bottom)
                        }
                    }
                }
                Text("\(song.lyrics.split { $0.isWhitespace || $0.isNewline }.count) words • \(song.lyrics.count) characters")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 24)
            }
            VStack {
                Spacer()
                if keyboardVisible {
                    dismissKeyboardButton
                        .animation(.easeInOut(duration: 0.25), value: keyboardVisible)
                }
            }
        }
        .sheet(isPresented: $showTagMetaEditor) {
            TagMetaEditorView(
                tag: selectedTag,
                initialTempo: sectionMeta[selectedTag]?.tempo ?? 120,
                initialChords: sectionMeta[selectedTag]?.chords ?? ""
            ) { tempo, chords in
                sectionMeta[selectedTag] = (tempo, chords)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isLyricsFocused = true
                undoStack = [song.lyrics]
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                keyboardVisible = true
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardVisible = false
            }
            loadMetadata()
        }
        .onChange(of: song.lyrics) { newValue in
            guard undoStack.last != newValue else { return }
            undoStack.append(newValue)
            redoStack.removeAll()
        }
        .onDisappear {
            saveMetadata()
            NotificationCenter.default.removeObserver(self)
        }
    }
    private func undo() {
        guard undoStack.count > 1 else { return }
        let current = undoStack.removeLast()
        redoStack.append(current)
        song.lyrics = undoStack.last ?? ""
        lyricsEditorID = UUID() // force redraw
    }
    private func redo() {
        guard let redoItem = redoStack.popLast() else { return }
        undoStack.append(redoItem)
        song.lyrics = redoItem
        lyricsEditorID = UUID() // force redraw
    }
    private func saveMetadata() {
        let encoded = sectionMeta.map { tag, data in
            "\(tag)|\(data.tempo)||\(data.chords)"
        }.joined(separator: "~~~")
        let pattern = "<!--sectionMeta:(.*?)-->"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: song.comments, range: NSRange(song.comments.startIndex..., in: song.comments)),
           let range = Range(match.range, in: song.comments) {
            song.comments.removeSubrange(range)
        }
        song.comments += "\n<!--sectionMeta:\(encoded)-->"
    }
    private func loadMetadata() {
        let pattern = "<!--sectionMeta:(.*?)-->"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: song.comments, range: NSRange(song.comments.startIndex..., in: song.comments)),
              let range = Range(match.range(at: 1), in: song.comments) else {
            return
        }
        let dataString = String(song.comments[range])
        let entries = dataString.components(separatedBy: "~~~")
        for entry in entries {
            let parts = entry.components(separatedBy: "||")
            if parts.count == 2 {
                let tagAndTempo = parts[0].components(separatedBy: "|")
                if tagAndTempo.count == 2 {
                    let tag = tagAndTempo[0]
                    let tempo = Int(tagAndTempo[1]) ?? 120
                    let chords = parts[1]
                    sectionMeta[tag] = (tempo, chords)
                }
            }
        }
    }
}
@ViewBuilder
private func squareToolbarButton(systemName: String, tint: Color = .white.opacity(0.8), disabled: Bool = false, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Image(systemName: systemName)
            .font(.title2)
            .foregroundColor(disabled ? .gray : tint)
            .frame(width: 36, height: 36)
    }
    .disabled(disabled)
}
struct TagMetaEditorView: View {
    var tag: String
    var initialTempo: Int
    var initialChords: String
    var onSave: (Int, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var tempo: Int = 120
    @State private var chords: String = ""
    var body: some View {
        let mood = SongMood.from(raw: tag)
        let gradientColors = mood.gradient
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 20) {
                Text(tag)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tempo")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Stepper("\(tempo) BPM", value: $tempo, in: 40...200)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chords")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        TextField("e.g. C G Am F", text: $chords)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .autocapitalization(.allCharacters)
                    }
                }
                .padding()
                Button(action: {
                    onSave(tempo, chords)
                    dismiss()
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                Spacer()
            }
            .padding()
        }
    }
}
extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        Array(Set(self)).sorted { lhs, rhs in
            self.firstIndex(of: lhs)! < self.firstIndex(of: rhs)!
        }
    }
}
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
enum ToolkitTab: String, CaseIterable, Identifiable {
    case quickNotes, savedHooks, phraseBuilder, fragments
    var id: String { self.rawValue }
}
struct CreativeToolkitDrawer: View {
    @Binding var isPresented: Bool
    @Binding var scratchPadText: String
    @Binding var savedHooks: [String]
    @Binding var savedFragments: [String]
    @Binding var phraseBuilderData: [String: [String]]
    var onInsert: ((String) -> Void)? = nil
    @State private var selectedTab: String = "Scratch"
    @State private var newHook: String = ""
    @State private var newFragment: String = ""
    @State private var newPhrase: String = ""
    @State private var selectedCategory: String = "General"
    @FocusState private var isInputFocused: Bool

    let tabs = ["Scratch", "Hooks", "Phrases", "Fragments"]
    let phraseCategories = ["General", "Love", "Conflict", "Hope", "Nature"]

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            HStack(spacing: 8) {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: {
                        withAnimation { selectedTab = tab }
                    }) {
                        Text(tab)
                            .font(.caption.bold())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(selectedTab == tab ? Color.white.opacity(0.2) : Color.clear)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                Spacer()
                Button(action: {
                    withAnimation { isPresented = false }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider().background(Color.white.opacity(0.1))

            ScrollView {
                VStack(spacing: 14) {
                    switch selectedTab {
                    case "Scratch":
                        scratchPadSection
                    case "Hooks":
                        hooksSection
                    case "Fragments":
                        fragmentsSection
                    case "Phrases":
                        phraseBuilderSection
                    default:
                        EmptyView()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            Spacer(minLength: 16)
        }
        .background(
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: "#10002B"), Color(hex: "#240046")]),
                center: .center,
                startRadius: 100,
                endRadius: 700
            ).ignoresSafeArea()
        )
    }

    private var scratchPadSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Notes")
                .font(.headline)
                .foregroundColor(.white)
            TextEditor(text: $scratchPadText)
                .frame(height: 160)
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .foregroundColor(.white)
                .focused($isInputFocused)
        }
    }

    private var hooksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Saved Hooks")
                .font(.headline)
                .foregroundColor(.white)
            HStack {
                TextField("Add new hook", text: $newHook)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .focused($isInputFocused)
                Button(action: {
                    if !newHook.isEmpty {
                        savedHooks.insert(newHook, at: 0)
                        newHook = ""
                    }
                }) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            ForEach(savedHooks, id: \.self) { hook in
                HStack {
                    Text("🎣 \(hook)")
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        savedHooks.removeAll { $0 == hook }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
                .padding(6)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
        }
    }

    private var fragmentsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lyrics Fragments")
                .font(.headline)
                .foregroundColor(.white)
            HStack {
                TextField("Add fragment", text: $newFragment)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .focused($isInputFocused)
                Button(action: {
                    if !newFragment.isEmpty {
                        savedFragments.insert(newFragment, at: 0)
                        newFragment = ""
                    }
                }) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            ForEach(savedFragments, id: \.self) { fragment in
                HStack {
                    Text("💡 \(fragment)")
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        savedFragments.removeAll { $0 == fragment }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
                .padding(6)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            }
        }
    }

    private var phraseBuilderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Phrase Builder")
                .font(.headline)
                .foregroundColor(.white)

            Picker("Category", selection: $selectedCategory) {
                ForEach(phraseCategories, id: \.self) { cat in
                    Text(cat).tag(cat)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 6)

            HStack {
                TextField("Add phrase to \(selectedCategory)", text: $newPhrase)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .focused($isInputFocused)
                Button(action: {
                    if !newPhrase.isEmpty {
                        phraseBuilderData[selectedCategory, default: []].insert(newPhrase, at: 0)
                        newPhrase = ""
                    }
                }) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.blue)
                }
            }

            if let phrases = phraseBuilderData[selectedCategory], !phrases.isEmpty {
                ForEach(phrases, id: \.self) { phrase in
                    HStack {
                        Text("✍️ \(phrase)")
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            phraseBuilderData[selectedCategory]?.removeAll { $0 == phrase }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red.opacity(0.7))
                        }
                    }
                    .padding(6)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
    }
}
