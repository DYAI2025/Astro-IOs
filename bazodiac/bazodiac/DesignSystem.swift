// DesignSystem.swift
// Bazodiac iOS — Design Tokens, Typography, Modifiers, Reusable Components
//
// Two themes:
//   DARK  — Obsidian #00050A + Gold #D4AF37  (deep space luxury)
//   LIGHT — Ivory  #F8F3E8 + Gold #9A7B2F    (bright astro luxury, parchment feel)
//
// Font: Cormorant Garamond (bundled) for all display/heading/serif text.

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

// MARK: - Theme Definition

enum CosmicTheme: String, CaseIterable {
    case dark  = "dark"
    case light = "light"

    // ── Backgrounds ────────────────────────────────────────────────────────────
    /// Primary app background
    var background: Color {
        switch self {
        case .dark:  return Color(hex: "#00050A")   // deep space black
        case .light: return Color(hex: "#F8F3E8")   // warm ivory / parchment
        }
    }
    /// Card / surface background
    var surface: Color {
        switch self {
        case .dark:  return Color(hex: "#1A1C1E")
        case .light: return Color(hex: "#FFFFFF")
        }
    }
    /// Secondary surface (elevated cards, sheets)
    var surfaceElevated: Color {
        switch self {
        case .dark:  return Color(hex: "#22252A")
        case .light: return Color(hex: "#FDF9F1")
        }
    }

    // ── Primary accent (Gold) ──────────────────────────────────────────────────
    var gold: Color {
        switch self {
        case .dark:  return Color(hex: "#D4AF37")   // bright gold on dark
        case .light: return Color(hex: "#9A7B2F")   // deep antique gold on light
        }
    }
    var goldSubtle: Color {
        switch self {
        case .dark:  return Color(hex: "#D4AF37").opacity(0.55)
        case .light: return Color(hex: "#9A7B2F").opacity(0.70)
        }
    }
    var goldBorder: Color {
        switch self {
        case .dark:  return Color(hex: "#D4AF37").opacity(0.14)
        case .light: return Color(hex: "#9A7B2F").opacity(0.22)
        }
    }
    var goldFaint: Color {
        switch self {
        case .dark:  return Color(hex: "#D4AF37").opacity(0.06)
        case .light: return Color(hex: "#9A7B2F").opacity(0.08)
        }
    }

    // ── Text ───────────────────────────────────────────────────────────────────
    var textPrimary: Color {
        switch self {
        case .dark:  return Color(hex: "#D4AF37").opacity(0.95)
        case .light: return Color(hex: "#2C1E0F")   // dark warm brown
        }
    }
    var textSecondary: Color {
        switch self {
        case .dark:  return Color(hex: "#D4AF37").opacity(0.60)
        case .light: return Color(hex: "#5C4A2A").opacity(0.80)
        }
    }
    var textTertiary: Color {
        switch self {
        case .dark:  return Color(hex: "#D4AF37").opacity(0.30)
        case .light: return Color(hex: "#8B6914").opacity(0.55)
        }
    }
    var textLabel: Color {        // goldLabel-equivalent
        switch self {
        case .dark:  return Color(hex: "#D4AF37").opacity(0.55)
        case .light: return Color(hex: "#9A7B2F").opacity(0.70)
        }
    }

    // ── Dividers ───────────────────────────────────────────────────────────────
    var dividerColors: [Color] {
        switch self {
        case .dark:  return [.clear, Color(hex: "#D4AF37").opacity(0.3), .clear]
        case .light: return [.clear, Color(hex: "#9A7B2F").opacity(0.35), .clear]
        }
    }

    // ── Star / ambient ─────────────────────────────────────────────────────────
    var starColor: Color {
        switch self {
        case .dark:  return Color(hex: "#D4AF37")
        case .light: return Color(hex: "#9A7B2F")
        }
    }
    var ambientGlow: Color {
        switch self {
        case .dark:  return Color(hex: "#D4AF37").opacity(0.06)
        case .light: return Color(hex: "#C8A84B").opacity(0.10)
        }
    }

    // ── Card style ─────────────────────────────────────────────────────────────
    var cardBackground: Color {
        switch self {
        case .dark:  return Color(hex: "#1A1C1E").opacity(0.85)
        case .light: return Color(hex: "#FFFFFF").opacity(0.90)
        }
    }

    // ── Tab bar ────────────────────────────────────────────────────────────────
    var tabBarBackground: Color {
        switch self {
        case .dark:  return Color(hex: "#0D0F11").opacity(0.92)
        case .light: return Color(hex: "#FDFAF3").opacity(0.95)
        }
    }

    // ── Convenience ────────────────────────────────────────────────────────────
    var isDark: Bool { self == .dark }

    var toggleIcon: String {
        switch self {
        case .dark:  return "sun.max.fill"
        case .light: return "moon.stars.fill"
        }
    }
    var next: CosmicTheme {
        switch self {
        case .dark:  return .light
        case .light: return .dark
        }
    }
}

// MARK: - Static Color Aliases (dark-mode static — kept for Canvas code)

extension Color {
    // Dark palette constants (Canvas drawing, Wu-Xing, Zodiac)
    static let obsidian     = Color(hex: "#00050A")
    static let cosmicGold   = Color(hex: "#D4AF37")
    static let goldDeep     = Color(hex: "#8B6914")
    static let cosmicAsh    = Color(hex: "#1A1C1E")
    static let cosmicInk    = Color(hex: "#1E2A3A")

    // Five Elements — Wu-Xing (unchanged, vibrant)
    static let elementWood  = Color(hex: "#52A853")
    static let elementFire  = Color(hex: "#EA4335")
    static let elementEarth = Color(hex: "#FBBC05")
    static let elementMetal = Color(hex: "#C8D4E4")
    static let elementWater = Color(hex: "#4285F4")

    // Western zodiac element tints
    static let zodiacFire   = Color(hex: "#FF6B4A")
    static let zodiacEarth  = Color(hex: "#C49A3C")
    static let zodiacAir    = Color(hex: "#7EC8E3")
    static let zodiacWater  = Color(hex: "#5B9BD5")

    // Utility (dark-mode defaults)
    static let goldFaint    = Color(hex: "#D4AF37").opacity(0.06)
    static let goldBorder   = Color(hex: "#D4AF37").opacity(0.14)
    static let goldMid      = Color(hex: "#D4AF37").opacity(0.45)
}

// MARK: - Typography — Cormorant Garamond

enum CosmicFont {

    // ── Cormorant Garamond font names ──────────────────────────────────────────
    private static let cgLight      = "CormorantGaramond-Light"
    private static let cgRegular    = "CormorantGaramond-Regular"
    private static let cgMedium     = "CormorantGaramond-Medium"
    private static let cgSemiBold   = "CormorantGaramond-SemiBold"
    private static let cgBold       = "CormorantGaramond-Bold"
    private static let cgItalic     = "CormorantGaramond-Italic"
    private static let cgLightItalic = "CormorantGaramond-LightItalic"

    /// Verify font is available, fallback to system serif
    private static func cg(_ name: String, size: CGFloat) -> Font {
        // Try custom font; if not loaded yet, fallback gracefully
        let font = UIFont(name: name, size: size)
        if font != nil {
            return Font.custom(name, size: size)
        }
        // Fallback: system serif
        return .system(size: size, weight: .ultraLight, design: .serif)
    }

    // ── Display — large cinematic titles (Splash, Home header) ────────────────
    static func display(_ size: CGFloat) -> Font {
        cg(cgLight, size: size)
    }

    // ── Heading — section titles, card headers ─────────────────────────────────
    static func heading(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold, .heavy, .black:
            return cg(cgBold, size: size)
        case .semibold:
            return cg(cgSemiBold, size: size)
        case .medium:
            return cg(cgMedium, size: size)
        case .thin, .ultraLight:
            return cg(cgLight, size: size)
        default:
            return cg(cgRegular, size: size)
        }
    }

    // ── Body serif — interpretation text, quotes ───────────────────────────────
    static func bodySerif(_ size: CGFloat) -> Font {
        cg(cgLight, size: size)
    }

    // ── Body serif italic ──────────────────────────────────────────────────────
    static func bodySerifItalic(_ size: CGFloat) -> Font {
        cg(cgLightItalic, size: size)
    }

    // ── Label — uppercase tracked small caps ───────────────────────────────────
    static func label(_ size: CGFloat = 10) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }

    // ── Mono — degrees, coordinates ───────────────────────────────────────────
    static func mono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .light, design: .monospaced)
    }

    // ── Chinese glyphs ────────────────────────────────────────────────────────
    static func chinese(_ size: CGFloat, weight: Font.Weight = .ultraLight) -> Font {
        .system(size: size, weight: weight)
    }
}

// MARK: - Theme Environment Key

struct CosmicThemeKey: EnvironmentKey {
    static let defaultValue: CosmicTheme = .dark
}

extension EnvironmentValues {
    var cosmicTheme: CosmicTheme {
        get { self[CosmicThemeKey.self] }
        set { self[CosmicThemeKey.self] = newValue }
    }
}

// MARK: - View Modifiers

/// Gold uppercase tracking label — theme-aware
struct GoldLabelStyle: ViewModifier {
    var opacity: Double = 0.55
    @Environment(\.cosmicTheme) private var theme

    func body(content: Content) -> some View {
        content
            .font(CosmicFont.label(9))
            .tracking(5)
            .textCase(.uppercase)
            .foregroundStyle(theme.textLabel.opacity(opacity / 0.55))
    }
}

/// Dark/light cosmic card with gold hairline border
struct CosmicCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 16
    @Environment(\.cosmicTheme) private var theme

    func body(content: Content) -> some View {
        content
            .background(theme.cardBackground)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(theme.goldBorder, lineWidth: 0.75)
            )
    }
}

/// Glass card — Liquid Glass on iOS 26+, theme-aware material fallback
struct GlassCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 16
    @Environment(\.cosmicTheme) private var theme

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(theme.goldBorder, lineWidth: 0.5)
                )
        }
    }
}

/// Glowing gold separator
struct GoldDividerStyle: ViewModifier {
    @Environment(\.cosmicTheme) private var theme

    func body(content: Content) -> some View {
        content
            .frame(height: 0.5)
            .background(
                LinearGradient(
                    colors: theme.dividerColors,
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

                    if star.radius > 1.5 {
                        let haloRect = rect.insetBy(dx: -star.radius * 1.5, dy: -star.radius * 1.5)
                        context.fill(Path(ellipseIn: haloRect), with: .color(tint.opacity(alpha * 0.15)))
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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

                    context.stroke(
                        Path(ellipseIn: ringRect),
                        with: .color(Color.cosmicGold.opacity(ringAlpha)),
                        lineWidth: 0.5
                    )

                    let orbit = orbitData[i]
                    let angle = t * orbit.speed + orbit.phaseOffset
                    let px = cx + radius * cos(angle)
                    let py = cy + radius * sin(angle) * 0.35
                    let dotR = orbit.dotSize / 2
                    let dotRect = CGRect(x: px - dotR, y: py - dotR,
                                        width: dotR * 2, height: dotR * 2)

                    let dotAlpha = (ringAlpha + 0.35).clamped(to: 0.0...1.0)
                    context.fill(Path(ellipseIn: dotRect),
                                 with: .color(Color.cosmicGold.opacity(dotAlpha)))

                    let haloRect = dotRect.insetBy(dx: -dotR * 1.5, dy: -dotR * 1.5)
                    context.fill(Path(ellipseIn: haloRect),
                                 with: .color(Color.cosmicGold.opacity(dotAlpha * 0.2)))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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

// MARK: - Reusable: Theme Toggle Button

struct ThemeToggleButton: View {
    @Environment(\.cosmicTheme) private var theme

    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Image(systemName: theme.toggleIcon)
                .font(.system(size: 16, weight: .thin))
                .foregroundStyle(theme.gold.opacity(0.7))
                .frame(width: 36, height: 36)
                .background(theme.goldFaint, in: Circle())
                .overlay(Circle().strokeBorder(theme.goldBorder, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.4, bounce: 0.2), value: theme)
    }
}

// MARK: - Reusable: Light-mode Star Background

/// For light mode: subtle vellum/parchment texture with faint gold dots
struct LightAmbientView: View {
    private struct Speck: Sendable {
        let x, y, r, phase, speed: CGFloat
    }
    private let specks: [Speck]

    init(count: Int = 60) {
        specks = (0..<count).map { _ in
            Speck(x: .random(in: 0...1), y: .random(in: 0...1),
                  r: .random(in: 0.3...1.4),
                  phase: .random(in: 0...(2 * .pi)),
                  speed: .random(in: 0.15...0.5))
        }
    }

    var body: some View {
        TimelineView(.animation) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                for s in specks {
                    let alpha = 0.04 + (sin(t * s.speed + s.phase) + 1) * 0.09
                    let rect = CGRect(x: s.x * size.width - s.r,
                                      y: s.y * size.height - s.r,
                                      width: s.r * 2, height: s.r * 2)
                    ctx.fill(Path(ellipseIn: rect),
                             with: .color(Color(hex: "#9A7B2F").opacity(alpha)))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Helpers

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Previews

#Preview("Dark Theme") {
    ZStack {
        Color.obsidian.ignoresSafeArea()
        StarfieldView(starCount: 120, goldTint: true).ignoresSafeArea()
        VStack(spacing: 20) {
            Text("Bazodiac")
                .font(CosmicFont.display(52))
                .foregroundStyle(Color.cosmicGold)
            Text("Coniunctio Caelorum")
                .font(CosmicFont.bodySerifItalic(14))
                .foregroundStyle(Color.cosmicGold.opacity(0.5))
            Text("DISPLAY FONT")
                .goldLabel()
            Text("Section Heading")
                .font(CosmicFont.heading(22))
                .foregroundStyle(Color.cosmicGold.opacity(0.85))
            Text("Body text interpretation flows here with serif grace.")
                .font(CosmicFont.bodySerif(15))
                .foregroundStyle(Color.cosmicGold.opacity(0.65))
        }
        .padding()
    }
    .environment(\.cosmicTheme, .dark)
}

#Preview("Light Theme") {
    let theme = CosmicTheme.light
    ZStack {
        theme.background.ignoresSafeArea()
        LightAmbientView(count: 60).ignoresSafeArea()
        VStack(spacing: 20) {
            Text("Bazodiac")
                .font(CosmicFont.display(52))
                .foregroundStyle(theme.gold)
            Text("Coniunctio Caelorum")
                .font(CosmicFont.bodySerifItalic(14))
                .foregroundStyle(theme.textSecondary)
            Text("DISPLAY FONT")
                .goldLabel()
            Text("Section Heading")
                .font(CosmicFont.heading(22))
                .foregroundStyle(theme.textPrimary)
            Text("Body text interpretation flows here with serif grace.")
                .font(CosmicFont.bodySerif(15))
                .foregroundStyle(theme.textSecondary)
            Text("Sample card")
                .font(CosmicFont.heading(16))
                .foregroundStyle(theme.textPrimary)
                .padding()
                .cosmicCard()
        }
        .padding()
    }
    .environment(\.cosmicTheme, .light)
}
