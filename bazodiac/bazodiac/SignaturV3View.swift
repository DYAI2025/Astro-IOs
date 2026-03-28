// SignaturV3View.swift
// Bazodiac iOS — Bipolar Trail Canvas (Signatur V3)
//
// Rendert 12 Pole (6 bipolare Dimensionspaare) als animierte Trails.
// Die akkumulierten Spuren SIND die Signatur.
// Trails überlappen → Form verdichtet sich → einzigartiger visueller Fingerprint.

import SwiftUI

struct SignaturV3View: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    @State private var engine = BipolarEngine()
    @State private var harmonic: DayHarmonicState = .neutral
    @State private var kpIndex: Double = 0
    @State private var initialized = false

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                screenHeader
                    .padding(.top, 60)
                    .padding(.bottom, 12)

                // Mode badge
                HStack(spacing: 8) {
                    Circle()
                        .fill(harmonic.mode == .trace ? Color(hex: "#D4AF37") : Color(hex: "#A0B4CC"))
                        .frame(width: 8, height: 8)
                    Text(harmonic.mode == .trace ? "TRACE" : "PULSE")
                        .font(CosmicFont.label(9))
                        .tracking(4)
                        .foregroundStyle(harmonic.mode == .trace
                            ? Color(hex: "#D4AF37").opacity(0.7)
                            : Color(hex: "#A0B4CC").opacity(0.7))
                }
                .padding(.bottom, 16)

                // Canvas
                GeometryReader { geo in
                    let size = min(geo.size.width, geo.size.height) - 40
                    TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                        Canvas { ctx, canvasSize in
                            let cx = canvasSize.width / 2
                            let cy = canvasSize.height / 2

                            // Background circle
                            let bgR = size / 2
                            ctx.fill(
                                Path(ellipseIn: CGRect(x: cx - bgR, y: cy - bgR, width: bgR * 2, height: bgR * 2)),
                                with: .color(theme.isDark ? Color(hex: "#050308") : Color(hex: "#F5F0E8"))
                            )
                            ctx.stroke(
                                Path(ellipseIn: CGRect(x: cx - bgR, y: cy - bgR, width: bgR * 2, height: bgR * 2)),
                                with: .color(theme.gold.opacity(0.15)), lineWidth: 0.5
                            )

                            // Tick engine
                            engine.tick(dayHarmonic: harmonic, kpIndex: kpIndex)

                            // Render trails
                            for pole in engine.poles {
                                guard pole.trail.count >= 2 else { continue }
                                let dimIdx = bipolarDimensions.firstIndex(where: { $0.id == pole.dimensionId }) ?? 0
                                let _ = bipolarDimensions[dimIdx]

                                let r = CGFloat(pole.color.r)
                                let g = CGFloat(pole.color.g)
                                let b = CGFloat(pole.color.b)

                                // Trail line
                                var path = Path()
                                for (j, pt) in pole.trail.enumerated() {
                                    let px = cx + CGFloat(pt.x)
                                    let py = cy + CGFloat(pt.y)
                                    if j == 0 { path.move(to: CGPoint(x: px, y: py)) }
                                    else { path.addLine(to: CGPoint(x: px, y: py)) }
                                }

                                let freshness = 0.15 + Double(pole.trail.count) / Double(pole.maxTrailLength) * 0.4
                                ctx.stroke(path,
                                    with: .color(Color(red: Double(r), green: Double(g), blue: Double(b)).opacity(freshness)),
                                    lineWidth: 0.8
                                )

                                // Current position dot
                                let dotR: CGFloat = 3
                                let dotX = cx + CGFloat(pole.x)
                                let dotY = cy + CGFloat(pole.y)
                                ctx.fill(
                                    Path(ellipseIn: CGRect(x: dotX - dotR, y: dotY - dotR, width: dotR * 2, height: dotR * 2)),
                                    with: .color(Color(red: Double(r), green: Double(g), blue: Double(b)).opacity(0.8))
                                )

                                // Glow
                                let glowR: CGFloat = 8
                                ctx.fill(
                                    Path(ellipseIn: CGRect(x: dotX - glowR, y: dotY - glowR, width: glowR * 2, height: glowR * 2)),
                                    with: .color(Color(red: Double(r), green: Double(g), blue: Double(b)).opacity(0.15))
                                )
                            }
                        }
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 340)
                .padding(.horizontal, 20)

                // Dimension legend
                dimensionLegend
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                Spacer()
            }
            .padding(.bottom, 120)
        }
        .onAppear { setup() }
    }

    // MARK: - Header

    private var screenHeader: some View {
        VStack(spacing: 6) {
            Text(store.language == .german ? "Deine Signatur" : "Your Signature")
                .font(CosmicFont.display(26))
                .foregroundStyle(theme.textPrimary)
            Text(store.language == .german
                 ? "Bipolare Spur-Signatur · Lebt und atmet"
                 : "Bipolar trail signature · Living and breathing")
                .goldLabel(0.4)
                .tracking(3)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Dimension Legend

    private var dimensionLegend: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
        ], spacing: 10) {
            ForEach(bipolarDimensions, id: \.id) { dim in
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(red: Double(dim.colorA.r), green: Double(dim.colorA.g), blue: Double(dim.colorA.b)))
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(Color(red: Double(dim.colorB.r), green: Double(dim.colorB.g), blue: Double(dim.colorB.b)))
                            .frame(width: 6, height: 6)
                    }
                    Text(dim.poleA)
                        .font(CosmicFont.label(7))
                        .tracking(1)
                        .foregroundStyle(theme.textTertiary)
                    Text("·")
                        .font(CosmicFont.label(6))
                        .foregroundStyle(theme.textTertiary.opacity(0.3))
                    Text(dim.poleB)
                        .font(CosmicFont.label(7))
                        .tracking(1)
                        .foregroundStyle(theme.textTertiary)
                }
            }
        }
        .padding(16)
        .cosmicCard(cornerRadius: 14)
    }

    // MARK: - Setup

    private func setup() {
        guard let profile = store.profile, !initialized else { return }
        initialized = true

        let natalWeights = NatalWeightMapper.fromProfile(profile)
        engine.config.maxR = 130
        engine.config.maxTrailLength = 600
        engine.initialize(natalWeights: natalWeights)

        harmonic = DayHarmonicEngine.fromProfile(profile)

        // Modulate config based on day harmonic
        if harmonic.mode == .pulse {
            engine.config.trailPersistence = min(0.99, engine.config.trailPersistence + harmonic.intensity * 0.12)
        } else {
            engine.config.trailPersistence = max(0.6, engine.config.trailPersistence - harmonic.intensity * 0.06)
        }

        // Load cosmic weather
        Task {
            let weather = await CosmicWeatherService.shared.fetch()
            kpIndex = weather.kpIndex
        }
    }
}

// MARK: - Preview

#Preview {
    SignaturV3View()
        .environment({
            let s = CosmicStore()
            s.profile = .mock
            return s
        }())
}
