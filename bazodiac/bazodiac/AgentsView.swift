// AgentsView.swift
// Bazodiac iOS — Agent-Auswahl (Levi & Eve)
//
// Beide Agents als große Kacheln dargestellt:
//   - Name groß oben
//   - Kerneigenschaften darunter
//   - i18n Hinweis unten
//
// Levi: Dunkelblau + Gold + Weiß
// Eve:  Violett + Silber-Schimmer + Petrol (15%)

import SwiftUI
import UIKit

struct AgentsView: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    @State private var selectedAgent: ConvaiAgent? = nil

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            if theme.isDark {
                StarfieldView(starCount: 50).ignoresSafeArea().opacity(0.3)
            } else {
                LightAmbientView(count: 40).ignoresSafeArea()
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                        .padding(.top, 60)
                        .padding(.bottom, 28)

                    // Kacheln
                    VStack(spacing: 16) {
                        LeviCard {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            selectedAgent = .levi
                        }

                        EveCard {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            selectedAgent = .eve
                        }
                    }
                    .padding(.horizontal, 20)

                    // i18n Hinweis
                    infoHint
                        .padding(.horizontal, 28)
                        .padding(.top, 24)
                        .padding(.bottom, 120)
                }
            }
        }
        .fullScreenCover(item: $selectedAgent) { agent in
            switch agent {
            case .levi:
                LeviView()
                    .environment(store)
                    .environment(\.cosmicTheme, theme)
            case .eve:
                EveView()
                    .environment(store)
                    .environment(\.cosmicTheme, theme)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 26, weight: .thin))
                .foregroundStyle(theme.gold.opacity(0.7))

            Text(store.language == .german ? "Deine Begleiter" : "Your Companions")
                .font(CosmicFont.display(30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.textPrimary, theme.textSecondary],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .tracking(2)

            Text(store.language == .german
                 ? "Wähle deinen kosmischen Guide"
                 : "Choose your cosmic guide")
                .goldLabel(0.4)
                .tracking(4)
        }
    }

    // MARK: - Info Hint (i18n)

    private var infoHint: some View {
        VStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.system(size: 14, weight: .thin))
                .foregroundStyle(theme.textTertiary)

            Text(store.language == .german
                 ? "Levi und Eve besitzen das gleiche Wissen über Bazodiac und die Fusions-Deutung — sie unterscheiden sich nur im Wesen."
                 : "Levi and Eve share the same knowledge about Bazodiac and Fusion readings — they only differ in character.")
                .font(CosmicFont.bodySerif(12))
                .foregroundStyle(theme.textTertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(16)
        .background(theme.goldFaint, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(theme.goldBorder, lineWidth: 0.5)
        )
    }
}

// MARK: - Levi Card
// Farbpalette: Dunkelblau (#0A1628) + Gold (#D4AF37) + Weiß

private struct LeviCard: View {
    let onTap: () -> Void
    @Environment(\.cosmicTheme) private var theme
    @Environment(CosmicStore.self) private var store
    @State private var pressed = false

    // Levi Farben
    private let deepBlue = Color(hex: "#0A1628")
    private let gold     = Color(hex: "#D4AF37")
    private let white    = Color.white

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Oberer Bereich: Name + Icon ───────────────────────
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Levi")
                            .font(CosmicFont.display(38))
                            .foregroundStyle(gold)
                            .tracking(2)

                        Text("Bazi")
                            .font(CosmicFont.heading(14, weight: .light))
                            .foregroundStyle(gold.opacity(0.5))
                            .tracking(4)
                            .textCase(.uppercase)
                    }

                    Spacer()

                    // Waveform icon
                    ZStack {
                        Circle()
                            .fill(gold.opacity(0.12))
                            .frame(width: 52, height: 52)
                        Circle()
                            .strokeBorder(gold.opacity(0.35), lineWidth: 0.75)
                            .frame(width: 52, height: 52)
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 24, weight: .thin))
                            .foregroundStyle(gold.opacity(0.8))
                    }
                }
                .padding(.bottom, 20)

                // ── Kerneigenschaften ─────────────────────────────────
                HStack(spacing: 8) {
                    ForEach(leviTraits, id: \.self) { trait in
                        Text(trait)
                            .font(CosmicFont.label(8))
                            .tracking(2)
                            .foregroundStyle(white.opacity(0.6))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(gold.opacity(0.08), in: Capsule())
                            .overlay(Capsule().strokeBorder(gold.opacity(0.18), lineWidth: 0.5))
                    }
                }
                .padding(.bottom, 16)

                // ── Beschreibung ──────────────────────────────────────
                Text(store.language == .german
                     ? "Analytisch, tiefgründig und klar — Levi führt dich mit ruhiger Präzision durch dein kosmisches Profil."
                     : "Analytical, profound and clear — Levi guides you through your cosmic profile with calm precision.")
                    .font(CosmicFont.bodySerif(13))
                    .foregroundStyle(white.opacity(0.45))
                    .lineSpacing(4)
                    .padding(.bottom, 16)

                // ── CTA ──────────────────────────────────────────────
                HStack {
                    Text(store.language == .german ? "Gespräch starten" : "Start conversation")
                        .font(CosmicFont.label(9))
                        .tracking(3)
                        .foregroundStyle(gold.opacity(0.7))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .thin))
                        .foregroundStyle(gold.opacity(0.5))
                }
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [deepBlue, deepBlue.opacity(0.9), Color(hex: "#0D1E3A")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [gold.opacity(0.35), gold.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: deepBlue.opacity(0.4), radius: 16, y: 6)
            .scaleEffect(pressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { pressed = true } }
                .onEnded   { _ in withAnimation(.spring(duration: 0.3)) { pressed = false } }
        )
    }

    private var leviTraits: [String] {
        store.language == .german
            ? ["ANALYTISCH", "KLAR", "TIEFGRÜNDIG"]
            : ["ANALYTICAL", "CLEAR", "PROFOUND"]
    }
}

// MARK: - Eve Card
// Farbpalette: Violett (#7C3AED) + Silber-Schimmer (#C0C0C0) + Petrol (#0D6B6E, 15%)

private struct EveCard: View {
    let onTap: () -> Void
    @Environment(\.cosmicTheme) private var theme
    @Environment(CosmicStore.self) private var store
    @State private var pressed = false

    // Eve Farben
    private let violet  = Color(hex: "#7C3AED")
    private let silver  = Color(hex: "#C0C0C0")
    private let petrol  = Color(hex: "#0D6B6E")
    private let deepBg  = Color(hex: "#0E0A1E")

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Oberer Bereich: Name + Icon ───────────────────────
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Eve")
                            .font(CosmicFont.display(38))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [silver, Color(hex: "#DDD6FE")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .tracking(2)

                        Text(store.language == .german ? "Intuition" : "Intuition")
                            .font(CosmicFont.heading(14, weight: .light))
                            .foregroundStyle(violet.opacity(0.55))
                            .tracking(4)
                            .textCase(.uppercase)
                    }

                    Spacer()

                    // Sparkles icon mit Silber-Schimmer
                    ZStack {
                        Circle()
                            .fill(violet.opacity(0.15))
                            .frame(width: 52, height: 52)
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [silver.opacity(0.4), violet.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.75
                            )
                            .frame(width: 52, height: 52)
                        Image(systemName: "sparkles")
                            .font(.system(size: 22, weight: .thin))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [silver.opacity(0.9), violet.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
                .padding(.bottom, 20)

                // ── Kerneigenschaften ─────────────────────────────────
                HStack(spacing: 8) {
                    ForEach(eveTraits, id: \.self) { trait in
                        Text(trait)
                            .font(CosmicFont.label(8))
                            .tracking(2)
                            .foregroundStyle(silver.opacity(0.65))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(violet.opacity(0.1), in: Capsule())
                            .overlay(Capsule().strokeBorder(violet.opacity(0.2), lineWidth: 0.5))
                    }
                }
                .padding(.bottom, 16)

                // ── Beschreibung ──────────────────────────────────────
                Text(store.language == .german
                     ? "Sanft, intuitiv und warmherzig — Eve spürt die Zwischentöne deines Kosmos und spricht die Sprache deiner Seele."
                     : "Gentle, intuitive and warm — Eve senses the subtleties of your cosmos and speaks the language of your soul.")
                    .font(CosmicFont.bodySerif(13))
                    .foregroundStyle(silver.opacity(0.4))
                    .lineSpacing(4)
                    .padding(.bottom, 16)

                // ── CTA ──────────────────────────────────────────────
                HStack {
                    Text(store.language == .german ? "Gespräch starten" : "Start conversation")
                        .font(CosmicFont.label(9))
                        .tracking(3)
                        .foregroundStyle(violet.opacity(0.7))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .thin))
                        .foregroundStyle(violet.opacity(0.5))
                }
            }
            .padding(24)
            .background {
                // Hintergrund: Violett + Petrol (15%)
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [deepBg, deepBg.opacity(0.9), petrol.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                // Silber-Schimmer Rand
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [silver.opacity(0.25), violet.opacity(0.2), petrol.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: violet.opacity(0.2), radius: 16, y: 6)
            .scaleEffect(pressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { pressed = true } }
                .onEnded   { _ in withAnimation(.spring(duration: 0.3)) { pressed = false } }
        )
    }

    private var eveTraits: [String] {
        store.language == .german
            ? ["SANFT", "INTUITIV", "WARMHERZIG"]
            : ["GENTLE", "INTUITIVE", "WARM"]
    }
}

// MARK: - ConvaiAgent Identifiable (für fullScreenCover)

extension ConvaiAgent: @retroactive Identifiable {
    var id: String { agentId }
}

// MARK: - Preview

#Preview {
    AgentsView()
        .environment(CosmicStore())
}
