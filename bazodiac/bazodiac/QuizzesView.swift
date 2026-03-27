// QuizzesView.swift
// Bazodiac iOS — Quiz Hub mit echten Fragen
//
// Zeigt alle verfügbaren Quizzes als Kacheln.
// Tap → QuizPlayView (vollständiger Frage-für-Frage-Fluss)
// Ergebnis wird lokal in UserDefaults gespeichert.

import SwiftUI
import UIKit

struct QuizzesView: View {
    @Environment(\.cosmicTheme) private var theme
    @Environment(CosmicStore.self) private var store
    @State private var completedQuizIds: Set<String> = []
    @State private var activeQuiz: FullQuiz? = nil

    private let quizzes = allQuizzes

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            if theme.isDark {
                StarfieldView(starCount: 60).ignoresSafeArea().opacity(0.35)
            } else {
                LightAmbientView(count: 50).ignoresSafeArea()
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    quizzesHeader
                        .padding(.top, 60)
                        .padding(.bottom, 28)

                    quizGrid
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .fullScreenCover(item: $activeQuiz) { quiz in
            QuizPlayView(quiz: quiz) { profile, scores in
                completedQuizIds.insert(quiz.id)
                saveCompletedQuizIds()
            }
            .environment(\.cosmicTheme, theme)
        }
        .onAppear {
            loadCompletedQuizIds()
        }
    }

    // MARK: - Header

    private var quizzesHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 26, weight: .thin))
                .foregroundStyle(theme.gold.opacity(0.7))

            Text("Quizzes")
                .font(CosmicFont.display(30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.textPrimary, theme.textSecondary],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .tracking(2)

            Text("Entdecke deine kosmischen Muster")
                .goldLabel(0.4)
                .tracking(4)

            Text("\(completedQuizIds.count) / \(quizzes.count) abgeschlossen")
                .font(CosmicFont.mono(11))
                .foregroundStyle(theme.textTertiary)
                .padding(.top, 4)
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Quiz Grid

    private var quizGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
            spacing: 14
        ) {
            ForEach(quizzes) { quiz in
                QuizGridTile(
                    quiz: quiz,
                    isCompleted: completedQuizIds.contains(quiz.id)
                ) {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    activeQuiz = quiz
                }
            }
        }
    }

    // MARK: - Persistence

    private func saveCompletedQuizIds() {
        UserDefaults.standard.set(Array(completedQuizIds), forKey: "bazodiac.completedQuizzes")
    }

    private func loadCompletedQuizIds() {
        let saved = UserDefaults.standard.stringArray(forKey: "bazodiac.completedQuizzes") ?? []
        completedQuizIds = Set(saved)
    }
}

// MARK: - Quiz Grid Tile

private struct QuizGridTile: View {
    @Environment(\.cosmicTheme) private var theme
    let quiz: FullQuiz
    let isCompleted: Bool
    let onTap: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(quiz.color.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Circle()
                            .strokeBorder(quiz.color.opacity(0.4), lineWidth: 0.75)
                            .frame(width: 40, height: 40)
                        Image(systemName: quiz.icon)
                            .font(.system(size: 16, weight: .thin))
                            .foregroundStyle(quiz.color)
                    }
                    Spacer()
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.cosmicGold)
                    }
                }

                Spacer()

                // Title
                Text(quiz.title)
                    .font(CosmicFont.heading(13, weight: .regular))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Meta
                HStack(spacing: 8) {
                    Text("\(quiz.questions.count) Fragen")
                        .font(CosmicFont.mono(9))
                        .foregroundStyle(quiz.color.opacity(0.6))
                    Text("~\(quiz.estimatedMinutes) Min.")
                        .font(CosmicFont.mono(9))
                        .foregroundStyle(theme.textTertiary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 145)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isCompleted ? Color.cosmicGold.opacity(0.06) : quiz.color.opacity(0.05))
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isCompleted ? Color.cosmicGold.opacity(0.45) : quiz.color.opacity(0.22),
                        lineWidth: isCompleted ? 1 : 0.75
                    )
            }
            .scaleEffect(pressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { pressed = true } }
                .onEnded   { _ in withAnimation(.spring(duration: 0.3)) { pressed = false } }
        )
    }
}

// MARK: - FullQuiz Identifiable conformance

extension FullQuiz: @retroactive Equatable {
    static func == (lhs: FullQuiz, rhs: FullQuiz) -> Bool { lhs.id == rhs.id }
}

// MARK: - Preview

#Preview {
    QuizzesView()
        .environment(CosmicStore())
}
