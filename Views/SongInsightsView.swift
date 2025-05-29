//  SongInsightsView.swift
//  Hookline
//  Created by Pulkit Jain on 22/4/2025.
import SwiftUI
import NaturalLanguage
import Charts
struct EmotionPoint: Identifiable {
    let id = UUID()
    let index: Int
    let score: Double
    let line: String
}
struct KeywordStat: Identifiable {
    let id = UUID()
    let word: String
    let count: Int
}
struct FlowStat {
    let lineIndex: Int
    let syllables: Int
}
enum InsightFilter: String, CaseIterable {
    case technical = "Technical"
    case emotion = "Emotion"
    case advanced = "Advanced"
}
struct SongInsightsView: View {
    let lyrics: String
    @State private var selectedTab: InsightFilter = .technical
    @State private var selectedEmotionLine: String? = nil
    var body: some View {
        VStack {
            Picker("Insights", selection: $selectedTab) {
                ForEach(InsightFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            ZStack {
                if selectedTab == .technical {
                    technicalTab.transition(.opacity)
                } else if selectedTab == .emotion {
                    emotionTab.transition(.opacity)
                } else if selectedTab == .advanced {
                    advancedTab.transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#141e30"), Color(hex: "#243b55")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    private var advancedTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header("Clarity & Density", systemImage: "eye.trianglebadge.exclamationmark")
                clarityPanel
                header("Perspective & Tense", systemImage: "person.3.sequence")
                perspectivePanel
            }
            .padding()
        }
    }
    private var sectionStrengthPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(deduplicatedSectionStats.indices, id: \.self) { i in
                let s = deduplicatedSectionStats[i]
                let score = (Double(s.words) + Double(s.unique) + s.rhyme * 100) / 3.0
                Text("\(s.name): Strength Score: \(String(format: "%.0f", score))")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    private var clarityPanel: some View {
        let words = lyrics.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        let wordCount = words.count
        let sentenceCount = lyrics.components(separatedBy: CharacterSet(charactersIn: ".!?\n")).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
        let syllableCount = words.map(syllableCount).reduce(0, +)
        let fleschScore = 206.835 - (1.015 * (Double(wordCount) / Double(max(sentenceCount, 1)))) - (84.6 * (Double(syllableCount) / Double(max(wordCount, 1))))
        let density = Double(keywordStats.count) / Double(max(wordCount, 1))
        return VStack(alignment: .leading, spacing: 6) {
            Text("Flesch Reading Ease: \(String(format: "%.1f", fleschScore))")
                .foregroundColor(.white.opacity(0.7))
            Text("Lexical Density: \(String(format: "%.2f", density))")
                .foregroundColor(.white.opacity(0.7))
        }
    }
    private var perspectivePanel: some View {
        let firstPersonWords = ["i", "me", "my", "mine", "we", "us", "our"]
        let secondPersonWords = ["you", "your", "yours"]
        let thirdPersonWords = ["he", "she", "it", "they", "him", "her", "them", "his", "hers", "its", "theirs"]
        let words = lyrics.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        let firstPersonCount = words.filter { firstPersonWords.contains($0) }.count
        let secondPersonCount = words.filter { secondPersonWords.contains($0) }.count
        let thirdPersonCount = words.filter { thirdPersonWords.contains($0) }.count
        let tenseTags = ["VBD", "VBN", "VBP", "VBZ", "VB", "MD"]
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameTypeOrLexicalClass])
        tagger.string = lyrics
        var pastTense = 0
        var presentTense = 0
        tagger.enumerateTags(in: lyrics.startIndex..<lyrics.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
            let word = String(lyrics[range]).lowercased()
            if word.hasSuffix("ed") {
                pastTense += 1
            } else if word.hasSuffix("ing") || word == "is" || word == "are" {
                presentTense += 1
            }
            return true
        }
        return VStack(alignment: .leading, spacing: 6) {
            Text("Point of View")
                .font(.headline)
                .foregroundColor(.white)
            Text("1st Person: \(firstPersonCount)")
                .foregroundColor(.white.opacity(0.7))
            Text("2nd Person: \(secondPersonCount)")
                .foregroundColor(.white.opacity(0.7))
            Text("3rd Person: \(thirdPersonCount)")
                .foregroundColor(.white.opacity(0.7))
            Text("\nTense")
                .font(.headline)
                .foregroundColor(.white)
            Text("Past Tense indicators: \(pastTense)")
                .foregroundColor(.white.opacity(0.7))
            Text("Present Tense indicators: \(presentTense)")
                .foregroundColor(.white.opacity(0.7))
        }
    }
    private var flowStats: [FlowStat] {
        let lines = lyrics.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return lines.enumerated().map { index, line in
            let syllables = line.lowercased().split(separator: " ").map { syllableCount(for: String($0)) }.reduce(0, +)
            return FlowStat(lineIndex: index, syllables: syllables)
        }
    }
    private func syllableCount(for word: String) -> Int {
        let vowels = "aeiouy"
        let chars = Array(word)
        var count = 0
        var previousWasVowel = false
        for char in chars {
            let isVowel = vowels.contains(char)
            if isVowel && !previousWasVowel {
                count += 1
            }
            previousWasVowel = isVowel
        }
        return max(count, 1)
    }
    private var keywordStats: [KeywordStat] {
        let words = lyrics.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty && !$0.isCommonStopWord() }
        let grouped = Dictionary(grouping: words, by: { $0 }).mapValues { $0.count }
        return grouped.map { KeywordStat(word: $0.key, count: $0.value) }
    }
    private var technicalTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header("Overview", systemImage: "eye")
                overviewPanel
                header("Section Strength", systemImage: "gauge")
                sectionStrengthPanel
            }
            .padding()
        }
    }
    private var emotionTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header("Emotion Timeline", systemImage: "chart.line.uptrend.xyaxis")
                emotionTimelinePanel
            }
            .padding()
        }
    }
    private func header(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.title3.bold())
            .foregroundColor(.white)
            .padding(.top, 12)
    }
    private func insightCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
    private var perspectivePanelShowsMixedPOV: Bool {
        let firstPersonWords = ["i", "me", "my", "mine", "we", "us", "our"]
        let secondPersonWords = ["you", "your", "yours"]
        let thirdPersonWords = ["he", "she", "it", "they", "him", "her", "them", "his", "hers", "its", "theirs"]
        let words = lyrics.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        let firstCount = words.filter { firstPersonWords.contains($0) }.count
        let secondCount = words.filter { secondPersonWords.contains($0) }.count
        let thirdCount = words.filter { thirdPersonWords.contains($0) }.count
        let counts = [firstCount, secondCount, thirdCount].filter { $0 > 0 }
        return counts.count > 1
    }
    private var overviewPanel: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            overviewMetric(title: "Words", value: "\(wordCount)", icon: "textformat")
            overviewMetric(title: "Unique Words", value: "\(uniqueWords.count)", icon: "textformat.abc")
            overviewMetric(title: "Characters", value: "\(lyrics.count)", icon: "character.book.closed")
            overviewMetric(title: "Words/Line", value: String(format: "%.1f", avgWordsPerLine), icon: "line.3.horizontal")
            overviewMetric(title: "Rhyme %", value: String(format: "%.0f%%", rhymeDensity * 100), icon: "waveform")
            overviewMetric(title: "Emotion", value: detectedEmotion, icon: "face.smiling")
        }
        .padding()
    }
    private func overviewMetric(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    private func tip(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
    private var emotionTimelinePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This chart shows how your song's emotional tone evolves line by line.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            Chart {
                ForEach(emotionTimelineData) { point in
                    LineMark(
                        x: .value("Line", point.index),
                        y: .value("Emotion", point.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(by: .value("Tone", point.score > 0.3 ? "Positive" : point.score < -0.3 ? "Negative" : "Neutral"))
                    .symbol(Circle())
                }
            }
            .chartForegroundStyleScale([
                "Positive": Color.green,
                "Neutral": Color.gray,
                "Negative": Color.red
            ])
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxisLabel("Line #")
            .frame(height: 200)
            .chartPlotStyle {
                $0
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }
            if let line = selectedEmotionLine {
                Text("“\(line)”")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 6)
                    .transition(.opacity)
            }
            Text("Mood Strip")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 4)
            HStack(spacing: 1) {
                ForEach(emotionTimelineData) { point in
                    Rectangle()
                        .fill(moodColor(for: point.score))
                        .frame(height: 6)
                }
            }
            .cornerRadius(3)
            Divider().background(Color.white.opacity(0.2)).padding(.top, 4)
            if let max = mostPositiveLine {
                Text("📈 Most Positive Line (Line \(max.index + 1)): “\(max.line)”")
                    .font(.caption)
                    .foregroundColor(.green.opacity(0.8))
            }
            if let min = mostNegativeLine {
                Text("📉 Most Negative Line (Line \(min.index + 1)): “\(min.line)”")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.8))
            }
            if let delta = sharpestShift {
                Text("⚡ Sharpest Emotional Shift: Line \(delta.from.index + 1) → \(delta.to.index + 1)")
                    .font(.caption)
                    .foregroundColor(.yellow.opacity(0.8))
            }
        }
    }
    private func moodColor(for score: Double) -> Color {
        if score > 0.3 {
            return .green
        } else if score < -0.3 {
            return .red
        } else {
            return .gray
        }
    }
    private var mostPositiveLine: EmotionPoint? {
        emotionTimelineData.max(by: { $0.score < $1.score })
    }
    private var mostNegativeLine: EmotionPoint? {
        emotionTimelineData.min(by: { $0.score < $1.score })
    }
    private var sharpestShift: (from: EmotionPoint, to: EmotionPoint)? {
        guard emotionTimelineData.count > 1 else { return nil }
        let shifts = zip(emotionTimelineData, emotionTimelineData.dropFirst())
        return shifts.max(by: { abs($0.1.score - $0.0.score) < abs($1.1.score - $1.0.score) })
    }
    private var wordCount: Int {
        lyrics.split { $0.isWhitespace || $0.isNewline }.count
    }
    private var uniqueWords: Set<String> {
        lyrics.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty && !$0.isCommonStopWord() }
            .reduce(into: Set<String>()) { $0.insert($1) }
    }
    private var avgWordsPerLine: Double {
        let lines = lyrics.components(separatedBy: .newlines)
        let totalWords = lines.map { $0.split(separator: " ").count }.reduce(0, +)
        return lines.isEmpty ? 0 : Double(totalWords) / Double(lines.count)
    }
    private var rhymeDensity: Double {
        let lines = lyrics.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let endings = lines.map { line in
            line.components(separatedBy: .whitespaces).last?.lowercased().trimmingCharacters(in: .punctuationCharacters) ?? ""
        }
        var rhymePairs = 0
        for i in 0..<endings.count {
            for j in (i + 1)..<endings.count {
                if endings[i].hasSuffix(endings[j].suffix(3)) && endings[i] != "" && endings[j] != "" {
                    rhymePairs += 1
                }
            }
        }
        let totalPairs = Double(endings.count * (endings.count - 1)) / 2.0
        return totalPairs == 0 ? 0 : Double(rhymePairs) / totalPairs
    }
    private var detectedEmotion: String {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = lyrics
        let (sentiment, _) = tagger.tag(at: lyrics.startIndex, unit: .paragraph, scheme: .sentimentScore)
        guard let scoreStr = sentiment?.rawValue, let score = Double(scoreStr) else { return "Neutral" }
        switch score {
        case let x where x > 0.3: return "Positive"
        case let x where x < -0.3: return "Negative"
        default: return "Neutral"
        }
    }
    private var emotionTimelineData: [EmotionPoint] {
        let lines = lyrics.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        return lines.enumerated().map { (index, line) in
            tagger.string = line
            let (sentiment, _) = tagger.tag(at: line.startIndex, unit: .paragraph, scheme: .sentimentScore)
            let score = Double(sentiment?.rawValue ?? "0") ?? 0
            return EmotionPoint(index: index, score: score, line: line)
        }
    }
    private var repeatedLines: [String: Int] {
        let lines = lyrics.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
        return Dictionary(grouping: lines, by: { $0 }).mapValues { $0.count }
    }
    private var rhymeClusters: [String: [String]] {
        var clusters = [String: [String]]()
        let lines = lyrics
            .components(separatedBy: .newlines)
            .filter {
                let trimmed = $0.trimmingCharacters(in: .whitespaces)
                return !trimmed.isEmpty && !(trimmed.hasPrefix("[") && trimmed.hasSuffix("]"))
            }
        for line in lines {
            let words = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard let lastWord = words.last?.lowercased().trimmingCharacters(in: .punctuationCharacters) else { continue }
            let suffix = String(lastWord.suffix(3))
            clusters[suffix, default: []].append(line)
        }
        return clusters.filter { $0.value.count > 1 }
    }
    private var sectionStats: [(name: String, content: String, words: Int, unique: Int, rhyme: Double, emotion: String)] {
        let lines = lyrics.components(separatedBy: .newlines)
        var sections = [(String, [String])]()
        var current = "[Unlabeled]"
        var buffer = [String]()
        for line in lines {
            if line.hasPrefix("[") && line.hasSuffix("]") {
                if !buffer.isEmpty {
                    sections.append((current, buffer))
                    buffer = []
                }
                current = line
            } else {
                buffer.append(line)
            }
        }
        if !buffer.isEmpty {
            sections.append((current, buffer))
        }
        return sections.map { (tag, lines) in
            let combined = lines.joined(separator: "\n")
            let wordCount = combined.split { $0.isWhitespace || $0.isNewline }.count
            let unique = Set(combined.lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty && !$0.isCommonStopWord() }).count
            let rhyme = rhymeDensity
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = combined
            let (sentiment, _) = tagger.tag(at: combined.startIndex, unit: .paragraph, scheme: .sentimentScore)
            let score = Double(sentiment?.rawValue ?? "0") ?? 0
            let emotion = score > 0.3 ? "Positive" : (score < -0.3 ? "Negative" : "Neutral")
            return (tag, combined, wordCount, unique, rhyme, emotion)
        }
    }
    private var deduplicatedSectionStats: [(name: String, words: Int, unique: Int, rhyme: Double, emotion: String, count: Int)] {
        var seen = [String: (name: String, words: Int, unique: Int, rhyme: Double, emotion: String, count: Int)]()
        for stat in sectionStats {
            let key = "\(stat.name.trimmingCharacters(in: CharacterSet(charactersIn: "[]")))|\(stat.content.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())"
            if var entry = seen[key] {
                entry.count += 1
                seen[key] = entry
            } else {
                seen[key] = (stat.name, stat.words, stat.unique, stat.rhyme, stat.emotion, 1)
            }
        }
        return Array(seen.values)
    }
}
extension String {
    func isCommonStopWord() -> Bool {
        let stopWords = ["the", "is", "and", "or", "but", "a", "an", "of", "in", "to", "on", "for", "with", "as", "at", "by", "from"]
        return stopWords.contains(self)
    }
}
