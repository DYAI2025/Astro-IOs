// ElevenLabsService.swift
// Bazodiac iOS — ElevenLabs Conversational AI WebSocket Client
//
// Verbindet sich per WebSocket mit ElevenLabs Convai Agents.
// Unterstützt Text-Input → Text-Response (Phase 1, kein Audio).
// Audio-Support (Phase 2) über AVFoundation geplant.
//
// Protokoll: wss://api.elevenlabs.io/v1/convai/conversation?agent_id=...
// Docs: https://elevenlabs.io/docs/conversational-ai/api-reference

import Foundation

// MARK: - Agent Definitionen

enum ConvaiAgent {
    case levi
    case eve

    var agentId: String {
        switch self {
        case .levi: return AppConfig.elevenLabsLeviAgentID
        case .eve:  return AppConfig.elevenLabsEveAgentID
        }
    }

    var displayName: String {
        switch self {
        case .levi: return "Levi Bazi"
        case .eve:  return "Eve"
        }
    }
}

// MARK: - Conversation Events (WebSocket Messages)

/// Vom Client → Server
struct ConvaiClientInit: Encodable {
    let type = "conversation_initiation_client_data"
    let conversation_config_override: ConvaiConfigOverride?
    let custom_llm_extra_body: [String: String]?
}

struct ConvaiConfigOverride: Encodable {
    let agent: ConvaiAgentOverride?
}

struct ConvaiAgentOverride: Encodable {
    let prompt: ConvaiPromptOverride?
    let first_message: String?
}

struct ConvaiPromptOverride: Encodable {
    let prompt: String
}

struct ConvaiUserText: Encodable {
    let text: String
    let type = "user_message"
}

/// Vom Server → Client
struct ConvaiServerMessage: Decodable {
    let type: String?                       // "conversation_initiation_metadata", "agent_response", "user_transcript", "interruption", "ping", "internal_tentative_agent_response"
    // agent_response fields
    let agent_response_type: String?        // "text" oder "audio"
    let text: String?                       // Textantwort
    let audio: ConvaiAudio?                 // Base64 Audio
    // user_transcript fields
    let user_transcription_event: ConvaiTranscript?
    // metadata
    let conversation_id: String?
}

struct ConvaiAudio: Decodable {
    let chunk: String?      // Base64 encoded audio
    let format: String?     // "pcm_16000" etc.
}

struct ConvaiTranscript: Decodable {
    let user_transcript: String?
    let is_final: Bool?
}

// MARK: - Delegate Protocol

@MainActor
protocol ElevenLabsDelegate: AnyObject {
    func didReceiveText(_ text: String)
    func didReceivePartialText(_ text: String)
    func didConnect(conversationId: String)
    func didDisconnect()
    func didEncounterError(_ error: String)
}

// MARK: - ElevenLabs Service

@MainActor
final class ElevenLabsService: NSObject {

    static let shared = ElevenLabsService()

    weak var delegate: ElevenLabsDelegate?

    private var webSocket: URLSessionWebSocketTask?
    private var session: URLSession?
    private(set) var isConnected = false
    private(set) var conversationId: String?

    private var pendingTextBuffer = ""

    private override init() {
        super.init()
    }

    // MARK: - Connect

    /// Startet eine WebSocket-Konversation mit einem Agent
    func connect(agent: ConvaiAgent, userContext: String? = nil) {
        disconnect() // Altes cleanup

        let urlString = "wss://api.elevenlabs.io/v1/convai/conversation?agent_id=\(agent.agentId)"
        guard let url = URL(string: urlString) else {
            delegate?.didEncounterError("Ungültige WebSocket-URL")
            return
        }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        webSocket = session?.webSocketTask(with: url)
        webSocket?.resume()

        // Initial-Nachricht mit Kontext senden
        let initMsg = ConvaiClientInit(
            conversation_config_override: userContext.map { ctx in
                ConvaiConfigOverride(
                    agent: ConvaiAgentOverride(
                        prompt: ConvaiPromptOverride(prompt: ctx),
                        first_message: nil
                    )
                )
            },
            custom_llm_extra_body: nil
        )

        sendJSON(initMsg)
        startReceiving()
    }

    // MARK: - Send Text Message

    /// Sendet eine Text-Nachricht an den Agent (kein Audio nötig)
    func sendText(_ text: String) {
        guard isConnected else {
            delegate?.didEncounterError("Nicht verbunden")
            return
        }
        let msg = ConvaiUserText(text: text)
        sendJSON(msg)
    }

    /// Sendet einen Base64-encoded Audio-Chunk an den Agent
    func sendAudioChunk(_ base64Audio: String) {
        guard isConnected else { return }
        let payload = "{\"user_audio_chunk\":\"\(base64Audio)\"}"
        webSocket?.send(.string(payload)) { _ in }
    }

    // MARK: - Disconnect

    func disconnect() {
        webSocket?.cancel(with: .normalClosure, reason: nil)
        webSocket = nil
        session?.invalidateAndCancel()
        session = nil
        isConnected = false
        conversationId = nil
        pendingTextBuffer = ""
    }

    // MARK: - Private: Send JSON

    private func sendJSON<T: Encodable>(_ value: T) {
        guard let data = try? JSONEncoder().encode(value),
              let string = String(data: data, encoding: .utf8) else { return }
        webSocket?.send(.string(string)) { [weak self] error in
            if let error {
                Task { @MainActor in
                    self?.delegate?.didEncounterError("Send failed: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Private: Receive Loop

    private func startReceiving() {
        webSocket?.receive { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .success(let message):
                    switch message {
                    case .string(let text):
                        self.handleMessage(text)
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8) {
                            self.handleMessage(text)
                        }
                    @unknown default:
                        break
                    }
                    // Weiter empfangen
                    self.startReceiving()

                case .failure(let error):
                    self.isConnected = false
                    self.delegate?.didDisconnect()
                    if (error as NSError).code != 57 { // nicht "Socket is not connected"
                        self.delegate?.didEncounterError(error.localizedDescription)
                    }
                }
            }
        }
    }

    // MARK: - Private: Parse Server Message

    private func handleMessage(_ raw: String) {
        guard let data = raw.data(using: .utf8) else { return }

        // Ping einfach ignorieren
        if raw.contains("\"ping\"") {
            // Pong zurücksenden
            webSocket?.send(.string("{\"type\":\"pong\"}")) { _ in }
            return
        }

        guard let msg = try? JSONDecoder().decode(ConvaiServerMessage.self, from: data) else {
            return
        }

        switch msg.type {
        case "conversation_initiation_metadata":
            isConnected = true
            conversationId = msg.conversation_id
            delegate?.didConnect(conversationId: msg.conversation_id ?? "")

        case "agent_response":
            if let text = msg.text, !text.isEmpty {
                if msg.agent_response_type == "text" {
                    // Text-Chunk — akkumulieren
                    pendingTextBuffer += text
                }
            }

        case "internal_tentative_agent_response":
            // Partial/streaming response
            if let text = msg.text {
                delegate?.didReceivePartialText(text)
            }

        case "agent_response_end", "turn_end":
            // Agent hat fertig gesprochen → Buffer flushen
            if !pendingTextBuffer.isEmpty {
                delegate?.didReceiveText(pendingTextBuffer)
                pendingTextBuffer = ""
            }

        case "user_transcript":
            // User-Transkription (wenn Audio-Mode aktiv)
            break

        case "interruption":
            // User hat unterbrochen
            pendingTextBuffer = ""

        default:
            // Unbekannter Typ — bei "audio" etc. ignorieren
            // Wenn es ein finaler Text-Block ist, trotzdem flushen
            if !pendingTextBuffer.isEmpty, msg.type == nil || msg.type == "" {
                delegate?.didReceiveText(pendingTextBuffer)
                pendingTextBuffer = ""
            }
        }
    }

    // MARK: - Context Builder

    /// Baut den User-Kontext für den Agent aus dem CosmicProfile
    static func buildContext(from profile: CosmicProfile?, language: CosmicStore.Language) -> String {
        guard let p = profile else {
            return language == .german
                ? "Der Nutzer hat noch kein astrologisches Profil erstellt."
                : "The user hasn't created their astrological profile yet."
        }

        let w = p.westernData
        let b = p.baziData
        let wu = p.wuxingData

        return """
        Nutzer-Profil:
        Name: \(p.birthData.name)
        Geburtsort: \(p.birthData.birthPlace)
        
        Western Astrologie:
        - Sonne: \(w.sunSign.germanName) (\(String(format: "%.1f°", w.sunDegree)))
        - Mond: \(w.moonSign.germanName) (\(String(format: "%.1f°", w.moonDegree)))
        - Aszendent: \(w.ascendant.germanName) (\(String(format: "%.1f°", w.ascendantDegree)))
        
        BaZi Vier Säulen:
        - Tag-Meister: \(b.day.stem.char) (\(b.day.stem.english))
        - Jahr: \(b.year.stem.char)\(b.year.branch.char) (\(b.year.branch.animal))
        - Monat: \(b.month.stem.char)\(b.month.branch.char)
        - Tag: \(b.day.stem.char)\(b.day.branch.char)
        - Stunde: \(b.hour.stem.char)\(b.hour.branch.char)
        
        Wu-Xing Dominantes Element: \(wu.dominant.germanName)
        Wu-Xing Schwächstes Element: \(wu.weakest.germanName)
        
        Sprache: \(language == .german ? "Deutsch" : "English")
        """
    }
}

// MARK: - URLSessionWebSocketDelegate

extension ElevenLabsService: URLSessionWebSocketDelegate {
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        // WebSocket geöffnet — Init-Nachricht wurde bereits in connect() gesendet
    }

    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Task { @MainActor in
            self.isConnected = false
            self.delegate?.didDisconnect()
        }
    }
}
