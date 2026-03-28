// VoiceRecordingService.swift
// Bazodiac iOS — Mikrofon-Aufnahme + Audio → ElevenLabs WebSocket
//
// TASK-avfoundation-mic + TASK-voice-to-websocket
//
// Nimmt Audio auf via AVAudioRecorder (16kHz PCM),
// konvertiert zu Base64 chunks und sendet an ElevenLabs Convai WebSocket.

import AVFoundation
import Foundation

@MainActor
@Observable
final class VoiceRecordingService: NSObject {

    var isRecording = false
    var permissionGranted = false
    var errorMessage: String?

    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var chunkTimer: Timer?

    // Callback: Sendet Base64-encoded Audio-Chunk an den WebSocket
    var onAudioChunk: ((String) -> Void)?

    override init() {
        super.init()
        checkPermission()
    }

    // MARK: - Permission

    func checkPermission() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            permissionGranted = true
        case .denied:
            permissionGranted = false
            errorMessage = "Mikrofon-Zugriff verweigert. Bitte in Einstellungen aktivieren."
        case .undetermined:
            // Will be requested on first record attempt
            permissionGranted = false
        @unknown default:
            permissionGranted = false
        }
    }

    func requestPermission() async -> Bool {
        let granted = await AVAudioApplication.requestRecordPermission()
        permissionGranted = granted
        if !granted {
            errorMessage = "Mikrofon-Zugriff wird benötigt für Sprachgespräche mit Levi und Eve."
        }
        return granted
    }

    // MARK: - Start Recording

    func startRecording() async {
        errorMessage = nil

        if !permissionGranted {
            let granted = await requestPermission()
            guard granted else { return }
        }

        // Configure audio session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            errorMessage = "Audio-Session konnte nicht gestartet werden."
            return
        }

        // Recording file (temp)
        let tempDir = FileManager.default.temporaryDirectory
        recordingURL = tempDir.appendingPathComponent("bazodiac_voice_\(UUID().uuidString).wav")

        // Settings: 16kHz mono PCM (ElevenLabs expects pcm_16000)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true

            // Stream chunks every 250ms
            startChunkStreaming()
        } catch {
            errorMessage = "Aufnahme fehlgeschlagen: \(error.localizedDescription)"
        }
    }

    // MARK: - Stop Recording

    func stopRecording() {
        chunkTimer?.invalidate()
        chunkTimer = nil
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false

        // Send final chunk
        if let url = recordingURL {
            sendAudioChunk(from: url)
            // Cleanup
            try? FileManager.default.removeItem(at: url)
            recordingURL = nil
        }
    }

    // MARK: - Chunk Streaming

    private func startChunkStreaming() {
        // ElevenLabs expects continuous audio chunks during recording
        // We send the accumulated audio every 250ms
        chunkTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let url = self.recordingURL else { return }
                self.sendAudioChunk(from: url)
            }
        }
    }

    private func sendAudioChunk(from url: URL) {
        guard let data = try? Data(contentsOf: url), !data.isEmpty else { return }

        // Skip WAV header (44 bytes) for raw PCM
        let pcmData = data.count > 44 ? data.subdata(in: 44..<data.count) : data
        guard !pcmData.isEmpty else { return }

        let base64 = pcmData.base64EncodedString()
        onAudioChunk?(base64)
    }
}

// MARK: - AVAudioRecorderDelegate

extension VoiceRecordingService: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            isRecording = false
            if !flag {
                errorMessage = "Aufnahme wurde unterbrochen."
            }
        }
    }

    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor in
            isRecording = false
            errorMessage = "Aufnahmefehler: \(error?.localizedDescription ?? "Unbekannt")"
        }
    }
}
