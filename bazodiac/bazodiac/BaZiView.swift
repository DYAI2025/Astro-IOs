// BaZiView.swift
// Bazodiac iOS — BaZi Four Pillars of Destiny
//
// The four pillars: Year / Month / Day / Hour
// Each pillar shows Heavenly Stem (天干) + Earthly Branch (地支)
// Stele-style card aesthetic inspired by the web app's .stele-card CSS class.
// Element colors per pillar, animated entrance cascade.

import SwiftUI
import UIKit

struct BaZiView: View {
    @Environment(CosmicStore.self) private var store

    @State private var appeared = false
    @State private var selectedPillar: BaZiPillar? = nil

    var body: some View {
        ZStack {
            Color.obsidian.ignoresSafeArea()
            StarfieldView(starCount: 55).ignoresSafeArea().opacity(0.4)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    screenHeader
                        .padding(.top, 60)
                        .padding(.bottom, 28)

                    if let data = store.profile?.baziData {
                        // Day Master highlight
                        DayMasterCard(pillar: data.day)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring(duration: 0.9).delay(0.1), value: appeared)

                        GoldLine()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)

                        // Four pillars grid
                        FourPillarsGrid(data: data, selectedPillar: $selectedPillar)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 24)
                            .animation(.spring(duration: 0.9).delay(0.3), value: appeared)

                        GoldLine()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)

                        // Element distribution
                        ElementDistributionBar(data: data)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(duration: 0.9).delay(0.5), value: appeared)
                    }
                }
            }
        }
        .onAppear {
            withAnimation { appeared = true }
        }
        .sheet(item: $selectedPillar) { pillar in
            PillarDetailSheet(pillar: pillar)
                .presentationDetents([.fraction(0.55)])
                .presentationBackground(Color.cosmicAsh)
        }
    }

    private var screenHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Vier Säulen")
                    .font(CosmicFont.display(26))
                    .foregroundStyle(Color.cosmicGold.opacity(0.9))
                Text("BaZi · Vier Pfeiler des Schicksals")
                    .goldLabel(0.4)
            }
            Spacer()
            Text("四柱命理")
                .font(CosmicFont.chinese(18, weight: .thin))
                .foregroundStyle(Color.cosmicGold.opacity(0.25))
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Day Master Highlight

private struct DayMasterCard: View {
    let pillar: BaZiPillar

    var body: some View {
        HStack(spacing: 20) {
            // Day Master stem badge
            VStack(spacing: 6) {
                Text(pillar.stem.char)
                    .font(CosmicFont.chinese(48, weight: .ultraLight))
                    .foregroundStyle(pillar.stem.element.color)
                Text(pillar.stem.pinyin)
                    .font(CosmicFont.mono(10))
                    .foregroundStyle(pillar.stem.element.color.opacity(0.5))
            }
            .padding(.leading, 4)

            VStack(alignment: .leading, spacing: 8) {
                Text("Tag-Meister · 日主")
                    .goldLabel(0.45)

                Text("\(pillar.stem.english)")
                    .font(CosmicFont.heading(18, weight: .light))
                    .foregroundStyle(Color.cosmicGold.opacity(0.9))

                Text("Das ist dein wahrstes Ich — deine Kernessenz im kosmischen System der Vier Säulen.")
                    .font(CosmicFont.bodySerif(13))
                    .foregroundStyle(Color.cosmicGold.opacity(0.5))
                    .lineSpacing(4)

                ElementBadge(element: pillar.stem.element, size: 28)
            }

            Spacer()
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(pillar.stem.element.color.opacity(0.06))
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(pillar.stem.element.color.opacity(0.25), lineWidth: 0.75)
        }
    }
}

// MARK: - Four Pillars Grid

private struct FourPillarsGrid: View {
    let data: BaZiData
    @Binding var selectedPillar: BaZiPillar?

    var body: some View {
        HStack(spacing: 10) {
            ForEach(data.allPillars) { pillar in
                PillarCard(pillar: pillar, isDay: pillar.type == .day) {
                    selectedPillar = pillar
                }
            }
        }
    }
}

// MARK: - Pillar Card (Stele Style)

private struct PillarCard: View {
    let pillar: BaZiPillar
    let isDay: Bool
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            VStack(spacing: 0) {
                // Pillar type label
                VStack(spacing: 2) {
                    Text(pillar.type.rawValue)
                        .font(CosmicFont.chinese(12, weight: .light))
                        .foregroundStyle(Color.cosmicGold.opacity(0.35))
                    Text(pillar.type.germanLabel)
                        .goldLabel(0.4)
                }
                .padding(.vertical, 10)

                // Top separator
                GoldLine()
                    .padding(.horizontal, 8)

                // Heavenly Stem 天干
                VStack(spacing: 4) {
                    Text(pillar.stem.char)
                        .font(CosmicFont.chinese(36, weight: .ultraLight))
                        .foregroundStyle(pillar.stem.element.color)

                    ElementBadge(element: pillar.stem.element, size: 22)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(pillar.stem.element.color.opacity(0.04))

                // Divider with stem details
                GoldLine()
                    .padding(.horizontal, 8)

                // Earthly Branch 地支
                VStack(spacing: 6) {
                    Text(pillar.branch.char)
                        .font(CosmicFont.chinese(32, weight: .ultraLight))
                        .foregroundStyle(pillar.branch.element.color)

                    Text(pillar.branch.animalEmoji)
                        .font(.system(size: 16))

                    Text(pillar.branch.animal)
                        .goldLabel(0.35)
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(pillar.branch.element.color.opacity(0.03))

                // Bottom bar — element indicator
                Rectangle()
                    .fill(pillar.stem.element.color.opacity(0.5))
                    .frame(height: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isDay ? Color.cosmicGold.opacity(0.4) : Color.cosmicGold.opacity(0.12),
                        lineWidth: isDay ? 1 : 0.5
                    )
            }
            .background(
                Color.cosmicAsh.opacity(0.8)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            )
            .shadow(
                color: isDay ? pillar.stem.element.color.opacity(0.15) : .clear,
                radius: 12
            )
            .scaleEffect(pressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { pressed = true } }
                .onEnded   { _ in withAnimation(.spring(duration: 0.3))  { pressed = false } }
        )
    }
}

// MARK: - Element Distribution Bar

private struct ElementDistributionBar: View {
    let data: BaZiData

    private var counts: [CosmicElement: Int] {
        var result: [CosmicElement: Int] = [:]
        for pillar in data.allPillars {
            result[pillar.stem.element,   default: 0] += 2
            result[pillar.branch.element, default: 0] += 1
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elementen-Verteilung")
                .goldLabel(0.5)
                .padding(.bottom, 4)

            ForEach(CosmicElement.allCases) { element in
                let count = counts[element] ?? 0
                let max   = 8.0 // max theoretical (4 stems × 2)

                HStack(spacing: 12) {
                    // Element symbol
                    Text(element.chineseChar)
                        .font(CosmicFont.chinese(14, weight: .light))
                        .foregroundStyle(element.color.opacity(0.8))
                        .frame(width: 20)

                    Text(element.germanName)
                        .font(CosmicFont.heading(12, weight: .light))
                        .foregroundStyle(Color.cosmicGold.opacity(0.6))
                        .frame(width: 58, alignment: .leading)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.cosmicGold.opacity(0.06))
                            Capsule()
                                .fill(element.color.opacity(0.7))
                                .frame(width: geo.size.width * CGFloat(count) / max)
                        }
                    }
                    .frame(height: 5)

                    Text("\(count)")
                        .font(CosmicFont.mono(11))
                        .foregroundStyle(element.color.opacity(0.6))
                        .frame(width: 18, alignment: .trailing)
                }
            }
        }
        .padding(18)
        .cosmicCard()
    }
}

// MARK: - Pillar Detail Sheet

private struct PillarDetailSheet: View {
    let pillar: BaZiPillar
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.cosmicGold.opacity(0.25))
                .frame(width: 36, height: 3)
                .padding(.top, 12)
                .padding(.bottom, 28)

            // Type header
            VStack(spacing: 4) {
                Text(pillar.type.rawValue)
                    .font(CosmicFont.chinese(22, weight: .thin))
                    .foregroundStyle(Color.cosmicGold.opacity(0.4))
                Text(pillar.type.germanLabel + " Säule")
                    .font(CosmicFont.display(26))
                    .foregroundStyle(Color.cosmicGold.opacity(0.9))
                Text(pillar.type.description)
                    .goldLabel(0.45)
                    .padding(.top, 2)
            }

            Spacer().frame(height: 24)

            // Stem + Branch display
            HStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("天干")
                        .goldLabel(0.35)
                    Text(pillar.stem.char)
                        .font(CosmicFont.chinese(56, weight: .ultraLight))
                        .foregroundStyle(pillar.stem.element.color)
                    Text(pillar.stem.pinyin)
                        .font(CosmicFont.mono(11))
                        .foregroundStyle(pillar.stem.element.color.opacity(0.5))
                    Text(pillar.stem.english)
                        .font(CosmicFont.heading(12, weight: .light))
                        .foregroundStyle(Color.cosmicGold.opacity(0.6))
                }

                Rectangle()
                    .fill(Color.cosmicGold.opacity(0.1))
                    .frame(width: 0.5)
                    .frame(height: 100)

                VStack(spacing: 8) {
                    Text("地支")
                        .goldLabel(0.35)
                    Text(pillar.branch.char)
                        .font(CosmicFont.chinese(56, weight: .ultraLight))
                        .foregroundStyle(pillar.branch.element.color)
                    Text(pillar.branch.animalEmoji)
                        .font(.system(size: 22))
                    Text(pillar.branch.animal)
                        .font(CosmicFont.heading(12, weight: .light))
                        .foregroundStyle(Color.cosmicGold.opacity(0.6))
                }
            }

            Spacer()

            Button("Schließen") { dismiss() }
                .font(CosmicFont.label(9))
                .tracking(3)
                .foregroundStyle(Color.cosmicGold.opacity(0.45))
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .background(Color.cosmicAsh)
    }
}

// MARK: - Preview

#Preview {
    BaZiView()
        .environment({
            let s = CosmicStore()
            s.profile = .mock
            return s
        }())
}
