// WuXingView.swift
// Bazodiac iOS — Wu-Xing Five Elements
//
// Canvas-drawn pentagon with data polygon fill.
// Generating cycle (相生) + Controlling cycle (相克) indicators.
// Element balance bars + interpretation card.

import SwiftUI

struct WuXingView: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme
    @State private var appeared = false

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            StarfieldView(starCount: 55).ignoresSafeArea().opacity(0.4)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    screenHeader
                        .padding(.top, 60)
                        .padding(.bottom, 28)

                    if let data = store.profile?.wuxingData {
                        // Pentagon
                        WuXingPentagon(data: data)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 28)
                            .opacity(appeared ? 1 : 0)
                            .scaleEffect(appeared ? 1 : 0.88)
                            .animation(.spring(duration: 1.1, bounce: 0.1).delay(0.1), value: appeared)

                        // Dominant / Weakest
                        ElementHighlights(data: data)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeIn(duration: 0.8).delay(0.5), value: appeared)

                        GoldLine()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)

                        // Balance bars
                        ElementBalanceBars(data: data)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeIn(duration: 0.8).delay(0.65), value: appeared)

                        GoldLine()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)

                        // Cycles legend
                        CyclesLegend()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeIn(duration: 0.8).delay(0.8), value: appeared)

                        GoldLine()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)

                        // Interpretation
                        ElementInterpretation(data: data)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                            .opacity(appeared ? 1 : 0)
                            .animation(.easeIn(duration: 0.8).delay(0.9), value: appeared)
                    }
                }
            }
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    private var screenHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Wu-Xing")
                    .font(CosmicFont.display(26))
                    .foregroundStyle(theme.textPrimary)
                Text("Fünf Elemente · Kosmische Balance")
                    .goldLabel(0.4)
            }
            Spacer()
            Text("五行")
                .font(CosmicFont.chinese(18, weight: .thin))
                .foregroundStyle(Color.cosmicGold.opacity(0.25))
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Wu-Xing Pentagon Canvas

private struct WuXingPentagon: View {
    @Environment(\.cosmicTheme) private var theme
    let data: WuXingData

    // Element order for pentagon: top-center, then clockwise
    private let order: [CosmicElement] = [.wood, .fire, .earth, .metal, .water]

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cx   = geo.size.width  / 2
            let cy   = geo.size.height / 2

            ZStack {
                Canvas { context, canvasSize in
                    drawPentagon(context: context, cx: cx, cy: cy, r: size / 2 * 0.85)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)

                // Element labels overlaid
                ForEach(0..<order.count, id: \.self) { i in
                    let pt = labelPoint(index: i, cx: cx, cy: cy, r: size / 2 * 0.95)
                    ElementLabel(element: order[i])
                        .position(x: pt.x, y: pt.y)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 340)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Wu-Xing Fünf-Elemente-Pentagon. Dominant: \(data.dominant.germanName). Schwächstes Element: \(data.weakest.germanName).")
    }

    private func drawPentagon(context: GraphicsContext, cx: CGFloat, cy: CGFloat, r: CGFloat) {
        let maxR = r * 0.78
        let normalized = order.map { element -> Double in
            (data.balance[element] ?? 0.0).clamped(to: 0.0...1.0)
        }

        // ── Grid pentagons (20% increments) ──────────────────────────────
        for level in stride(from: 0.2, through: 1.0, by: 0.2) {
            let pts = (0..<5).map { i in
                pentagonPoint(i: i, r: maxR * CGFloat(level), cx: cx, cy: cy)
            }
            var grid = Path()
            grid.move(to: pts[0])
            for pt in pts.dropFirst() { grid.addLine(to: pt) }
            grid.closeSubpath()
            let isOuter = abs(level - 1.0) < 0.01
            context.stroke(grid,
                           with: .color(Color.cosmicGold.opacity(isOuter ? 0.2 : 0.07)),
                           lineWidth: isOuter ? 0.75 : 0.4)
        }

        // ── Axis lines ─────────────────────────────────────────────────────
        for i in 0..<5 {
            let pt = pentagonPoint(i: i, r: maxR, cx: cx, cy: cy)
            var axis = Path()
            axis.move(to: CGPoint(x: cx, y: cy))
            axis.addLine(to: pt)
            context.stroke(axis,
                           with: .color(Color.cosmicGold.opacity(0.06)),
                           lineWidth: 0.4)
        }

        // ── Data polygon ────────────────────────────────────────────────────
        let dataPts = (0..<5).map { i in
            pentagonPoint(i: i, r: maxR * CGFloat(max(normalized[i], 0.06)), cx: cx, cy: cy)
        }
        var dataPath = Path()
        dataPath.move(to: dataPts[0])
        for pt in dataPts.dropFirst() { dataPath.addLine(to: pt) }
        dataPath.closeSubpath()

        // Fill with element gradient blend
        context.fill(dataPath, with: .color(Color.cosmicGold.opacity(0.08)))
        context.stroke(dataPath, with: .color(Color.cosmicGold.opacity(0.5)), lineWidth: 1.5)

        // ── Generating cycle arrows (相生) ──────────────────────────────────
        let genCycle = [0, 1, 2, 3, 4, 0]   // Wood→Fire→Earth→Metal→Water→Wood
        for i in 0..<5 {
            let fromPt = dataPts[genCycle[i]]
            let toPt   = dataPts[genCycle[i + 1]]
            drawArrow(context: context, from: fromPt, to: toPt,
                      color: order[genCycle[i]].color.opacity(0.35),
                      lineWidth: 1.0)
        }

        // ── Element node dots ───────────────────────────────────────────────
        for i in 0..<5 {
            let pt = dataPts[i]
            let element = order[i]
            let dotR: CGFloat = 5.5

            let glowRect = CGRect(x: pt.x - dotR * 2.5, y: pt.y - dotR * 2.5,
                                  width: dotR * 5, height: dotR * 5)
            context.fill(Path(ellipseIn: glowRect),
                         with: .color(element.color.opacity(0.18)))

            let dotRect = CGRect(x: pt.x - dotR, y: pt.y - dotR,
                                 width: dotR * 2, height: dotR * 2)
            context.fill(Path(ellipseIn: dotRect),
                         with: .color(element.color.opacity(0.9)))
        }
    }

    private func drawArrow(context: GraphicsContext, from: CGPoint, to: CGPoint,
                            color: Color, lineWidth: CGFloat) {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let len = sqrt(dx * dx + dy * dy)
        guard len > 0.01 else { return }

        let ux = dx / len; let uy = dy / len
        let inset: CGFloat = 8  // don't draw into node
        let start = CGPoint(x: from.x + ux * inset, y: from.y + uy * inset)
        let end   = CGPoint(x: to.x   - ux * inset, y: to.y   - uy * inset)

        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        context.stroke(path, with: .color(color), lineWidth: lineWidth)

        // Arrowhead
        let arrowLen: CGFloat = 6
        let arrowWidth: CGFloat = 3.5
        let ax = end.x - ux * arrowLen
        let ay = end.y - uy * arrowLen
        var arrow = Path()
        arrow.move(to: end)
        arrow.addLine(to: CGPoint(x: ax - uy * arrowWidth, y: ay + ux * arrowWidth))
        arrow.addLine(to: CGPoint(x: ax + uy * arrowWidth, y: ay - ux * arrowWidth))
        arrow.closeSubpath()
        context.fill(arrow, with: .color(color))
    }

    private func pentagonPoint(i: Int, r: CGFloat, cx: CGFloat, cy: CGFloat) -> CGPoint {
        // Start from top (-90°), clockwise, 72° apart
        let deg = Double(i) * 72.0 - 90.0
        let rad = deg * .pi / 180.0
        return CGPoint(x: cx + r * CGFloat(cos(rad)), y: cy + r * CGFloat(sin(rad)))
    }

    private func labelPoint(index: Int, cx: CGFloat, cy: CGFloat, r: CGFloat) -> CGPoint {
        let deg = Double(index) * 72.0 - 90.0
        let rad = deg * .pi / 180.0
        return CGPoint(x: cx + r * CGFloat(cos(rad)), y: cy + r * CGFloat(sin(rad)))
    }
}

private struct ElementLabel: View {
    @Environment(\.cosmicTheme) private var theme
    let element: CosmicElement

    var body: some View {
        VStack(spacing: 3) {
            Text(element.chineseChar)
                .font(CosmicFont.chinese(15, weight: .light))
                .foregroundStyle(element.color)
            Text(element.germanName)
                .goldLabel(0.45)
        }
    }
}

// MARK: - Element Highlights

private struct ElementHighlights: View {
    let data: WuXingData

    var body: some View {
        HStack(spacing: 12) {
            ElementHighlightCard(
                title: "Dominant",
                element: data.dominant,
                icon: "arrow.up.circle.fill"
            )
            ElementHighlightCard(
                title: "Schwach",
                element: data.weakest,
                icon: "arrow.down.circle"
            )
        }
    }
}

private struct ElementHighlightCard: View {
    @Environment(\.cosmicTheme) private var theme
    let title: String
    let element: CosmicElement
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .thin))
                .foregroundStyle(element.color.opacity(0.8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title).goldLabel(0.4)
                HStack(spacing: 6) {
                    Text(element.chineseChar)
                        .font(CosmicFont.chinese(16, weight: .light))
                        .foregroundStyle(element.color)
                    Text(element.germanName)
                        .font(CosmicFont.heading(13, weight: .light))
                        .foregroundStyle(Color.cosmicGold.opacity(0.8))
                }
            }
            Spacer()
        }
        .padding(16)
        .background(element.color.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(element.color.opacity(0.2), lineWidth: 0.6)
        )
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Element Balance Bars

private struct ElementBalanceBars: View {
    @Environment(\.cosmicTheme) private var theme
    let data: WuXingData

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Elementares Gleichgewicht")
                    .goldLabel(0.5)
                Spacer()
            }
            .padding(.bottom, 14)

            VStack(spacing: 10) {
                ForEach(CosmicElement.allCases) { element in
                    let value = data.balance[element] ?? 0
                    ElementBarRow(element: element, value: value)
                }
            }
        }
        .padding(18)
        .cosmicCard()
    }
}

private struct ElementBarRow: View {
    @Environment(\.cosmicTheme) private var theme
    let element: CosmicElement
    let value:   Double
    @State private var animValue: Double = 0

    var body: some View {
        HStack(spacing: 12) {
            Text(element.chineseChar)
                .font(CosmicFont.chinese(14))
                .foregroundStyle(element.color.opacity(0.8))
                .frame(width: 18)

            Text(element.germanName)
                .font(CosmicFont.heading(12, weight: .light))
                .foregroundStyle(theme.textSecondary)
                .frame(width: 56, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.cosmicGold.opacity(0.06))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [element.color.opacity(0.8), element.color.opacity(0.45)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animValue)
                }
            }
            .frame(height: 6)
            .onAppear {
                // Guard against re-firing on re-appear (LazyVStack recycling)
                guard animValue == 0 else { return }
                withAnimation(.spring(duration: 1.1).delay(Double.random(in: 0.0...0.3))) {
                    animValue = value
                }
            }

            Text(String(format: "%.0f%%", value * 100))
                .font(CosmicFont.mono(11))
                .foregroundStyle(element.color.opacity(0.6))
                .frame(width: 32, alignment: .trailing)
        }
    }
}

// MARK: - Cycles Legend

private struct CyclesLegend: View {
    @Environment(\.cosmicTheme) private var theme
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Kosmische Zyklen")
                    .goldLabel(0.5)
                Spacer()
            }

            HStack(spacing: 24) {
                CycleLegendItem(
                    color: Color.cosmicGold.opacity(0.6),
                    dashed: false,
                    label: "Erzeugungs-Zyklus 相生",
                    sublabel: "Holz→Feuer→Erde→Metall→Wasser"
                )
            }
        }
        .padding(18)
        .cosmicCard()
    }
}

private struct CycleLegendItem: View {
    @Environment(\.cosmicTheme) private var theme
    let color: Color
    let dashed: Bool
    let label: String
    let sublabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                // Line sample
                if dashed {
                    HStack(spacing: 3) {
                        ForEach(0..<4, id: \.self) { _ in
                            Rectangle().fill(color).frame(width: 5, height: 1.5)
                        }
                    }
                } else {
                    Rectangle().fill(color).frame(width: 22, height: 1.5)
                }
                Text(label)
                    .font(CosmicFont.heading(12, weight: .light))
                    .foregroundStyle(theme.textSecondary)
            }
            Text(sublabel)
                .goldLabel(0.3)
                .padding(.leading, 30)
        }
    }
}

// MARK: - Interpretation Card

private struct ElementInterpretation: View {
    @Environment(\.cosmicTheme) private var theme
    let data: WuXingData

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Interpretation", systemImage: "sparkles")
                .goldLabel(0.55)
                .labelStyle(.titleAndIcon)

            GoldLine()

            Text(data.interpretation)
                .font(CosmicFont.bodySerif(14))
                .foregroundStyle(theme.textSecondary)
                .lineSpacing(5)
        }
        .padding(18)
        .cosmicCard()
    }
}

// MARK: - Preview

#Preview {
    WuXingView()
        .environment({
            let s = CosmicStore()
            s.profile = .mock
            return s
        }())
}
