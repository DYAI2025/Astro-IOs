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
            // ── Day Mode — Pulse ODER Trace (nie beides) ─────────────
            DayModeCard()

            CosmicTriad()

            GoldLine().padding(.vertical, 4)
            SectionNavigationGrid()
            GoldLine().padding(.vertical, 4)
            AgentsTeaser()
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

// MARK: - Drei Kacheln: Sonnenzeichen · Jahrestier · Dominantes Element

private struct CosmicTriad: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    @State private var showSunDetail = false
    @State private var showAnimalDetail = false
    @State private var showElementDetail = false

    var body: some View {
        HStack(spacing: 12) {
            if let p = store.profile {
                // 1. Sonnenzeichen
                TriadTile(
                    label: store.language == .german ? "Sonne" : "Sun",
                    value: p.westernData.sunSign.germanName,
                    sfSymbol: "sun.max.fill",
                    color: p.westernData.sunSign.element.color
                ) { showSunDetail = true }

                // 2. Jahrestier (BaZi)
                TriadTile(
                    label: store.language == .german ? "Jahrestier" : "Year Animal",
                    value: p.baziData.year.branch.animal,
                    sfSymbol: "leaf.fill",
                    color: p.baziData.year.branch.element.color
                ) { showAnimalDetail = true }

                // 3. Dominantes Element (Wu Xing)
                TriadTile(
                    label: store.language == .german ? "Element" : "Element",
                    value: p.wuxingData.dominant.germanName,
                    sfSymbol: p.wuxingData.dominant.symbol,
                    color: p.wuxingData.dominant.color
                ) { showElementDetail = true }
            }
        }
        .sheet(isPresented: $showSunDetail) {
            if let p = store.profile {
                SunSignDetailSheet(profile: p, language: store.language)
                    .environment(\.cosmicTheme, theme)
                    .presentationDetents([.fraction(0.75)])
                    .presentationBackground(theme.surfaceElevated)
            }
        }
        .sheet(isPresented: $showAnimalDetail) {
            if let p = store.profile {
                YearAnimalDetailSheet(profile: p, language: store.language)
                    .environment(\.cosmicTheme, theme)
                    .presentationDetents([.fraction(0.75)])
                    .presentationBackground(theme.surfaceElevated)
            }
        }
        .sheet(isPresented: $showElementDetail) {
            if let p = store.profile {
                WuXingDetailSheet(profile: p, language: store.language)
                    .environment(\.cosmicTheme, theme)
                    .presentationDetents([.fraction(0.75)])
                    .presentationBackground(theme.surfaceElevated)
            }
        }
    }
}

private struct TriadTile: View {
    @Environment(\.cosmicTheme) private var theme
    let label: String
    let value: String
    let sfSymbol: String
    let color: Color
    let onTap: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Circle().strokeBorder(color.opacity(0.4), lineWidth: 0.75)
                        Image(systemName: sfSymbol)
                            .font(.system(size: 16, weight: .thin))
                            .foregroundStyle(color)
                    }

                VStack(spacing: 2) {
                    Text(label)
                        .goldLabel(0.4)
                    Text(value)
                        .font(CosmicFont.heading(13, weight: .light))
                        .foregroundStyle(theme.textPrimary.opacity(0.85))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .cosmicCard(cornerRadius: 14)
            .scaleEffect(pressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { pressed = true } }
                .onEnded   { _ in withAnimation(.spring(duration: 0.3)) { pressed = false } }
        )
    }
}

// MARK: - Day Mode Card (Pulse ODER Trace — nie beides)
//
// H ≥ 0.50 → TRACE (Pole kreuzen sich, direkt, geladen, handlungsorientiert)
// H <  0.50 → PULSE (symmetrisch, poetischer Realismus, atmosphärisch)
// Kein Astro-Vokabular. Kein "weil". 2–3 Sätze.

private struct DayModeCard: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme
    @State private var harmonic: DayHarmonicState = .neutral
    @State private var weather: CosmicWeather?
    @State private var text: String = ""
    @State private var appeared = false

    private var isTrace: Bool { harmonic.mode == .trace }

    // Trace: Gold · Pulse: Silber-Blau
    private var modeColor: Color {
        isTrace ? Color(hex: "#D4AF37") : Color(hex: "#A0B4CC")
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {

            // ── Mode Label ──────────────────────────────────────
            Text(isTrace ? "DAY-TRACE" : "DAY-PULSE")
                .font(CosmicFont.display(26))
                .foregroundStyle(modeColor)
                .tracking(4)
                .padding(.bottom, 2)

            Text(Date(), format: .dateTime.day().month(.wide))
                .font(CosmicFont.mono(11))
                .foregroundStyle(theme.textTertiary)
                .padding(.bottom, 16)

            // ── Visual Snapshot ──────────────────────────────────
            ModeVisual(mode: harmonic.mode, intensity: harmonic.intensity, color: modeColor)
                .frame(width: 120, height: 120)
                .padding(.bottom, 20)

            // ── Text: 2–3 Sätze ─────────────────────────────────
            Text(text)
                .font(CosmicFont.bodySerif(15))
                .foregroundStyle(theme.textPrimary.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(7)
                .italic(harmonic.mode == .pulse)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)

            // ── Subtext: Mond + Kp (nur wenn geladen) ───────────
            if let w = weather {
                HStack(spacing: 6) {
                    Image(systemName: w.moonPhase.icon)
                        .font(.system(size: 10, weight: .thin))
                        .foregroundStyle(theme.textTertiary)
                    Text(store.language == .german ? w.moonPhase.germanName : w.moonPhase.englishName)
                        .font(CosmicFont.mono(9))
                        .foregroundStyle(theme.textTertiary)

                    if w.kpIndex >= 5 {
                        Text("· ⚡ Kp \(String(format: "%.0f", w.kpIndex))")
                            .font(CosmicFont.mono(9))
                            .foregroundStyle(Color(hex: "#EA4335").opacity(0.7))
                    }
                }
                .padding(.top, 14)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackground)
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [modeColor.opacity(0.3), theme.goldBorder],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(duration: 0.8).delay(0.1), value: appeared)
        .onAppear {
            appeared = true
            loadDayMode()
        }
    }

    private func loadDayMode() {
        guard let profile = store.profile else { return }

        // 1. Berechne H
        harmonic = DayHarmonicEngine.fromProfile(profile)

        // 2. Lade Wetter (async)
        Task {
            let w = await CosmicWeatherService.shared.fetch()
            weather = w

            // 3. Generiere Text
            text = DayModeTextGenerator.generate(
                mode: harmonic.mode,
                intensity: harmonic.intensity,
                profile: profile,
                weather: w,
                language: store.language
            )
        }
    }
}

// MARK: - Mode Visual (Canvas: Pulse = Ringe, Trace = Lissajous)

private struct ModeVisual: View {
    let mode: DayMode
    let intensity: Double
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let r = min(cx, cy) * 0.85

            if mode == .pulse {
                // Konzentrische Ringe — ruhig, symmetrisch
                let rings = 3 + Int(intensity * 2)
                for i in 0..<rings {
                    let t = Double(i) / Double(max(rings - 1, 1))
                    let ringR = r * (0.3 + t * 0.7)
                    let alpha = (1 - t) * (0.35 + intensity * 0.25)
                    let rect = CGRect(x: cx - ringR, y: cy - ringR, width: ringR * 2, height: ringR * 2)
                    ctx.stroke(Path(ellipseIn: rect),
                               with: .color(color.opacity(alpha)),
                               lineWidth: 0.8 + intensity * 0.5)
                }
                // Zentrumspunkt
                let dotR: CGFloat = 3
                ctx.fill(Path(ellipseIn: CGRect(x: cx - dotR, y: cy - dotR, width: dotR * 2, height: dotR * 2)),
                         with: .color(color.opacity(0.6)))
            } else {
                // Lissajous-Kreuzungskurven — geladen, dynamisch
                let steps = 600
                let freqRatio = 1.0 + intensity * 1.5
                let gold = color
                let cyan = Color(hex: "#00D2FF")

                // Kurve A (Gold)
                var pathA = Path()
                for s in 0...steps {
                    let t = Double(s) / Double(steps) * .pi * 2
                    let x = cx + cos(t) * r
                    let y = cy + sin(t * freqRatio) * r * 0.8
                    if s == 0 { pathA.move(to: CGPoint(x: x, y: y)) }
                    else { pathA.addLine(to: CGPoint(x: x, y: y)) }
                }
                ctx.stroke(pathA, with: .color(gold.opacity(0.5 + intensity * 0.3)), lineWidth: 0.8)

                // Kurve B (Cyan)
                var pathB = Path()
                for s in 0...steps {
                    let t = Double(s) / Double(steps) * .pi * 2
                    let x = cx + cos(t + .pi * 0.3) * r
                    let y = cy + sin(t * freqRatio + .pi * 0.5) * r * 0.8
                    if s == 0 { pathB.move(to: CGPoint(x: x, y: y)) }
                    else { pathB.addLine(to: CGPoint(x: x, y: y)) }
                }
                ctx.stroke(pathB, with: .color(cyan.opacity(0.3 + intensity * 0.2)), lineWidth: 0.8)

                // Kreuzungspunkt-Glow
                let glowR = 10.0 + intensity * 8.0
                let glowRect = CGRect(x: cx - glowR, y: cy - glowR, width: glowR * 2, height: glowR * 2)
                ctx.fill(Path(ellipseIn: glowRect), with: .color(gold.opacity(0.3 + intensity * 0.2)))
                let innerR = glowR * 0.3
                ctx.fill(Path(ellipseIn: CGRect(x: cx - innerR, y: cy - innerR, width: innerR * 2, height: innerR * 2)),
                         with: .color(gold.opacity(0.6)))
            }
        }
        .clipShape(Circle())
        .background(
            Circle()
                .fill(Color(hex: "#050308"))
        )
    }
}

// MARK: - Daily Insight Card (bestehendes Interpretationsfeld — jetzt sekundär)

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
        (.agents,  "Levi & Eve",     "KI-Begleiter",         "person.2.fill"),
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

// MARK: - Agents Teaser (Levi + Eve)

private struct AgentsTeaser: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation { store.selectedTab = .agents }
        } label: {
            HStack(spacing: 16) {
                // Dual agent avatars
                ZStack {
                    // Levi
                    Circle()
                        .fill(Color(hex: "#0A1628").opacity(0.8))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "waveform.circle.fill")
                                .font(.system(size: 16, weight: .thin))
                                .foregroundStyle(Color(hex: "#D4AF37").opacity(0.8))
                        )
                        .offset(x: -10)

                    // Eve
                    Circle()
                        .fill(Color(hex: "#1A0A2E").opacity(0.8))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .thin))
                                .foregroundStyle(Color(hex: "#A78BFA").opacity(0.8))
                        )
                        .offset(x: 10)
                }
                .frame(width: 56, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Levi & Eve")
                        .font(CosmicFont.heading(15, weight: .light))
                        .foregroundStyle(theme.textPrimary)
                    Text(store.language == .german
                         ? "Deine KI-Begleiter · Jetzt verbinden"
                         : "Your AI companions · Connect now")
                        .goldLabel(0.45)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .thin))
                    .foregroundStyle(theme.textTertiary)
            }
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#D4AF37").opacity(0.06),
                                     Color(hex: "#A78BFA").opacity(0.06),
                                     theme.surface.opacity(0.4)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(theme.goldBorder, lineWidth: 0.75)
            }
        }
        .buttonStyle(.plain)
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
