//  AudioRecorderView.swift
//  Hookline
//  Created by Pulkit Jain on 2/5/2025.
import SwiftUI
import AVFoundation
import AVKit
struct AudioRecorderView: View {
    @ObservedObject var viewModel = AudioRecorderViewModel()
    var section: String?
    @State private var audioPlayer: AVPlayer?
    @State private var pulse = false
    @State private var waveformCache: [URL: [Float]] = [:]
    @State private var isPlaying: Bool = false
    @State private var playbackProgress: Double = 0.0
    @State private var totalDuration: Double = 0.0
    @State private var playbackTimer: Timer?
    @State private var currentlyPlayingURL: URL?
    @State private var editingClipID: UUID?
    @FocusState private var titleFieldFocused: Bool
    @FocusState private var focusedClipID: UUID?
    var body: some View {
        let background = LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#10002B"),
                Color(hex: "#240046"),
                Color(hex: "#3C096C")
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return ZStack {
            background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Text("Audio Recorder")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top)
                
                Button(action: {
                    if viewModel.isRecording {
                        viewModel.stopRecording(section: section)
                    } else {
                        viewModel.startRecording(section: section)
                    }
                }) {
                    Label(viewModel.isRecording ? "Stop Recording" : "Start Recording",
                          systemImage: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(viewModel.isRecording ? Color.red : Color.blue)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                if viewModel.isRecording {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "waveform")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .scaleEffect(pulse ? 1.1 : 0.9)
                                .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: pulse)
                                .onAppear { pulse = true }
                                .onDisappear { pulse = false }
                            GeometryReader { geo in
                                let barHeight = CGFloat(viewModel.currentVolumeLevel) * geo.size.height
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(height: max(barHeight, 4)) // ensure minimum visibility
                                        .cornerRadius(2)
                                }
                            }
                            .frame(width: 12, height: 40)
                        }
                        Text(formatTime(viewModel.recordingDuration))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                if viewModel.recordings.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "waveform")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.3))
                        Text("No recordings yet")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.6))
                        Text("Record your ideas and organize them by section.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.groupedRecordings.keys.sorted(by: { $0 == "Unassigned" ? true : $1 != "Unassigned" }), id: \.self) { tag in
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(tag)
                                        .font(.caption.bold())
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding(.vertical, 6)
                                        .padding(.horizontal)
                                    
                                    ForEach(viewModel.groupedRecordings[tag] ?? []) { clip in
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                if editingClipID == clip.id {
                                                    TextField("", text: Binding(
                                                        get: { clip.title },
                                                        set: { newValue in clip.title = newValue }
                                                    ), onCommit: {
                                                        viewModel.renameClip(clip, to: clip.title)
                                                        editingClipID = nil
                                                    })
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                    .foregroundColor(.white)
                                                    .font(.subheadline)
                                                    .submitLabel(.done)
                                                    .onAppear {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                            editingClipID = clip.id // trigger animation smoothly
                                                        }
                                                    }
                                                } else {
                                                    Text(clip.title)
                                                        .font(.subheadline)
                                                        .foregroundColor(.white)
                                                        .lineLimit(1)
                                                        .onTapGesture {
                                                            editingClipID = clip.id
                                                        }
                                                }
                                                Spacer()
                                                Button(action: {
                                                    viewModel.deleteRecording(clip)
                                                }) {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(.red)
                                                }
                                            }
                                            .padding(.horizontal)
                                            
                                            if let samples = waveformCache[clip.fileURL] {
                                                WaveformView(
                                                    samples: samples,
                                                    playheadProgress: (currentlyPlayingURL == clip.fileURL && totalDuration > 0)
                                                    ? Double(samples.count) * playbackProgress / totalDuration
                                                    : nil
                                                )
                                                .frame(height: 32)
                                                .padding(.horizontal)
                                            } else {
                                                Text("Loading waveform...")
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                                    .padding(.horizontal)
                                                    .onAppear {
                                                        DispatchQueue.global(qos: .userInitiated).async {
                                                            let samples = WaveformExtractor.loadSamples(from: clip.fileURL)
                                                            DispatchQueue.main.async {
                                                                waveformCache[clip.fileURL] = samples
                                                            }
                                                        }
                                                    }
                                            }
                                            
                                            HStack {
                                                Button(action: {
                                                    if isPlaying && currentlyPlayingURL == clip.fileURL {
                                                        audioPlayer?.pause()
                                                        isPlaying = false
                                                    } else {
                                                        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                                                        try? AVAudioSession.sharedInstance().setActive(true)
                                                        
                                                        let playerItem = AVPlayerItem(url: clip.fileURL)
                                                        audioPlayer = AVPlayer(playerItem: playerItem)
                                                        currentlyPlayingURL = clip.fileURL
                                                        audioPlayer?.play()
                                                        isPlaying = true
                                                        
                                                        totalDuration = CMTimeGetSeconds(playerItem.asset.duration)
                                                        
                                                        playbackTimer?.invalidate()
                                                        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                                                            if let currentTime = audioPlayer?.currentTime() {
                                                                playbackProgress = CMTimeGetSeconds(currentTime)
                                                                if playbackProgress >= totalDuration {
                                                                    isPlaying = false
                                                                    playbackTimer?.invalidate()
                                                                }
                                                            }
                                                        }
                                                    }
                                                }) {
                                                    Image(systemName: (isPlaying && currentlyPlayingURL == clip.fileURL) ? "pause.circle.fill" : "play.circle.fill")
                                                        .foregroundColor(.green)
                                                        .font(.title2)
                                                }
                                                
                                                Spacer()
                                                
                                                Text("\(formatTime(playbackProgress)) / \(formatTime(totalDuration))")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.6))
                                                
                                                Spacer()
                                                
                                                Menu {
                                                    ForEach(viewModel.sectionTags, id: \.self) { tag in
                                                        Button(tag) {
                                                            viewModel.updateSection(for: clip, to: tag)
                                                        }
                                                    }
                                                } label: {
                                                    HStack {
                                                        Text(clip.sectionTag ?? "Unassigned")
                                                            .font(.caption)
                                                            .foregroundColor(.white)
                                                        Image(systemName: "chevron.down")
                                                            .foregroundColor(.white.opacity(0.7))
                                                    }
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.white.opacity(0.08))
                                                    .cornerRadius(6)
                                                }
                                            }
                                            .padding(.horizontal)
                                            .padding(.bottom, 8)
                                            
                                            Divider()
                                                .background(Color.white.opacity(0.1))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

class AudioRecorderViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var recordings: [AudioClip] = []
    @Published var groupedRecordings: [String: [AudioClip]] = [:]
    @Published var sectionTags: [String] = ["Verse", "Chorus", "Bridge", "Intro", "Outro", "Hook", "Pre-Chorus", "Post-Chorus", "Unassigned"]
    @Published var currentVolumeLevel: Float = 0.0
    @Published var liveSamples: [Float] = []
    @Published var recordingDuration: TimeInterval = 0.0

    private var meteringTimer: Timer?
    private var audioRecorder: AVAudioRecorder?
    private let recordingsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Recordings")
    
    override init() {
        super.init()
        loadRecordings()
    }
    func updateTitle(for clip: AudioClip, to newTitle: String) {
        let newFilename = "Clip_\(clip.sectionTag ?? "Unassigned")_\(clip.createdAt.timeIntervalSince1970).m4a"
        let newURL = recordingsDirectory.appendingPathComponent(newFilename)
        do {
            try FileManager.default.moveItem(at: clip.fileURL, to: newURL)
            var updatedClip = clip
            updatedClip.title = newTitle
            loadRecordings()
        } catch {
            print("Failed to rename clip: \(error)")
        }
    }
    func renameClip(_ clip: AudioClip, to newTitle: String) {
        let safeTitle = newTitle.replacingOccurrences(of: " ", with: "_")
        let newFilename = "Clip_\(clip.sectionTag ?? "Unassigned")_\(clip.createdAt.timeIntervalSince1970)_\(safeTitle).m4a"
        let newURL = recordingsDirectory.appendingPathComponent(newFilename)
        
        do {
            try FileManager.default.moveItem(at: clip.fileURL, to: newURL)
            loadRecordings()
        } catch {
            print("Failed to rename clip: \(error)")
        }
    }
    func startRecording(section: String?) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard granted else { return }
            DispatchQueue.main.async {
                self?.record(section: section)
            }
        }
    }
    private func record(section: String?) {
        try? FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)
        let timestamp = Date().timeIntervalSince1970
        let tag = section ?? "Unassigned"
        let sectionPrefix = section ?? "Clip"
        let existingTitles = recordings.map { $0.title }
        let matchingTitles = existingTitles.filter { $0.hasPrefix(sectionPrefix) }
        let numbers = matchingTitles.compactMap {
            Int($0.replacingOccurrences(of: "\(sectionPrefix) ", with: ""))
        }
        let nextIndex = (numbers.max() ?? 0) + 1
        let defaultTitle = "\(sectionPrefix) \(nextIndex)"
        let filename = "Clip_\(tag)_\(timestamp).m4a"
        let url = recordingsDirectory.appendingPathComponent(filename)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            meteringTimer?.invalidate()
            recordingDuration = 0
            liveSamples = []
            meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder else { return }
                recorder.updateMeters()
                let level = recorder.averagePower(forChannel: 0)
                let normalized = pow(10, level / 20) // convert dB to linear 0–1
                self.liveSamples.append(Float(normalized))
                if self.liveSamples.count > 100 {
                    self.liveSamples.removeFirst()
                }
                self.currentVolumeLevel = Float(normalized)
                self.recordingDuration += 0.05
            }
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    func stopRecording(section: String?) {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        meteringTimer?.invalidate()
        liveSamples = []
        recordingDuration = 0
        let sectionPrefix = section ?? "Clip"
        let existingTitles = recordings.map { $0.title }
        let matchingTitles = existingTitles.filter {
            $0.hasPrefix(sectionPrefix + " ") && Int($0.replacingOccurrences(of: "\(sectionPrefix) ", with: "")) != nil
        }
        let numbers = matchingTitles.compactMap {
            Int($0.replacingOccurrences(of: "\(sectionPrefix) ", with: ""))
        }
        let nextIndex = (numbers.max() ?? 0) + 1
        let defaultTitle = "\(sectionPrefix) \(nextIndex)"
        let urls = (try? FileManager.default.contentsOfDirectory(at: recordingsDirectory, includingPropertiesForKeys: [.creationDateKey])) ?? []
        let recentURL = urls.max(by: {
            let date1 = (try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            let date2 = (try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
            return date1 < date2
        })
        if let oldURL = recentURL {
            let newFilename = "Clip_\(sectionPrefix)_\(Date().timeIntervalSince1970)_\(defaultTitle.replacingOccurrences(of: " ", with: "_")).m4a"
            let newURL = recordingsDirectory.appendingPathComponent(newFilename)
            do {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                let clip = AudioClip(
                    id: UUID(),
                    fileURL: newURL,
                    title: defaultTitle,
                    sectionTag: section,
                    createdAt: Date()
                )
                withAnimation {
                    recordings.insert(clip, at: 0)
                    groupedRecordings = Dictionary(grouping: recordings, by: { $0.sectionTag ?? "Unassigned" })
                }
            } catch {
                print("Failed to rename recorded clip: \(error)")
            }
        }
    }
    func loadRecordings() {
        let urls = (try? FileManager.default.contentsOfDirectory(at: recordingsDirectory, includingPropertiesForKeys: nil)) ?? []
        var result: [AudioClip] = []
        for url in urls {
            let filename = url.lastPathComponent.replacingOccurrences(of: ".m4a", with: "")
            let parts = filename.components(separatedBy: "_")
            let tag = parts.count >= 2 ? parts[1] : "Unassigned"
            let title: String
            if parts.count >= 4 {
                title = parts[3...].joined(separator: "_").replacingOccurrences(of: "_", with: " ")
            } else {
                let sectionPrefix = tag
                let existingTitles = result.map { $0.title }
                let matchingTitles = existingTitles.filter { $0.hasPrefix(sectionPrefix + " ") }
                let numbers = matchingTitles.compactMap {
                    Int($0.replacingOccurrences(of: "\(sectionPrefix) ", with: ""))
                }
                let nextIndex = (numbers.max() ?? 0) + 1
                title = "\(sectionPrefix) \(nextIndex)"
            }
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
            let creationDate = attributes?[.creationDate] as? Date ?? Date()
            let clip = AudioClip(id: UUID(), fileURL: url, title: title, sectionTag: tag, createdAt: creationDate)
            result.append(clip)
        }
        recordings = result.sorted(by: { $0.createdAt > $1.createdAt })
        let grouped = Dictionary(grouping: recordings, by: { $0.sectionTag ?? "Unassigned" })
        groupedRecordings = grouped.mapValues { $0.sorted(by: { $0.createdAt > $1.createdAt }) }
    }
    func updateSection(for clip: AudioClip, to newTag: String) {
        let oldTag = clip.sectionTag ?? "Clip"
        let titleIsAutoGenerated = clip.title == "\(oldTag) 1" || clip.title.hasPrefix("\(oldTag) ")
        let newTitle: String
        if titleIsAutoGenerated {
            let matching = recordings.filter { $0.sectionTag == newTag && $0.title.hasPrefix(newTag + " ") }
            let existingNumbers = matching.compactMap {
                Int($0.title.replacingOccurrences(of: "\(newTag) ", with: ""))
            }
            let nextIndex = (existingNumbers.max() ?? 0) + 1
            newTitle = "\(newTag) \(nextIndex)"
        } else {
            newTitle = clip.title
        }
        let safeTitle = newTitle.replacingOccurrences(of: " ", with: "_")
        let newFilename = "Clip_\(newTag)_\(clip.createdAt.timeIntervalSince1970)_\(safeTitle).m4a"
        let newURL = recordingsDirectory.appendingPathComponent(newFilename)
        do {
            try FileManager.default.moveItem(at: clip.fileURL, to: newURL)
            loadRecordings()
        } catch {
            print("Failed to reassign clip: \(error)")
        }
    }
    func deleteRecording(_ clip: AudioClip) {
        do {
            try FileManager.default.removeItem(at: clip.fileURL)
            loadRecordings()
        } catch {
            print("Failed to delete: \(error)")
        }
    }
}
class AudioClip: Identifiable, ObservableObject {
    let id: UUID
    var fileURL: URL
    @Published var title: String
    var sectionTag: String?
    var createdAt: Date
    init(id: UUID, fileURL: URL, title: String, sectionTag: String?, createdAt: Date) {
        self.id = id
        self.fileURL = fileURL
        self.title = title
        self.sectionTag = sectionTag
        self.createdAt = createdAt
    }
}
struct WaveformView: View {
    var samples: [Float]
    var color: Color = .blue
    var playheadProgress: Double? = nil
    var body: some View {
        GeometryReader { geometry in
            let width = Int(geometry.size.width)
            let height = geometry.size.height
            let midY = height / 2
            let downsampled = WaveformExtractor.downsample(samples, to: width)
            ZStack(alignment: .leading) {
                Path { path in
                    for x in 0..<downsampled.count {
                        let value = CGFloat(downsampled[x]) * midY
                        path.move(to: CGPoint(x: CGFloat(x), y: midY - value))
                        path.addLine(to: CGPoint(x: CGFloat(x), y: midY + value))
                    }
                }
                .stroke(color, lineWidth: 1)
                if let progress = playheadProgress {
                    let index = min(Int(progress), samples.count - 1)
                    let x = (CGFloat(index) / CGFloat(samples.count)) * CGFloat(width)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2)
                        .position(x: x, y: midY)
                }
            }
        }
        .frame(height: 30)
        .cornerRadius(4)
    }
}
class WaveformExtractor {
    static func loadSamples(from url: URL) -> [Float] {
        let asset = AVAsset(url: url)
        guard let track = asset.tracks(withMediaType: .audio).first else { return [] }
        let readerSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        do {
            let reader = try AVAssetReader(asset: asset)
            let output = AVAssetReaderTrackOutput(track: track, outputSettings: readerSettings)
            reader.add(output)
            reader.startReading()
            var samples: [Float] = []
            while let buffer = output.copyNextSampleBuffer(), let block = CMSampleBufferGetDataBuffer(buffer) {
                let length = CMBlockBufferGetDataLength(block)
                var data = Data(count: length)
                data.withUnsafeMutableBytes { ptr in
                    CMBlockBufferCopyDataBytes(block, atOffset: 0, dataLength: length, destination: ptr.baseAddress!)
                }
                let count = length / MemoryLayout<Int16>.size
                let values = data.withUnsafeBytes { ptr -> [Int16] in
                    let buffer = ptr.bindMemory(to: Int16.self)
                    return Array(buffer)
                }
                let floatSamples = values.map { Float($0) / Float(Int16.max) }
                samples.append(contentsOf: floatSamples)
            }
            return downsample(samples, to: 100)
        } catch {
            print("Waveform loading failed: \(error)")
            return []
        }
    }
    static func downsample(_ samples: [Float], to target: Int) -> [Float] {
        guard samples.count > target else {
            return samples + Array(repeating: 0, count: target - samples.count)
        }
        let sampleCount = samples.count
        let bucketSize = sampleCount / target
        return stride(from: 0, to: sampleCount, by: bucketSize).map { i in
            let end = min(i + bucketSize, sampleCount)
            let slice = samples[i..<end]
            return slice.max() ?? 0
        }
    }
}
