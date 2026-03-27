// SplashView.swift
// Bazodiac iOS — Cinematic Splash Screen
//
// Phase sequence: .starfield → .title → .gate → (done)
// Pure SwiftUI animations — no AVFoundation video.
// UIKit used only for haptic feedback.
// The iOS counterpart of the web Splash's animation sequence.

import SwiftUI
import UIKit

// MARK: - Splash Phase

private enum SplashPhase: Int, CaseIterable {
    case blank     = 0
    case starfield = 1
    case title     = 2
    case subtitle  = 3
    case gate      = 4
}

// MARK: - Splash View

struct SplashView: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    // Phase drive animation
    @State private var phase: SplashPhase = .blank

    // Gate hover tracking
    @State private var hoveredLanguage: String? = nil

    // Ephemeris scroll unroll
    @State private var scrollUnrolled = false

    var body: some View {
        ZStack {
            // ── 1. Deep space background
            theme.background.ignoresSafeArea()

            // ── 2. Starfield / ambient layer (theme-aware)
            Group {
                if theme.isDark {
                    StarfieldView(starCount: 140, goldTint: true)
                } else {
                    LightAmbientView(count: 100)
                }
            }
            .ignoresSafeArea()
            .opacity(phase.rawValue >= SplashPhase.starfield.rawValue ? 1 : 0)
            .animation(.easeIn(duration: 2.5), value: phase)

            // ── 3. Ambient radial glow (center)
            RadialGradient(
                colors: [Color.cosmicGold.opacity(0.06), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 340
            )
            .ignoresSafeArea()
            .opacity(phase.rawValue >= SplashPhase.title.rawValue ? 1 : 0)
            .animation(.easeInOut(duration: 3), value: phase)

            // ── 4. Single-flow content column (scroll → title → gate)
            VStack(spacing: 0) {
                Spacer()

                ephemerisScroll
                    .opacity(phase.rawValue >= SplashPhase.title.rawValue ? 1 : 0)
                    .scaleEffect(phase.rawValue >= SplashPhase.title.rawValue ? 1 : 0.88)
                    .animation(.spring(duration: 2.5, bounce: 0.1), value: phase)

                Spacer().frame(height: 36)

                titleBlock

                Spacer()

                languageGate

                Spacer().frame(height: 56)
            }
        }
        .onAppear {
            runSplashSequence()
        }
    }

    // MARK: - Ephemeris Scroll

    private var ephemerisScroll: some View {
        VStack(spacing: 8) {
            // Caption above scroll
            Text("Fusion Firmaments")
                .goldLabel(0.45)
                .tracking(6)
                .opacity(phase.rawValue >= SplashPhase.title.rawValue ? 1 : 0)
                .animation(.easeIn(duration: 2).delay(0.5), value: phase)

            ZStack {
                // Top rod
                Capsule()
                    .fill(Color.cosmicGold.opacity(0.4))
                    .frame(width: 180, height: 4)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, -2)

                // Scroll body — zodiac wheel placeholder
                ZodiacScrollBody(unrolled: scrollUnrolled)
                    .frame(width: 180, height: scrollUnrolled ? 220 : 12)
                    .animation(.spring(duration: 1.8, bounce: 0.05).delay(0.3), value: scrollUnrolled)
                    .clipped()

                // Bottom rod
                Capsule()
                    .fill(Color.cosmicGold.opacity(0.4))
                    .frame(width: 180, height: 4)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, -2)
            }
            .frame(height: scrollUnrolled ? 228 : 20)
        }
    }

    // MARK: - Title Block

    private var titleBlock: some View {
        VStack(spacing: 6) {
            Text("Bazodiac")
                .font(CosmicFont.display(52))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.cosmicGold, Color.cosmicGold.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .tracking(4)
                .opacity(phase.rawValue >= SplashPhase.title.rawValue ? 1 : 0)
                .offset(y: phase.rawValue >= SplashPhase.title.rawValue ? 0 : 24)
                .animation(.spring(duration: 2, bounce: 0.1).delay(0.8), value: phase)

            Text("Coniunctio Caelorum")
                .font(CosmicFont.bodySerif(12))
                .foregroundStyle(theme.textTertiary)
                .tracking(5)
                .opacity(phase.rawValue >= SplashPhase.subtitle.rawValue ? 1 : 0)
                .animation(.easeIn(duration: 1.5).delay(0.2), value: phase)
        }
        .padding(.top, 16)
    }

    // MARK: - Language Gate

    private var languageGate: some View {
        VStack(spacing: 20) {
            Text("Bazodiac")
                .goldLabel(0.25)
                .tracking(6)

            HStack(spacing: 16) {
                languageButton("Deutsch", code: "de")
                languageButton("English", code: "en")
            }

            Text("Wähle deine Erfahrung")
                .font(CosmicFont.label(8))
                .tracking(3)
                .foregroundStyle(Color.cosmicGold.opacity(0.2))
                .italic()
        }
        .opacity(phase.rawValue >= SplashPhase.gate.rawValue ? 1 : 0)
        .offset(y: phase.rawValue >= SplashPhase.gate.rawValue ? 0 : 16)
        .animation(.spring(duration: 1.2, bounce: 0.05).delay(0.1), value: phase)
    }

    private func languageButton(_ title: String, code: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.5)) {
                store.language = code == "de" ? .german : .english
            }
            // Brief haptic
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()

            // Delay slightly for animation then transition
            Task {
                try? await Task.sleep(for: .milliseconds(350))
                store.enterApp(language: code == "de" ? .german : .english)
            }
        } label: {
            Text(title)
                .font(CosmicFont.label(9))
                .tracking(5)
                .foregroundStyle(Color.cosmicGold.opacity(hoveredLanguage == code ? 0.95 : 0.65))
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(
                            Color.cosmicGold.opacity(hoveredLanguage == code ? 0.4 : 0.14),
                            lineWidth: 0.75
                        )
                    if hoveredLanguage == code {
                        Color.cosmicGold.opacity(0.05)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                }
        }
        .buttonStyle(.plain)
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.3)) {
                hoveredLanguage = isHovered ? code : nil
            }
        }
    }

    // MARK: - Animation Sequence

    private func runSplashSequence() {
        let delays: [(SplashPhase, Double)] = [
            (.starfield, 0.3),
            (.title,     1.2),
            (.subtitle,  2.8),
            (.gate,      4.2),
        ]
        for (nextPhase, delay) in delays {
            Task {
                try? await Task.sleep(for: .seconds(delay))
                withAnimation {
                    phase = nextPhase
                }
                if nextPhase == .title {
                    try? await Task.sleep(for: .seconds(0.6))
                    withAnimation {
                        scrollUnrolled = true
                    }
                }
            }
        }
    }
}

// MARK: - Zodiac Scroll Body

/// The parchment-style inner scroll — shows a minimal zodiac ring illustration
private struct ZodiacScrollBody: View {
    @Environment(\.cosmicTheme) private var theme
    let unrolled: Bool

    var body: some View {
        ZStack {
            // Parchment background
            Rectangle()
                .fill(theme.surface.opacity(0.6))

            // Gold border hairlines
            Rectangle()
                .strokeBorder(Color.cosmicGold.opacity(0.18), lineWidth: 0.5)

            if unrolled {
                ZodiacWheelMini()
                    .opacity(0.55)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
    }
}

/// Compact zodiac ring drawn with Canvas
private struct ZodiacWheelMini: View {
    @Environment(\.cosmicTheme) private var theme
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height / 2
            let outerR = min(cx, cy) * 0.88
            let innerR = outerR * 0.62

            // 12 sign sectors
            for i in 0..<12 {
                let startAngle = Double(i) * 30 - 90.0
                let endAngle   = startAngle + 30.0
                let sa = Angle.degrees(startAngle)
                let ea = Angle.degrees(endAngle)

                var path = Path()
                path.addArc(center: CGPoint(x: cx, y: cy),
                            radius: outerR,
                            startAngle: sa, endAngle: ea, clockwise: false)
                path.addArc(center: CGPoint(x: cx, y: cy),
                            radius: innerR,
                            startAngle: ea, endAngle: sa, clockwise: true)
                path.closeSubpath()

                let sign = ZodiacSign.allCases[i]
                context.fill(path, with: .color(sign.color.opacity(0.12)))

                // Division tick
                var tick = Path()
                let tickAngle = Angle.degrees(startAngle)
                let tx1 = cx + innerR  * CGFloat(cos(tickAngle.radians))
                let ty1 = cy + innerR  * CGFloat(sin(tickAngle.radians))
                let tx2 = cx + outerR  * CGFloat(cos(tickAngle.radians))
                let ty2 = cy + outerR  * CGFloat(sin(tickAngle.radians))
                tick.move(to: CGPoint(x: tx1, y: ty1))
                tick.addLine(to: CGPoint(x: tx2, y: ty2))
                context.stroke(tick, with: .color(Color.cosmicGold.opacity(0.25)), lineWidth: 0.5)

                // Glyph
                let glyphAngle = Angle.degrees(startAngle + 15)
                let gr = (outerR + innerR) / 2
                let gx = cx + gr * CGFloat(cos(glyphAngle.radians))
                let gy = cy + gr * CGFloat(sin(glyphAngle.radians))

                var text = context.resolve(Text(sign.canvasLabel)
                    .font(.system(size: 7, weight: .medium).monospacedDigit()))
                text.shading = .color(Color.cosmicGold.opacity(0.75))
                context.draw(text, at: CGPoint(x: gx, y: gy), anchor: .center)
            }

            // Center circle
            context.stroke(
                Path(ellipseIn: CGRect(x: cx - innerR, y: cy - innerR,
                                       width: innerR * 2, height: innerR * 2)),
                with: .color(Color.cosmicGold.opacity(0.2)),
                lineWidth: 0.5
            )

            // Outer ring
            context.stroke(
                Path(ellipseIn: CGRect(x: cx - outerR, y: cy - outerR,
                                       width: outerR * 2, height: outerR * 2)),
                with: .color(Color.cosmicGold.opacity(0.3)),
                lineWidth: 0.75
            )
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView()
        .environment(CosmicStore())
}
