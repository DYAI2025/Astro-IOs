// QuizResultView.swift
// Bazodiac iOS — Quiz-Ergebnisanzeige
//
// Zeigt Profil-Titel, Beschreibung, Stats-Radar, Share-Button.
// Trading-Card Aesthetic (1:1 wie Web-App Design-System).

import SwiftUI
import UIKit

struct QuizResultView: View {
    let quiz: FullQuiz
    let profile: QuizProfile
    let scores: [String: Double]
    let onDone: () -> Void

    @Environment(\.cosmicTheme) private var theme
    @State private var appeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                // ── Ergebnis-Karte (Trading Card) ──────────────────────
                resultCard
                    .padding(.horizontal, 28)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.9)
                    .animation(.spring(duration: 0.8, bounce: 0.15).delay(0.2), value: appeared)

                Spacer().frame(height: 28)

                // ── Stats ──────────────────────────────────────────────
                statsSection
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(duration: 0.7).delay(0.5), value: appeared)

                Spacer().frame(height: 24)

                // ── Dimension-Scores ─────────────────────────────────
                dimensionBars
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeIn(duration: 0.6).delay(0.7), value: appeared)

                Spacer().frame(height: 32)

                // ── Actions ────────────────────────────────────────────
                actionButtons
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeIn(duration: 0.5).delay(0.9), value: appeared)

                Spacer().frame(height: 120)
            }
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    // MARK: - Result Card

    private var resultCard: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(profile.color.opacity(0.15))
                    .frame(width: 80, height: 80)
                Circle()
                    .strokeBorder(profile.color.opacity(0.4), lineWidth: 1)
                    .frame(width: 80, height: 80)
                Image(systemName: profile.icon)
                    .font(.system(size: 32, weight: .thin))
                    .foregroundStyle(profile.color)
            }

            // Titel
            Text(profile.title)
                .font(CosmicFont.display(28))
                .foregroundStyle(theme.textPrimary)
                .multilineTextAlignment(.center)

            // Tagline
            Text(profile.tagline)
                .font(CosmicFont.bodySerif(14))
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            GoldLine()
                .padding(.vertical, 4)

            // Beschreibung
            Text(profile.description)
                .font(CosmicFont.bodySerif(14))
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 8)
        }
        .padding(24)
        .cosmicCard(cornerRadius: 20)
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: 12) {
            ForEach(profile.stats, id: \.label) { stat in
                VStack(spacing: 8) {
                    // Circular progress
                    ZStack {
                        Circle()
                            .stroke(theme.goldFaint, lineWidth: 3)
                            .frame(width: 50, height: 50)
                        Circle()
                            .trim(from: 0, to: appeared ? stat.percent : 0)
                            .stroke(profile.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(duration: 1.2).delay(0.6), value: appeared)

                        Text(stat.value)
                            .font(CosmicFont.mono(10))
                            .foregroundStyle(theme.textPrimary)
                    }

                    Text(stat.label)
                        .font(CosmicFont.label(8))
                        .tracking(2)
                        .foregroundStyle(theme.textTertiary)
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .cosmicCard(cornerRadius: 14)
    }

    // MARK: - Dimension Bars

    private var dimensionBars: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DIMENSIONEN")
                .goldLabel(0.45)

            ForEach(quiz.dimensions.sorted(by: { (scores[$0] ?? 0) > (scores[$1] ?? 0) }), id: \.self) { dim in
                let score = scores[dim] ?? 0
                HStack(spacing: 12) {
                    Text(dim.capitalized)
                        .font(CosmicFont.heading(12, weight: .light))
                        .foregroundStyle(theme.textSecondary)
                        .frame(width: 80, alignment: .trailing)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(theme.goldFaint)
                                .frame(height: 6)
                            Capsule()
                                .fill(profile.color.opacity(0.7))
                                .frame(width: geo.size.width * (appeared ? score / 100 : 0), height: 6)
                                .animation(.spring(duration: 1).delay(0.8), value: appeared)
                        }
                    }
                    .frame(height: 6)

                    Text("\(Int(score))")
                        .font(CosmicFont.mono(11))
                        .foregroundStyle(theme.textTertiary)
                        .frame(width: 28, alignment: .trailing)
                }
            }
        }
        .padding(18)
        .cosmicCard(cornerRadius: 14)
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Share
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                // TODO: Share sheet
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .light))
                    Text("ERGEBNIS TEILEN")
                        .font(CosmicFont.label(9))
                        .tracking(3)
                }
                .foregroundStyle(theme.gold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(theme.goldBorder, lineWidth: 0.75)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.goldFaint)
                }
            }
            .buttonStyle(.plain)

            // Done
            Button {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                onDone()
            } label: {
                Text("ZURÜCK ZU DEN QUIZZES")
                    .font(CosmicFont.label(9))
                    .tracking(3)
                    .foregroundStyle(theme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
    }
}
