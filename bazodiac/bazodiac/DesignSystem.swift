// DesignSystem.swift
// Bazodiac iOS — Design Tokens, Typography, Modifiers, Reusable Components
//
// Color palette mirrors the web app exactly:
//   Obsidian #00050A + Gold #D4AF37 (dark luxury theme)
//   Dawn #E2ECF6 + Ink #1E2A3A (morning/light theme — future)

import SwiftUI

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}

// MARK: - Design Palette

extension Color {
    // Core dark-luxury palette (web variables translated)
    static let obsidian     = Color(hex: "#00050A")   // --color-obsidian
    static let cosmicGold   = Color(hex: "#D4AF37")   // --color-gold
    static let goldDeep     = Color(hex: "#8B6914")   // --color-gold-deep
    static let cosmicAsh    = Color(hex: "#1A1C1E")   // --color-ash
    static let cosmicInk    = Color(hex: "#1E2A3A")   // --color-ink

    // Five Elements — Wu-Xing
    static let elementWood  = Color(hex: "#52A853")   // 木 Holz — Smaragdgrün
    static let elementFire  = Color(hex: "#EA4335")   // 火 Feuer — Rot
    static let elementEarth = Color(hex: "#FBBC05")   // 土 Erde — Ocker
    static let elementMetal = Color(hex: "#C8D4E4")   // 金 Metall — Silber
    static let elementWater = Color(hex: "#4285F4")   // 水 Wasser — Tiefblau

    // Western zodiac element tints
    static let zodiacFire   = Color(hex: "#FF6B4A")
    static let zodiacEarth  = Color(hex: "#C49A3C")
    static let zodiacAir    = Color(hex: "#7EC8E3")
    static let zodiacWater  = Color(hex: "#5B9BD5")

    // Utility
    static let goldFaint    = Color(hex: "#D4AF37").opacity(0.06)
    static let goldBorder   = Color(hex: "#D4AF37").opacity(0.14)
    static let goldMid      = Color(hex: "#D4AF37").opacity(0.45)
}

// MARK: - Typography Scale

enum CosmicFont {
    // Display — like Cormorant Garamond (serif system alternative)
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .ultraLight, design: .serif)
    }
    // Heading — Sora-feel (clean, geometric sans)
    static func heading(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    // Body — serif for interpretive/atmospheric text
    static func bodySerif(_ size: CGFloat) -> Font {
        .system(size: size, weight: .light, design: .serif)
    }
    // Label — tight tracked caps (10px 0.5em tracking in web)
    static func label(_ size: CGFloat = 10) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    // Mono — for degrees, coordinates
    static func mono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .light, design: .monospaced)
    }
    // Chinese glyphs
    static func chinese(_ size: CGFloat, weight: Font.Weight = .ultraLight) -> Font {
        .system(size: size, weight: weight)
    }
}

// MARK: - View Modifiers

/// Small gold uppercase tracking label (web: text-[10px] tracking-[0.5em] uppercase text-gold/60)
struct GoldLabelStyle: ViewModifier {
    var opacity: Double = 0.55
    func body(content: Content) -> some View {
        content
            .font(CosmicFont.label(9))
            .tracking(5)
            .textCase(.uppercase)
            .foregroundStyle(Color.cosmicGold.opacity(opacity))
    }
}

/// Dark obsidian card with gold hairline border
struct CosmicCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .background(Color.cosmicAsh.opacity(0.85))
            .clipShape(.rect(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.goldBorder, lineWidth: 0.75)
            )
    }
}

/// Glass card — Liquid Glass on iOS 26+, material fallback on earlier
struct GlassCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 16
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.goldBorder, lineWidth: 0.5)
                )
        }
    }
}

/// Glowing gold separator line
struct GoldDividerStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 0.5)
            .background(
                LinearGradient(
                    colors: [.clear, Color.cosmicGold.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

// MARK: - View Extensions

extension View {
    func goldLabel(_ opacity: Double = 0.55) -> some View {
        modifier(GoldLabelStyle(opacity: opacity))
    }
    func cosmicCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(CosmicCardStyle(cornerRadius: cornerRadius))
    }
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCardStyle(cornerRadius: cornerRadius))
    }
    func goldDivider() -> some View {
        modifier(GoldDividerStyle())
    }
}

// MARK: - Reusable: Gold Separator

struct GoldLine: View {
    var body: some View {
        Rectangle()
            .goldDivider()
    }
}

// MARK: - Reusable: Starfield Canvas

private struct StarDatum: Sendable {
    let x: CGFloat
    let y: CGFloat
    let radius: CGFloat
    let phase: Double
    let speed: Double
}

struct StarfieldView: View {
    var starCount: Int = 120
    var goldTint: Bool = true

    private let stars: [StarDatum]

    init(starCount: Int = 120, goldTint: Bool = true) {
        self.starCount = starCount
        self.goldTint = goldTint
        self.stars = (0..<starCount).map { _ in
            StarDatum(
                x: .random(in: 0...1),
                y: .random(in: 0...1),
                radius: .random(in: 0.3...2.1),
                phase: .random(in: 0...(2 * .pi)),
                speed: .random(in: 0.25...1.1)
            )
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                for star in stars {
                    let alpha = 0.08 + (sin(t * star.speed + star.phase) + 1) * 0.28
                    let x = star.x * size.width
                    let y = star.y * size.height
                    let rect = CGRect(
                        x: x - star.radius,
                        y: y - star.radius,
                        width: star.radius * 2,
                        height: star.radius * 2
                    )
                    let tint: Color = goldTint ? .cosmicGold : .white
                    context.fill(Path(ellipseIn: rect), with: .color(tint.opacity(alpha)))

                    // Subtle halo on larger stars
                    if star.radius > 1.5 {
                        let haloRect = rect.insetBy(dx: -star.radius * 1.5, dy: -star.radius * 1.5)
                        context.fill(Path(ellipseIn: haloRect), with: .color(tint.opacity(alpha * 0.15)))
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Reusable: Orbital Rings

struct OrbitalRingsView: View {
    var rings: Int = 4
    var baseRadius: CGFloat = 50
    var ringSpacing: CGFloat = 32

    private let orbitData: [(speed: Double, phaseOffset: Double, dotSize: CGFloat)] = [
        (0.9,  0.0,  5),
        (0.55, 1.0,  4),
        (0.30, 2.2,  3.5),
        (0.18, 4.1,  3),
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let cx = size.width  / 2
                let cy = size.height / 2

                for i in 0..<min(rings, orbitData.count) {
                    let radius = baseRadius + CGFloat(i) * ringSpacing
                    let ringAlpha = 0.18 - Double(i) * 0.03
                    let ringRect = CGRect(x: cx - radius, y: cy - radius,
                                         width: radius * 2, height: radius * 2)

                    // Draw orbital ellipse
                    context.stroke(
                        Path(ellipseIn: ringRect),
                        with: .color(Color.cosmicGold.opacity(ringAlpha)),
                        lineWidth: 0.5
                    )

                    // Orbiting planet dot
                    let orbit = orbitData[i]
                    let angle = t * orbit.speed + orbit.phaseOffset
                    let px = cx + radius * cos(angle)
                    let py = cy + radius * sin(angle) * 0.35  // flattened ellipse
                    let dotR = orbit.dotSize / 2
                    let dotRect = CGRect(x: px - dotR, y: py - dotR,
                                        width: dotR * 2, height: dotR * 2)

                    let dotAlpha = (ringAlpha + 0.35).clamped(to: 0.0...1.0)
                    context.fill(Path(ellipseIn: dotRect),
                                 with: .color(Color.cosmicGold.opacity(dotAlpha)))

                    // Planet halo
                    let haloRect = dotRect.insetBy(dx: -dotR * 1.5, dy: -dotR * 1.5)
                    context.fill(Path(ellipseIn: haloRect),
                                 with: .color(Color.cosmicGold.opacity(dotAlpha * 0.2)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Reusable: Element Badge

struct ElementBadge: View {
    let element: CosmicElement
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            Circle()
                .fill(element.color.opacity(0.15))
                .frame(width: size, height: size)
            Circle()
                .strokeBorder(element.color.opacity(0.4), lineWidth: 0.75)
                .frame(width: size, height: size)
            Text(element.chineseChar)
                .font(CosmicFont.chinese(size * 0.42, weight: .light))
                .foregroundStyle(element.color.opacity(0.9))
        }
    }
}

// MARK: - Helpers

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Design System Previews

#Preview("Starfield") {
    StarfieldView(starCount: 120, goldTint: true)
        .frame(width: 390, height: 844)
        .background(Color.obsidian)
}

#Preview("OrbitalRings") {
    OrbitalRingsView(rings: 4, baseRadius: 50, ringSpacing: 32)
        .frame(width: 300, height: 300)
        .background(Color.obsidian)
}

#Preview("ElementBadge") {
    HStack(spacing: 16) {
        ForEach(CosmicElement.allCases) { e in
            ElementBadge(element: e, size: 44)
        }
    }
    .padding(24)
    .background(Color.obsidian)
}

#Preview("GoldCards") {
    VStack(spacing: 16) {
        Text("Cosmic Card")
            .font(CosmicFont.heading(16))
            .foregroundStyle(Color.cosmicGold)
            .padding()
            .cosmicCard()
        Text("Glass Card")
            .font(CosmicFont.heading(16))
            .foregroundStyle(Color.cosmicGold)
            .padding()
            .glassCard()
        Text("GOLD LABEL")
            .goldLabel()
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.obsidian)
}
