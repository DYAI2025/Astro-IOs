// LeviView.swift
// Bazodiac iOS — Levi Bazi AI Voice Companion
//
// The native iOS counterpart of the web ElevenLabs voice widget.
// Features: animated waveform, conversation history, voice input button,
// session start/stop, and cosmic-themed UI.
// (Voice API integration: replace stub with ElevenLabs SDK or REST)

import SwiftUI
import UIKit

// MARK: - Message Model

private struct Message: Identifiable {
    let id   = UUID()
    let role: Role
    let text: String
    let time: Date = Date()

    enum Role { case user, levi }
}

// MARK: - Levi View

struct LeviView: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    // PH-13 BEHOBEN: Startet leer statt mit vorgeladenem Sample
    // Echte Begrüßung kommt von ElevenLabs (Phase 4)
    @State private var messages: [Message] = []
    @State private var isListening   = false
    @State private var isSpeaking    = false
    @State private var sessionActive = false
    @State private var inputText     = ""
    @State private var appeared      = false
    @State private var leviService   = LeviConversationHandler()
    @Environment(\.dismiss) private var dismiss

    private let scrollID = "bottom"

    var body: some View {
        ZStack {
            // Deep space background — slightly different tint for Levi section
            LinearGradient(
                colors: [
                    Color.obsidian,
                    Color(hex: "#050310"),
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            StarfieldView(starCount: 80, goldTint: false).ignoresSafeArea().opacity(0.3)

            VStack(spacing: 0) {
                // ── Header ─────────────────────────────────────────────────
                leviHeader

                // ── Waveform / Avatar ──────────────────────────────────────
                LeviAvatarSection(isSpeaking: isSpeaking, isListening: isListening)
                    .frame(height: 180)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)

                // ── Conversation scroll ────────────────────────────────────
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .transition(.asymmetric(
                                        insertion: .push(from: .bottom),
                                        removal:   .opacity
                                    ))
                            }
                            Color.clear.frame(height: 1).id(scrollID)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .onChange(of: messages.count) {
                        withAnimation(.spring(duration: 0.4)) {
                            proxy.scrollTo(scrollID, anchor: .bottom)
                        }
                    }
                }

                Spacer(minLength: 0)

                // ── Input / Control bar ────────────────────────────────────
                LeviControlBar(
                    isListening:   $isListening,
                    isSpeaking:    $isSpeaking,
                    sessionActive: $sessionActive,
                    inputText:     $inputText,
                    onSend:        sendMessage
                )
                .padding(.bottom, max(100, 88))
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6).delay(0.3)) { appeared = true }
        }
    }

    // MARK: - Header

    private var leviHeader: some View {
        HStack(spacing: 12) {
            // Zurück-Button
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color.cosmicGold.opacity(0.5))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            // Levi avatar badge
            ZStack {
                Circle()
                    .fill(Color(hex: "#1A0A2E").opacity(0.8))
                    .frame(width: 44, height: 44)
                Circle()
                    .strokeBorder(Color.cosmicGold.opacity(sessionActive ? 0.6 : 0.2), lineWidth: 0.75)
                    .frame(width: 44, height: 44)
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 22, weight: .thin))
                    .foregroundStyle(Color.cosmicGold.opacity(sessionActive ? 0.9 : 0.5))
                    .symbolEffect(.breathe, isActive: sessionActive)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Levi Bazi")
                    .font(CosmicFont.heading(17, weight: .light))
                    .foregroundStyle(theme.textPrimary)
                Text(sessionActive
                     ? (isSpeaking ? "Spricht …" : isListening ? "Hört zu …" : "Verbunden")
                     : "KI-Kosmosbegleiter")
                    .goldLabel(0.45)
                    .animation(.easeInOut(duration: 0.3), value: isSpeaking)
            }

            Spacer()

            // Session toggle
            Button {
                withAnimation(.spring(duration: 0.4)) {
                    sessionActive.toggle()
                    if !sessionActive {
                        isListening = false
                        isSpeaking  = false
                    } else {
                        // Echte ElevenLabs-Verbindung starten
                        leviService.onText = { text in addLeviMessage(text) }
                        leviService.connect(
                            profile: store.profile,
                            language: store.language
                        )
                    }
                }
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            } label: {
                Label(sessionActive ? "Ende" : "Start",
                      systemImage: sessionActive ? "stop.circle.fill" : "play.circle.fill")
                    .font(CosmicFont.label(9))
                    .tracking(2)
                    .foregroundStyle(sessionActive
                        ? Color.elementFire.opacity(0.8)
                        : Color.cosmicGold.opacity(0.7))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .strokeBorder(
                                sessionActive
                                    ? Color.elementFire.opacity(0.35)
                                    : Color.cosmicGold.opacity(0.2),
                                lineWidth: 0.75
                            )
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 12)
    }

    // MARK: - Actions

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        withAnimation(.spring(duration: 0.4)) {
            messages.append(Message(role: .user, text: text))
        }
        inputText = ""

        withAnimation(.spring(duration: 0.3)) { isSpeaking = true }

        if leviService.isConnected {
            // Echte ElevenLabs-Nachricht
            leviService.send(text: text)
        } else {
            // Fallback wenn nicht verbunden
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                addLeviMessage(leviResponse(for: text))
                withAnimation { isSpeaking = false }
            }
        }
    }

    private func addLeviMessage(_ text: String) {
        withAnimation(.spring(duration: 0.4)) {
            messages.append(Message(role: .levi, text: text))
        }
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    private func leviResponse(for input: String) -> String {
        let responses = [
            "Dein Wasserlement spricht in dieser Frage sehr stark. Der natürliche Fluss leitet dich.",
            "Die Spannung zwischen deinem Steinbock-Kern und dem Skorpion-Mond zeigt sich hier deutlich.",
            "Betrachte den aktuellen Transit — Saturn berührt dein Tagessäule-Element.",
            "Dein Day Master 壬 (Yang Wasser) neigt dazu, Wahrheit in der Tiefe zu suchen, nicht an der Oberfläche.",
            "Die Generierungs-Energie von Wasser zu Holz unterstützt gerade dein Wachstum.",
        ]
        return responses.randomElement() ?? responses[0]
    }
}

// MARK: - Levi Avatar Section (Waveform)

private struct LeviAvatarSection: View {
    @Environment(\.cosmicTheme) private var theme
    let isSpeaking:  Bool
    let isListening: Bool

    var body: some View {
        ZStack {
            // Background glow
            RadialGradient(
                colors: [
                    Color(hex: "#3B1F6B").opacity(isSpeaking ? 0.3 : 0.12),
                    .clear,
                ],
                center: .center,
                startRadius: 20,
                endRadius: 90
            )
            .animation(.easeInOut(duration: 0.6), value: isSpeaking)

            if isSpeaking || isListening {
                // Animated waveform bars
                LeviWaveform(isSpeaking: isSpeaking, isListening: isListening)
                    .frame(height: 80)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else {
                // Idle state — subtle orbital rings
                OrbitalRingsView(rings: 2, baseRadius: 28, ringSpacing: 22)
                    .opacity(0.4)
                    .transition(.opacity)
            }

            // Central sigil
            ZStack {
                Circle()
                    .fill(Color(hex: "#0D0518").opacity(0.9))
                    .frame(width: 64, height: 64)
                Circle()
                    .strokeBorder(Color.cosmicGold.opacity(isSpeaking ? 0.7 : 0.25), lineWidth: 0.75)
                    .frame(width: 64, height: 64)
                    .animation(.easeInOut(duration: 0.4), value: isSpeaking)
                Image(systemName: "waveform")
                    .font(.system(size: 24, weight: .ultraLight))
                    .foregroundStyle(Color.cosmicGold.opacity(isSpeaking ? 0.9 : 0.4))
                    .symbolEffect(.breathe, isActive: isSpeaking)
            }
        }
        .animation(.spring(duration: 0.5), value: isSpeaking)
        .animation(.spring(duration: 0.5), value: isListening)
    }
}

private struct LeviWaveform: View {
    @Environment(\.cosmicTheme) private var theme
    let isSpeaking:  Bool
    let isListening: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t     = timeline.date.timeIntervalSinceReferenceDate
                let bars  = 28
                let barW  = size.width / CGFloat(bars * 2 - 1)
                let cx    = size.width / 2

                for i in 0..<bars {
                    let x = cx + CGFloat(i - bars / 2) * barW * 2
                    let phase = Double(i) * 0.5
                    let baseH: CGFloat = size.height * 0.15

                    let h: CGFloat
                    if isSpeaking {
                        h = baseH + size.height * 0.6 * CGFloat(abs(sin(t * 2.2 + phase)))
                    } else if isListening {
                        h = baseH + size.height * 0.35 * CGFloat(abs(sin(t * 1.3 + phase)))
                    } else {
                        h = baseH
                    }

                    let y   = (size.height - h) / 2
                    let rect = CGRect(x: x - barW * 0.4, y: y, width: barW * 0.8, height: h)
                    let alpha = 0.35 + 0.45 * abs(sin(t * 1.8 + phase))
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: barW * 0.4),
                        with: .color(Color.cosmicGold.opacity(alpha))
                    )
                }
            }
        }
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    @Environment(\.cosmicTheme) private var theme
    let message: Message

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 50) }

            if !isUser {
                // Levi icon
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 14, weight: .thin))
                    .foregroundStyle(Color.cosmicGold.opacity(0.4))
                    .padding(.bottom, 4)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .font(CosmicFont.bodySerif(14))
                    .foregroundStyle(isUser
                        ? Color.cosmicGold.opacity(0.85)
                        : Color.cosmicGold.opacity(0.65))
                    .lineSpacing(4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background {
                        if isUser {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cosmicGold.opacity(0.1))
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.cosmicGold.opacity(0.22), lineWidth: 0.6)
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "#0D0518").opacity(0.8))
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.cosmicGold.opacity(0.1), lineWidth: 0.4)
                        }
                    }

                Text(message.time, style: .time)
                    .goldLabel(0.22)
            }

            if isUser {
                Image(systemName: "person.circle")
                    .font(.system(size: 14, weight: .thin))
                    .foregroundStyle(theme.textTertiary)
                    .padding(.bottom, 4)
            }

            if !isUser { Spacer(minLength: 50) }
        }
    }
}

// MARK: - Control Bar

private struct LeviControlBar: View {
    @Environment(\.cosmicTheme) private var theme
    @Binding var isListening:   Bool
    @Binding var isSpeaking:    Bool
    @Binding var sessionActive: Bool
    @Binding var inputText:     String
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Text input
            TextField("Stelle Levi eine Frage …", text: $inputText)
                .font(CosmicFont.heading(14, weight: .light))
                .foregroundStyle(Color.cosmicGold.opacity(0.8))
                .tint(Color.cosmicGold)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.surface.opacity(0.9))
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.cosmicGold.opacity(0.15), lineWidth: 0.6)
                }
                .submitLabel(.send)
                .onSubmit(onSend)
                .disabled(!sessionActive)
                .opacity(sessionActive ? 1 : 0.35)

            // Voice button
            Button {
                guard sessionActive else { return }
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                withAnimation(.spring(duration: 0.3)) {
                    isListening.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(isListening
                              ? Color.cosmicGold.opacity(0.2)
                              : theme.surface.opacity(0.9))
                        .frame(width: 48, height: 48)
                    Circle()
                        .strokeBorder(
                            isListening
                                ? Color.cosmicGold.opacity(0.7)
                                : Color.cosmicGold.opacity(0.18),
                            lineWidth: 0.75
                        )
                        .frame(width: 48, height: 48)
                    Image(systemName: isListening ? "mic.fill" : "mic")
                        .font(.system(size: 18, weight: .thin))
                        .foregroundStyle(Color.cosmicGold.opacity(isListening ? 0.95 : 0.4))
                        .symbolEffect(.breathe, isActive: isListening)
                }
            }
            .buttonStyle(.plain)
            .disabled(!sessionActive)
            .opacity(sessionActive ? 1 : 0.35)
            .accessibilityLabel(isListening ? "Aufnahme stoppen" : "Sprachaufnahme starten")

            // Send button
            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(inputText.isEmpty
                              ? theme.surface.opacity(0.9)
                              : Color.cosmicGold.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Circle()
                        .strokeBorder(Color.cosmicGold.opacity(inputText.isEmpty ? 0.12 : 0.45), lineWidth: 0.75)
                        .frame(width: 48, height: 48)
                    Image(systemName: "paperplane")
                        .font(.system(size: 16, weight: .thin))
                        .foregroundStyle(Color.cosmicGold.opacity(inputText.isEmpty ? 0.25 : 0.85))
                }
            }
            .buttonStyle(.plain)
            .disabled(inputText.isEmpty || !sessionActive)
            .accessibilityLabel("Nachricht senden")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            // iOS 26.2 deployment target — Liquid Glass always available
            GlassEffectContainer(spacing: 0) {
                Color.clear
            }
        }
    }
}

// MARK: - Sample Conversation

extension Message {
    static let sampleConversation: [Message] = [
        Message(role: .levi, text: "Willkommen. Ich bin Levi Bazi, dein kosmischer Begleiter. Dein Blueprint liegt vor mir — womit soll ich beginnen?"),
        Message(role: .user, text: "Was bedeutet mein Day Master für meine Lebensenergie?"),
        Message(role: .levi, text: "Dein Day Master ist 壬 (Yang Wasser) — eine tiefe, fließende Kraft. Du bewegst dich wie ein Ozean: ruhig an der Oberfläche, mit enormer Tiefe darunter. Du suchst Wahrheit intuitiv, nicht logisch."),
    ]
}

// MARK: - Preview

#Preview {
    LeviView()
        .environment({
            let s = CosmicStore()
            s.profile = .mock
            return s
        }())
}
