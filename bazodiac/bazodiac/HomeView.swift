// HomeView.swift
// Bazodiac iOS — Cosmic Blueprint Dashboard
//
// The "atlas" overview: orbital header animation, Big Three badges,
// daily interpretation card, quick-nav section grid, and Levi teaser.

import SwiftUI
import UIKit

struct HomeView: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        ZStack(alignment: .topTrailing) {
            theme.background.ignoresSafeArea()

            // Light-Mode: sanfte goldene Partikel statt Sternenfeld
            if theme.isDark {
                StarfieldView(starCount: 80).ignoresSafeArea()
            } else {
                LightAmbientView(count: 80).ignoresSafeArea()
            }

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0, pinnedViews: []) {
                    CosmicHeader()
                        .padding(.bottom, 28)

                    contentStack
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120) // tab bar clearance
                }
            }
            .scrollBounceBehavior(.basedOnSize)

            // Theme-Toggle oben rechts
            ThemeToggleButton { store.toggleTheme() }
                .padding(.top, 58)
                .padding(.trailing, 20)
        }
    }

    private var contentStack: some View {
        VStack(spacing: 20) {
            BigThreeBadges()
            DailyInsightCard()
            GoldLine()
                .padding(.vertical, 4)
            SectionNavigationGrid()
            GoldLine()
                .padding(.vertical, 4)
            LeviTeaser()
            DailyQuoteCard()
        }
    }
}

// MARK: - Cosmic Header (Orbital Animation + Name)

private struct CosmicHeader: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        ZStack {
            // Orbital orrery animation
            OrbitalRingsView(rings: 4, baseRadius: 44, ringSpacing: 30)
                .frame(height: 260)
                .opacity(0.6)

            // Central glow
            RadialGradient(
                colors: [Color.cosmicGold.opacity(0.1), .clear],
                center: .center,
                startRadius: 10,
                endRadius: 120
            )
            .frame(height: 260)
            .allowsHitTesting(false)

            VStack(spacing: 4) {
                // Sun symbol
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 24, weight: .ultraLight))
                    .foregroundStyle(Color.cosmicGold.opacity(0.8))
                    .symbolEffect(.breathe)

                Spacer().frame(height: 8)

                // Title
                Text("Bazodiac")
                    .font(CosmicFont.display(42))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.textPrimary, theme.textSecondary.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .tracking(4)

                // Personalised sub-label
                if !store.displayName.isEmpty, store.displayName != "Dein Kosmos" {
                    Text(store.displayName)
                        .goldLabel(0.55)
                        .tracking(5)
                        .padding(.top, 2)
                }

                // Birth place
                if let profile = store.profile {
                    Text(profile.birthData.birthPlace)
                        .font(CosmicFont.mono(11))
                        .foregroundStyle(theme.textTertiary)
                        .tracking(1)
                        .padding(.top, 2)
                }
            }
            .frame(height: 260)
        }
    }
}

// MARK: - Big Three Badges (Sun / Moon / Ascendant)

private struct BigThreeBadges: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        HStack(spacing: 12) {
            if let w = store.profile?.westernData {
                BigThreeBadge(
                    title: "Sonne",
                    sfSymbol: "sun.max.fill",
                    sign: w.sunSign,
                    degree: w.sunDegree
                )
                BigThreeBadge(
                    title: "Mond",
                    sfSymbol: "moon.fill",
                    sign: w.moonSign,
                    degree: w.moonDegree
                )
                BigThreeBadge(
                    title: "Aszendent",
                    sfSymbol: "arrow.up.circle",
                    sign: w.ascendant,
                    degree: w.ascendantDegree
                )
            }
        }
    }
}

private struct BigThreeBadge: View {
    @Environment(\.cosmicTheme) private var theme
    let title: String
    let sfSymbol: String
    let sign: ZodiacSign
    let degree: Double

    var body: some View {
        VStack(spacing: 8) {
            // Element color dot with SF Symbol
            Circle()
                .fill(sign.element.color.opacity(0.25))
                .frame(width: 44, height: 44)
                .overlay {
                    Circle()
                        .strokeBorder(sign.element.color.opacity(0.4), lineWidth: 0.75)
                    Image(systemName: sfSymbol)
                        .font(.system(size: 16, weight: .thin))
                        .foregroundStyle(sign.element.color)
                }

            VStack(spacing: 2) {
                Text(title)
                    .goldLabel(0.4)
                Text(sign.germanName)
                    .font(CosmicFont.heading(13, weight: .light))
                    .foregroundStyle(theme.textPrimary.opacity(0.85))
                Text(String(format: "%.1f°", degree))
                    .font(CosmicFont.mono(10))
                    .foregroundStyle(theme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .cosmicCard(cornerRadius: 14)
    }
}

// MARK: - Daily Insight Card

private struct DailyInsightCard: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Tages-Interpretation", systemImage: "sparkles")
                    .goldLabel(0.55)
                    .labelStyle(.titleAndIcon)
                Spacer()
                Text("Heute")
                    .goldLabel(0.3)
            }

            GoldLine()

            let text = store.profile?.interpretation ?? ""
            Text(text)
                .font(CosmicFont.bodySerif(14))
                .foregroundStyle(theme.textSecondary)
                .lineSpacing(5)
                .lineLimit(expanded ? nil : 3)

            Button {
                withAnimation(.spring(duration: 0.4)) {
                    expanded.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(expanded ? "Weniger" : "Mehr lesen")
                        .goldLabel(0.5)
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(Color.cosmicGold.opacity(0.5))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .cosmicCard()
    }
}

// MARK: - Section Navigation Grid

private struct SectionNavigationGrid: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    private let sections: [(tab: CosmicStore.Tab, title: String, sub: String, icon: String)] = [
        (.chart,   "Geburts-Chart",  "Western Astrologie",  "scope"),
        (.bazi,    "BaZi Säulen",    "Vier Pfeiler",         "rectangle.grid.2x2.fill"),
        (.quizzes, "Quizzes",        "Kosmische Muster",     "square.grid.2x2.fill"),
        (.levi,    "Levi",           "KI-Begleiter",         "waveform.circle.fill"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Dein Kosmos")
                    .goldLabel(0.55)
                Spacer()
            }
            .padding(.bottom, 12)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ], spacing: 12) {
                ForEach(sections, id: \.title) { section in
                    SectionCard(
                        title: section.title,
                        subtitle: section.sub,
                        icon: section.icon
                    ) {
                        withAnimation(.spring(duration: 0.3)) {
                            store.selectedTab = section.tab
                        }
                    }
                }
            }
        }
    }
}

private struct SectionCard: View {
    @Environment(\.cosmicTheme) private var theme
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .thin))
                    .foregroundStyle(Color.cosmicGold.opacity(0.75))

                Spacer()

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(CosmicFont.heading(13, weight: .regular))
                        .foregroundStyle(theme.textPrimary)

                    Text(subtitle)
                        .goldLabel(0.4)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 110)
            .cosmicCard(cornerRadius: 14)
            .scaleEffect(pressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { pressed = true } }
                .onEnded   { _ in withAnimation(.spring(duration: 0.3))  { pressed = false } }
        )
    }
}

// MARK: - Levi Teaser

private struct LeviTeaser: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            withAnimation { store.selectedTab = .levi }
        } label: {
            HStack(spacing: 16) {
                // Waveform visual
                LeviWaveformMini()
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Levi Bazi")
                        .font(CosmicFont.heading(15, weight: .light))
                        .foregroundStyle(theme.textPrimary)
                    Text("Dein KI-Kosmosbegleiter · Jetzt sprechen")
                        .goldLabel(0.45)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .thin))
                    .foregroundStyle(theme.textTertiary)
            }
            .padding(18)
            .background {
                // Special gradient background for Levi
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cosmicGold.opacity(0.08),
                                theme.surface.opacity(0.5),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.cosmicGold.opacity(0.2), lineWidth: 0.75)
            }
        }
        .buttonStyle(.plain)
    }
}

/// Tiny animated waveform for the Levi teaser
private struct LeviWaveformMini: View {
    @Environment(\.cosmicTheme) private var theme
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let bars = 9
                let barW: CGFloat = size.width / CGFloat(bars * 2)
                let cx = size.width / 2

                for i in 0..<bars {
                    let x = cx + CGFloat(i - bars / 2) * barW * 2
                    let phase = Double(i) * 0.6
                    let h = size.height * (0.2 + 0.6 * abs(sin(t * 1.4 + phase)))
                    let y = (size.height - h) / 2
                    let rect = CGRect(x: x - barW / 2, y: y, width: barW, height: h)
                    let alpha = 0.4 + 0.4 * abs(sin(t * 1.4 + phase))
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: barW),
                        with: .color(Color.cosmicGold.opacity(alpha))
                    )
                }
            }
        }
    }
}

// MARK: - Daily Quote Card

private struct DailyQuoteCard: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "quote.opening")
                .font(.system(size: 20, weight: .ultraLight))
                .foregroundStyle(theme.textTertiary)

            Text(store.profile?.dailyQuote ?? "")
                .font(CosmicFont.bodySerif(14))
                .foregroundStyle(Color.cosmicGold.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .italic()

            Text("Bazodiac · Heute")
                .goldLabel(0.25)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .cosmicCard()
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environment({
            let s = CosmicStore()
            s.profile = .mock
            return s
        }())
}
