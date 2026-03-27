// EveView.swift
// Bazodiac iOS — Eve Astro KI-Agentin
//
// Eve ist die feminine Gegenseite zu Levi.
// Während Levi tief, analytisch und dunkel-mystisch agiert,
// ist Eve warm, intuitiv und lichterfüllt — die helle Stimme des Kosmos.
//
// Voice API: ElevenLabs Conversational AI (gleiche Architektur wie Levi)
// Agent-ID: separat in AppConfig konfiguriert

import SwiftUI
import UIKit

// MARK: - Message Model

private struct EveMessage: Identifiable {
    let id = UUID()
    let role: Role
    let text: String
    let time: Date = Date()
    enum Role { case user, eve }
}

// MARK: - Eve View

struct EveView: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    @State private var messages: [EveMessage] = []
    @State private var isListening   = false
    @State private var isSpeaking    = false
    @State private var sessionActive = false
    @State private var inputText     = ""
    @State private var eveService     = EveConversationHandler()

    private let scrollID = "eve-bottom"

    // Eve's cosmic violet palette
    private let eveGlow  = Color(hex: "#A78BFA")  // Violet
    private let eveDeep  = Color(hex: "#7C3AED")  // Deep violet
    private let eveLight = Color(hex: "#DDD6FE")  // Soft lavender

    var body: some View {
        ZStack {
            // Eve's ambient — violet cosmos
            Group {
                if theme.isDark {
                    LinearGradient(
                        colors: [theme.background, Color(hex: "#0A0520")],
                        startPoint: .top, endPoint: .bottom
                    )
                } else {
                    LinearGradient(
                        colors: [theme.background, Color(hex: "#F3EDFF")],
                        startPoint: .top, endPoint: .bottom
                    )
                }
            }
            .ignoresSafeArea()

            if theme.isDark {
                StarfieldView(starCount: 70, goldTint: false).ignoresSafeArea().opacity(0.25)
            } else {
                LightAmbientView(count: 50).ignoresSafeArea().opacity(0.4)
            }

            VStack(spacing: 0) {
                eveHeader
                EveAvatarSection(isSpeaking: isSpeaking, isListening: isListening, glow: eveGlow)
                    .frame(height: 160)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)

                // Conversation
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { msg in
                                EveBubble(message: msg, eveColor: eveGlow)
                                    .transition(.push(from: .bottom))
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

                EveControlBar(
                    isListening: $isListening,
                    isSpeaking: $isSpeaking,
                    sessionActive: $sessionActive,
                    inputText: $inputText,
                    eveColor: eveGlow,
                    onSend: sendMessage
                )
                .padding(.bottom, max(100, 88))
            }
        }
    }

    // MARK: - Header

    private var eveHeader: some View {
        HStack(spacing: 12) {
            // Eve avatar
            ZStack {
                Circle()
                    .fill(eveGlow.opacity(theme.isDark ? 0.15 : 0.1))
                    .frame(width: 44, height: 44)
                Circle()
                    .strokeBorder(eveGlow.opacity(sessionActive ? 0.6 : 0.2), lineWidth: 0.75)
                    .frame(width: 44, height: 44)
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .thin))
                    .foregroundStyle(eveGlow.opacity(sessionActive ? 0.9 : 0.5))
                    .symbolEffect(.breathe, isActive: sessionActive)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Eve")
                    .font(CosmicFont.heading(17, weight: .light))
                    .foregroundStyle(theme.textPrimary)
                Text(sessionActive
                     ? (isSpeaking ? "Spricht …" : isListening ? "Hört zu …" : "Verbunden")
                     : "Kosmische Intuition")
                    .goldLabel(0.45)
            }

            Spacer()

            // Session toggle
            Button {
                withAnimation(.spring(duration: 0.4)) {
                    sessionActive.toggle()
                    if !sessionActive {
                        isListening = false; isSpeaking = false
                    } else {
                        // Echte ElevenLabs-Verbindung
                        eveService.onText = { text in addEveMessage(text) }
                        eveService.connect(
                            profile: store.profile,
                            language: store.language
                        )
                    }
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Label(sessionActive ? "Ende" : "Start",
                      systemImage: sessionActive ? "stop.circle.fill" : "play.circle.fill")
                    .font(CosmicFont.label(9))
                    .tracking(2)
                    .foregroundStyle(sessionActive ? Color.elementFire.opacity(0.8) : eveGlow.opacity(0.8))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background {
                        Capsule().strokeBorder(
                            sessionActive ? Color.elementFire.opacity(0.35) : eveGlow.opacity(0.25),
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
            messages.append(EveMessage(role: .user, text: text))
        }
        inputText = ""

        withAnimation(.spring(duration: 0.3)) { isSpeaking = true }

        if eveService.isConnected {
            eveService.send(text: text)
        } else {
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                addEveMessage(eveResponse(for: text))
                withAnimation { isSpeaking = false }
            }
        }
    }

    private func addEveMessage(_ text: String) {
        withAnimation(.spring(duration: 0.4)) {
            messages.append(EveMessage(role: .eve, text: text))
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Placeholder-Antworten (wird durch ElevenLabsService.shared ersetzt)
    private func eveResponse(for input: String) -> String {
        let responses = [
            "Dein Aszendent flüstert heute von Neuanfängen. Vertraue diesem Impuls — er kennt den Weg, auch wenn du ihn noch nicht siehst.",
            "Ich spüre die Spannung zwischen Mond und Sonne in deinem Chart. Das ist nicht Kampf — das ist Dialog. Hör beiden Seiten zu.",
            "Dein Wasser-Element dominiert gerade stark. Lass die Welle nicht gegen das Ufer schlagen — lass sie sanft auslaufen.",
            "Die Kirschblüte in dir beginnt sich zu öffnen. Dieser Moment der Verletzlichkeit ist gleichzeitig dein stärkster Moment.",
            "Mars und Venus tanzen gerade in deinem 7. Haus. Das Thema Beziehung ist kein Zufall — es ist eine kosmische Einladung.",
            "Dein BaZi zeigt eine seltene Konstellation: Wasser nährt Holz, Holz nährt Feuer. Du bist im Fluss der Transformation.",
        ]
        return responses.randomElement() ?? responses[0]
    }
}

// MARK: - Eve Avatar (Violet Waveform)

private struct EveAvatarSection: View {
    let isSpeaking: Bool
    let isListening: Bool
    let glow: Color
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [glow.opacity(isSpeaking ? 0.2 : 0.08), .clear],
                center: .center, startRadius: 15, endRadius: 80
            )
            .animation(.easeInOut(duration: 0.6), value: isSpeaking)

            if isSpeaking || isListening {
                EveWaveform(isSpeaking: isSpeaking, isListening: isListening, color: glow)
                    .frame(height: 70)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else {
                OrbitalRingsView(rings: 2, baseRadius: 24, ringSpacing: 20)
                    .opacity(0.3)
            }

            // Center sigil
            ZStack {
                Circle()
                    .fill(theme.isDark ? Color(hex: "#0D0520").opacity(0.9) : Color.white.opacity(0.9))
                    .frame(width: 56, height: 56)
                Circle()
                    .strokeBorder(glow.opacity(isSpeaking ? 0.7 : 0.25), lineWidth: 0.75)
                    .frame(width: 56, height: 56)
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .ultraLight))
                    .foregroundStyle(glow.opacity(isSpeaking ? 0.9 : 0.4))
                    .symbolEffect(.breathe, isActive: isSpeaking)
            }
        }
        .animation(.spring(duration: 0.5), value: isSpeaking)
    }
}

private struct EveWaveform: View {
    let isSpeaking: Bool
    let isListening: Bool
    let color: Color

    var body: some View {
        TimelineView(.animation) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let bars = 24
                let barW = size.width / CGFloat(bars * 2 - 1)
                let cx = size.width / 2

                for i in 0..<bars {
                    let x = cx + CGFloat(i - bars / 2) * barW * 2
                    let phase = Double(i) * 0.55
                    let baseH = size.height * 0.12
                    let h: CGFloat = isSpeaking
                        ? baseH + size.height * 0.55 * CGFloat(abs(sin(t * 2.0 + phase)))
                        : isListening
                            ? baseH + size.height * 0.3 * CGFloat(abs(sin(t * 1.1 + phase)))
                            : baseH
                    let y = (size.height - h) / 2
                    let rect = CGRect(x: x - barW * 0.35, y: y, width: barW * 0.7, height: h)
                    let alpha = 0.3 + 0.5 * abs(sin(t * 1.6 + phase))
                    ctx.fill(Path(roundedRect: rect, cornerRadius: barW * 0.35),
                             with: .color(color.opacity(alpha)))
                }
            }
        }
    }
}

// MARK: - Eve Message Bubble

private struct EveBubble: View {
    let message: EveMessage
    let eveColor: Color
    @Environment(\.cosmicTheme) private var theme

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 50) }
            if !isUser {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .thin))
                    .foregroundStyle(eveColor.opacity(0.5))
                    .padding(.bottom, 4)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .font(CosmicFont.bodySerif(14))
                    .foregroundStyle(isUser ? theme.textPrimary.opacity(0.85) : theme.textSecondary)
                    .lineSpacing(4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background {
                        if isUser {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(eveColor.opacity(0.1))
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(eveColor.opacity(0.22), lineWidth: 0.6)
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(theme.isDark ? Color(hex: "#0D0520").opacity(0.7) : Color(hex: "#F3EDFF").opacity(0.8))
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(eveColor.opacity(0.12), lineWidth: 0.4)
                        }
                    }

                Text(message.time, style: .time)
                    .goldLabel(0.22)
            }

            if isUser {
                Image(systemName: "person.circle")
                    .font(.system(size: 12, weight: .thin))
                    .foregroundStyle(theme.textTertiary)
                    .padding(.bottom, 4)
            }
            if !isUser { Spacer(minLength: 50) }
        }
    }
}

// MARK: - Eve Control Bar

private struct EveControlBar: View {
    @Binding var isListening: Bool
    @Binding var isSpeaking: Bool
    @Binding var sessionActive: Bool
    @Binding var inputText: String
    let eveColor: Color
    let onSend: () -> Void
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        HStack(spacing: 12) {
            TextField("Frag Eve …", text: $inputText)
                .font(CosmicFont.heading(14, weight: .light))
                .foregroundStyle(theme.textPrimary)
                .tint(eveColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.surface.opacity(0.9))
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(eveColor.opacity(0.15), lineWidth: 0.6)
                }
                .submitLabel(.send)
                .onSubmit(onSend)
                .disabled(!sessionActive)
                .opacity(sessionActive ? 1 : 0.35)

            // Mic
            Button {
                guard sessionActive else { return }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(duration: 0.3)) { isListening.toggle() }
            } label: {
                ZStack {
                    Circle()
                        .fill(isListening ? eveColor.opacity(0.2) : theme.surface.opacity(0.9))
                        .frame(width: 48, height: 48)
                    Circle()
                        .strokeBorder(isListening ? eveColor.opacity(0.7) : eveColor.opacity(0.18), lineWidth: 0.75)
                        .frame(width: 48, height: 48)
                    Image(systemName: isListening ? "mic.fill" : "mic")
                        .font(.system(size: 18, weight: .thin))
                        .foregroundStyle(eveColor.opacity(isListening ? 0.95 : 0.4))
                        .symbolEffect(.breathe, isActive: isListening)
                }
            }
            .buttonStyle(.plain)
            .disabled(!sessionActive)
            .opacity(sessionActive ? 1 : 0.35)

            // Send
            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(inputText.isEmpty ? theme.surface.opacity(0.9) : eveColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Circle()
                        .strokeBorder(eveColor.opacity(inputText.isEmpty ? 0.12 : 0.45), lineWidth: 0.75)
                        .frame(width: 48, height: 48)
                    Image(systemName: "paperplane")
                        .font(.system(size: 16, weight: .thin))
                        .foregroundStyle(eveColor.opacity(inputText.isEmpty ? 0.25 : 0.85))
                }
            }
            .buttonStyle(.plain)
            .disabled(inputText.isEmpty || !sessionActive)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            if #available(iOS 26, *) {
                GlassEffectContainer(spacing: 0) { Color.clear }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    EveView()
        .environment(CosmicStore())
}
