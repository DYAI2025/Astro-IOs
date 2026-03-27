// WesternChartView.swift
// Bazodiac iOS — Western Birth Chart (Natal Chart / Orrery)
//
// Full zodiac wheel drawn with Canvas:
//   - 12 zodiac sectors with element colors
//   - 12 house divisions
//   - Planet glyphs at their ecliptic degrees
//   - Planet detail cards below
//
// Pure SwiftUI Canvas — no UIKit, no SpriteKit.

import SwiftUI
import UIKit

struct WesternChartView: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme
    @State private var selectedPlanet: PlanetPosition? = nil

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            StarfieldView(starCount: 50).ignoresSafeArea().opacity(0.4)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Navigation header
                    screenHeader

                    // Zodiac wheel
                    if let data = store.profile?.westernData {
                        ZodiacWheelView(data: data, selectedPlanet: $selectedPlanet)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 20)

                        // Big Three summary
                        BigThreeRow(data: data)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)

                        GoldLine()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)

                        // Planet list
                        PlanetList(data: data, selectedPlanet: $selectedPlanet)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                    }
                }
            }
        }
        .sheet(item: $selectedPlanet) { planet in
            PlanetDetailSheet(position: planet)
                .presentationDetents([.fraction(0.42)])
                .presentationBackground(theme.surfaceElevated)
        }
    }

    private var screenHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Geburts-Chart")
                    .font(CosmicFont.display(26))
                    .foregroundStyle(theme.textPrimary)
                Text("Western Astrologie · Natal Chart")
                    .goldLabel(0.4)
            }
            Spacer()
            Image(systemName: "scope")
                .font(.system(size: 22, weight: .thin))
                .foregroundStyle(Color.cosmicGold.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 12)
    }
}

// MARK: - Zodiac Wheel Canvas

private struct ZodiacWheelView: View {
    @Environment(\.cosmicTheme) private var theme
    let data: WesternData
    @Binding var selectedPlanet: PlanetPosition?

    // Wheel geometry constants
    private let outerRatio:   CGFloat = 0.95
    private let zodiacOuter:  CGFloat = 0.95
    private let zodiacInner:  CGFloat = 0.78
    private let houseOuter:   CGFloat = 0.76
    private let houseInner:   CGFloat = 0.62
    private let planetRadius: CGFloat = 0.70

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cx   = geo.size.width  / 2
            let cy   = geo.size.height / 2

            ZStack {
                // Main chart canvas
                Canvas { context, canvasSize in
                    drawChart(context: context, cx: cx, cy: cy, r: size / 2)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .allowsHitTesting(false)

                // Planet tap targets (overlay transparent buttons)
                ForEach(data.planets) { planet in
                    let pos = planetScreenPos(planet: planet, cx: cx, cy: cy, r: size / 2)
                    Button {
                        let sel = UISelectionFeedbackGenerator()
                        sel.selectionChanged()
                        selectedPlanet = planet
                    } label: {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 32, height: 32)
                    }
                    .offset(x: pos.x - cx, y: pos.y - cy)
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(planet.planet.germanName) in \(planet.sign.germanName), Haus \(planet.house)")
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Geburts-Chart — Zodiak-Rad mit Planetenpositionen")
    }

    // MARK: Canvas Drawing

    private func drawChart(context: GraphicsContext, cx: CGFloat, cy: CGFloat, r: CGFloat) {
        let oR = r * zodiacOuter
        let iR = r * zodiacInner
        let hO = r * houseOuter
        let hI = r * houseInner

        // ── Zodiac sectors (12 × 30°) ─────────────────────────────────────
        for (i, sign) in ZodiacSign.allCases.enumerated() {
            let startDeg = Double(i) * 30.0 - 90.0   // top-center = 0° Aries
            let endDeg   = startDeg + 30.0

            var path = Path()
            path.addArc(center: CGPoint(x: cx, y: cy), radius: oR,
                        startAngle: .degrees(startDeg), endAngle: .degrees(endDeg),
                        clockwise: false)
            path.addArc(center: CGPoint(x: cx, y: cy), radius: iR,
                        startAngle: .degrees(endDeg), endAngle: .degrees(startDeg),
                        clockwise: true)
            path.closeSubpath()

            context.fill(path, with: .color(sign.element.color.opacity(0.08)))

            // Division lines
            let tickStart = pointOnCircle(cx: cx, cy: cy, r: iR, deg: startDeg)
            let tickEnd   = pointOnCircle(cx: cx, cy: cy, r: oR, deg: startDeg)
            var tick = Path()
            tick.move(to: tickStart)
            tick.addLine(to: tickEnd)
            context.stroke(tick,
                           with: .color(Color.cosmicGold.opacity(0.2)),
                           lineWidth: 0.5)

            // Sign glyph
            let glyphDeg = startDeg + 15
            let glyphR   = (oR + iR) / 2
            let glyphPt  = pointOnCircle(cx: cx, cy: cy, r: glyphR, deg: glyphDeg)
            var glyphText = context.resolve(
                Text(sign.canvasLabel)
                    .font(.system(size: r * 0.055, weight: .medium).monospacedDigit())
            )
            glyphText.shading = .color(sign.element.color.opacity(0.85))
            context.draw(glyphText, at: glyphPt, anchor: .center)
        }

        // ── Outer ring ─────────────────────────────────────────────────────
        context.stroke(
            Path(ellipseIn: CGRect(x: cx - oR, y: cy - oR, width: oR * 2, height: oR * 2)),
            with: .color(Color.cosmicGold.opacity(0.3)),
            lineWidth: 1
        )

        // ── Inner zodiac ring ──────────────────────────────────────────────
        context.stroke(
            Path(ellipseIn: CGRect(x: cx - iR, y: cy - iR, width: iR * 2, height: iR * 2)),
            with: .color(Color.cosmicGold.opacity(0.15)),
            lineWidth: 0.5
        )

        // ── House divisions ────────────────────────────────────────────────
        for (i, houseStart) in data.houseStarts.enumerated() {
            let deg  = houseStart - 90.0
            let from = pointOnCircle(cx: cx, cy: cy, r: hI, deg: deg)
            let to   = pointOnCircle(cx: cx, cy: cy, r: hO, deg: deg)

            var line = Path()
            line.move(to: from)
            line.addLine(to: to)

            let isAxis = i == 0 || i == 3 || i == 6 || i == 9
            context.stroke(line,
                           with: .color(Color.cosmicGold.opacity(isAxis ? 0.45 : 0.18)),
                           lineWidth: isAxis ? 0.75 : 0.4)

            // House number
            let midR = (hI + hO) / 2
            let midDeg = deg + ((data.houseStarts[(i + 1) % 12] - houseStart) / 2.0)
            let numPt = pointOnCircle(cx: cx, cy: cy, r: midR * 0.93, deg: midDeg)
            var numText = context.resolve(
                Text("\(i + 1)")
                    .font(.system(size: r * 0.04, weight: .thin))
            )
            numText.shading = .color(Color.cosmicGold.opacity(0.3))
            context.draw(numText, at: numPt, anchor: .center)
        }

        // ── House ring arcs ─────────────────────────────────────────────────
        context.stroke(
            Path(ellipseIn: CGRect(x: cx - hO, y: cy - hO, width: hO * 2, height: hO * 2)),
            with: .color(Color.cosmicGold.opacity(0.12)),
            lineWidth: 0.4
        )
        context.stroke(
            Path(ellipseIn: CGRect(x: cx - hI, y: cy - hI, width: hI * 2, height: hI * 2)),
            with: .color(Color.cosmicGold.opacity(0.1)),
            lineWidth: 0.4
        )

        // ── Center circle ─────────────────────────────────────────────────
        let centerR = r * 0.12
        context.fill(
            Path(ellipseIn: CGRect(x: cx - centerR, y: cy - centerR,
                                   width: centerR * 2, height: centerR * 2)),
            with: .color(Color.cosmicGold.opacity(0.04))
        )
        context.stroke(
            Path(ellipseIn: CGRect(x: cx - centerR, y: cy - centerR,
                                   width: centerR * 2, height: centerR * 2)),
            with: .color(Color.cosmicGold.opacity(0.2)),
            lineWidth: 0.5
        )

        // ── Planets ─────────────────────────────────────────────────────────
        for planet in data.planets {
            let pos = planetScreenPos(planet: planet, cx: cx, cy: cy, r: r)
            let planetR = r * 0.032

            // Glow
            let glowRect = CGRect(x: pos.x - planetR * 2.5, y: pos.y - planetR * 2.5,
                                  width: planetR * 5, height: planetR * 5)
            context.fill(Path(ellipseIn: glowRect),
                         with: .color(planet.planet.color.opacity(0.15)))

            // Circle
            let circleRect = CGRect(x: pos.x - planetR, y: pos.y - planetR,
                                    width: planetR * 2, height: planetR * 2)
            context.fill(Path(ellipseIn: circleRect),
                         with: .color(planet.planet.color.opacity(0.85)))

            // Glyph
            var glyphText = context.resolve(
                Text(planet.planet.glyph)
                    .font(.system(size: r * 0.042))
            )
            glyphText.shading = .color(planet.planet.color)
            context.draw(glyphText, at: CGPoint(x: pos.x, y: pos.y - planetR * 2.8), anchor: .center)
        }
    }

    // MARK: Geometry Helpers

    private func pointOnCircle(cx: CGFloat, cy: CGFloat, r: CGFloat, deg: Double) -> CGPoint {
        let rad = deg * .pi / 180
        return CGPoint(x: cx + CGFloat(cos(rad)) * r, y: cy + CGFloat(sin(rad)) * r)
    }

    private func planetScreenPos(planet: PlanetPosition, cx: CGFloat, cy: CGFloat, r: CGFloat) -> CGPoint {
        // Ascendant on the left (9 o'clock = 180° in screen coords)
        let ascDeg  = data.houseStarts[0]
        let ecl     = planet.degree
        let screen  = (ecl - ascDeg - 90.0)
        let pr      = r * planetRadius
        return pointOnCircle(cx: cx, cy: cy, r: pr, deg: screen)
    }
}

// MARK: - Big Three Row

private struct BigThreeRow: View {
    @Environment(\.cosmicTheme) private var theme
    let data: WesternData

    var body: some View {
        HStack(spacing: 0) {
            BigThreeCell(title: "☉ Sonne",      sign: data.sunSign,    deg: data.sunDegree)
            Divider()
                .frame(width: 0.5).background(Color.cosmicGold.opacity(0.12))
            BigThreeCell(title: "☽ Mond",        sign: data.moonSign,   deg: data.moonDegree)
            Divider()
                .frame(width: 0.5).background(Color.cosmicGold.opacity(0.12))
            BigThreeCell(title: "↑ Aszendent",   sign: data.ascendant,  deg: data.ascendantDegree)
        }
        .cosmicCard()
    }
}

private struct BigThreeCell: View {
    @Environment(\.cosmicTheme) private var theme
    let title: String
    let sign:  ZodiacSign
    let deg:   Double

    var body: some View {
        VStack(spacing: 6) {
            Text(title).goldLabel(0.4)
            // Sign badge — element-colored circle with 2-letter code
            ZStack {
                Circle()
                    .fill(sign.element.color.opacity(0.18))
                    .frame(width: 40, height: 40)
                Circle()
                    .strokeBorder(sign.element.color.opacity(0.45), lineWidth: 0.75)
                    .frame(width: 40, height: 40)
                Text(sign.canvasLabel)
                    .font(.system(size: 10, weight: .medium).monospacedDigit())
                    .foregroundStyle(sign.element.color.opacity(0.9))
            }
            Text(sign.germanName)
                .font(CosmicFont.heading(12, weight: .light))
                .foregroundStyle(Color.cosmicGold.opacity(0.8))
            Text(String(format: "%.1f°", deg))
                .font(CosmicFont.mono(10))
                .foregroundStyle(theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
}

// MARK: - Planet List

private struct PlanetList: View {
    @Environment(\.cosmicTheme) private var theme
    let data: WesternData
    @Binding var selectedPlanet: PlanetPosition?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Planeten-Positionen")
                    .goldLabel(0.5)
                Spacer()
            }
            .padding(.bottom, 12)

            VStack(spacing: 0) {
                ForEach(data.planets) { planet in
                    PlanetRow(position: planet) {
                        selectedPlanet = planet
                    }
                    if planet.planet != data.planets.last?.planet {
                        GoldLine().padding(.horizontal, 12)
                    }
                }
            }
            .cosmicCard()
        }
    }
}

private struct PlanetRow: View {
    @Environment(\.cosmicTheme) private var theme
    let position: PlanetPosition
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Planet icon (SF Symbol — SF font can't render classic astrological glyphs)
                Image(systemName: position.planet.sfSymbol)
                    .font(.system(size: 16, weight: .thin))
                    .foregroundStyle(position.planet.color)
                    .frame(width: 28)

                // Name
                Text(position.planet.germanName)
                    .font(CosmicFont.heading(14, weight: .light))
                    .foregroundStyle(theme.textPrimary.opacity(0.85))

                Spacer()

                // Sign + degree
                HStack(spacing: 6) {
                    Text(position.sign.canvasLabel)
                        .font(.system(size: 10, weight: .medium).monospacedDigit())
                        .foregroundStyle(position.sign.element.color.opacity(0.85))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(position.sign.element.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 3))
                    Text(position.sign.germanName)
                        .font(CosmicFont.heading(13, weight: .light))
                        .foregroundStyle(theme.textSecondary)
                    Text(String(format: "%.0f°", position.degree.truncatingRemainder(dividingBy: 30)))
                        .font(CosmicFont.mono(11))
                        .foregroundStyle(theme.textTertiary)
                    if position.isRetrograde {
                        Text("℞")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.elementFire.opacity(0.6))
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .thin))
                    .foregroundStyle(Color.cosmicGold.opacity(0.2))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Planet Detail Sheet

private struct PlanetDetailSheet: View {
    @Environment(\.cosmicTheme) private var theme
    let position: PlanetPosition
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.cosmicGold.opacity(0.25))
                .frame(width: 36, height: 3)
                .padding(.top, 12)
                .padding(.bottom, 24)

            VStack(spacing: 16) {
                // Planet badge
                ZStack {
                    Circle()
                        .fill(position.planet.color.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Circle()
                        .strokeBorder(position.planet.color.opacity(0.35), lineWidth: 1)
                        .frame(width: 72, height: 72)
                    Image(systemName: position.planet.sfSymbol)
                        .font(.system(size: 28, weight: .thin))
                        .foregroundStyle(position.planet.color)
                }

                VStack(spacing: 4) {
                    Text(position.planet.germanName)
                        .font(CosmicFont.display(24))
                        .foregroundStyle(theme.textPrimary)

                    HStack(spacing: 8) {
                        Text(position.sign.canvasLabel)
                            .font(.system(size: 11, weight: .medium).monospacedDigit())
                            .foregroundStyle(position.sign.element.color)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(position.sign.element.color.opacity(0.12),
                                        in: RoundedRectangle(cornerRadius: 3))
                        Text(position.sign.germanName)
                            .font(CosmicFont.heading(14, weight: .light))
                            .foregroundStyle(theme.textSecondary)
                        Text("· Haus \(position.house)")
                            .goldLabel(0.5)
                    }

                    Text(String(format: "%.2f° Ekliptik", position.degree))
                        .font(CosmicFont.mono(12))
                        .foregroundStyle(theme.textTertiary)
                }

                if position.isRetrograde {
                    Label("Rückläufig", systemImage: "arrow.counterclockwise")
                        .font(CosmicFont.label(9))
                        .tracking(2)
                        .foregroundStyle(Color.elementFire.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.elementFire.opacity(0.1), in: Capsule())
                }
            }

            Spacer()

            Button("Schließen") { dismiss() }
                .font(CosmicFont.label(9))
                .tracking(3)
                .foregroundStyle(Color.cosmicGold.opacity(0.5))
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .background(theme.surfaceElevated)
    }
}

// MARK: - Preview

#Preview {
    WesternChartView()
        .environment({
            let s = CosmicStore()
            s.profile = .mock
            return s
        }())
}
