// QuizPlayView.swift
// Bazodiac iOS — Quiz-Spielfluss (Frage → Antwort → Ergebnis)
//
// 1:1 Port der Web-App Scoring-Engine.
// Frage-für-Frage UI mit Fortschrittsbalken, animierten Übergängen.

import SwiftUI
import UIKit

struct QuizPlayView: View {
    let quiz: FullQuiz
    let onFinish: (QuizProfile, [String: Double]) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.cosmicTheme) private var theme

    @State private var currentIndex = 0
    @State private var answers: [String: String] = [:]
    @State private var selectedOption: String? = nil
    @State private var showResult = false
    @State private var resultProfile: QuizProfile? = nil
    @State private var resultScores: [String: Double] = [:]

    private var progress: Double {
        Double(currentIndex) / Double(max(quiz.questions.count, 1))
    }

    private var currentQuestion: QuizQuestion? {
        guard currentIndex < quiz.questions.count else { return nil }
        return quiz.questions[currentIndex]
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            if showResult, let profile = resultProfile {
                QuizResultView(quiz: quiz, profile: profile, scores: resultScores) {
                    onFinish(profile, resultScores)
                    dismiss()
                }
                .transition(.push(from: .trailing))
            } else if let question = currentQuestion {
                VStack(spacing: 0) {
                    // Header + Progress
                    quizHeader

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Kontext/Szenario
                            if !question.context.isEmpty {
                                Text(question.context)
                                    .font(CosmicFont.bodySerif(14))
                                    .foregroundStyle(theme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(5)
                                    .padding(.horizontal, 28)
                                    .padding(.top, 20)
                            }

                            // Frage
                            Text(question.text)
                                .font(CosmicFont.heading(22, weight: .medium))
                                .foregroundStyle(theme.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, 24)

                            // Optionen
                            VStack(spacing: 12) {
                                ForEach(question.options) { option in
                                    OptionButton(
                                        option: option,
                                        isSelected: selectedOption == option.id,
                                        quizColor: quiz.color
                                    ) {
                                        selectOption(option)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .push(from: .trailing),
                    removal: .push(from: .leading)
                ))
                .id(currentIndex) // Force transition on index change
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.15), value: currentIndex)
        .animation(.spring(duration: 0.5), value: showResult)
    }

    // MARK: - Header

    private var quizHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(theme.textTertiary)
                        .frame(width: 36, height: 36)
                        .background(theme.goldFaint, in: Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("\(currentIndex + 1) / \(quiz.questions.count)")
                    .font(CosmicFont.mono(12))
                    .foregroundStyle(theme.textTertiary)

                Spacer()

                // Quiz icon
                Image(systemName: quiz.icon)
                    .font(.system(size: 14, weight: .thin))
                    .foregroundStyle(quiz.color.opacity(0.6))
                    .frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(theme.goldFaint)
                        .frame(height: 4)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [quiz.color.opacity(0.6), quiz.color],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.spring(duration: 0.5), value: progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)
        }
        .padding(.top, 60)
        .padding(.bottom, 8)
    }

    // MARK: - Actions

    private func selectOption(_ option: QuizOption) {
        guard selectedOption == nil else { return } // Prevent double-tap

        let impact = UISelectionFeedbackGenerator()
        impact.selectionChanged()

        withAnimation(.spring(duration: 0.3)) {
            selectedOption = option.id
        }

        guard let question = currentQuestion else { return }
        answers[question.id] = option.id

        // Delay then advance
        Task {
            try? await Task.sleep(for: .milliseconds(600))

            if currentIndex + 1 < quiz.questions.count {
                withAnimation {
                    selectedOption = nil
                    currentIndex += 1
                }
            } else {
                // Quiz complete → calculate result
                resultScores = QuizEngine.calculateScores(answers: answers, quiz: quiz)
                resultProfile = QuizEngine.matchProfile(scores: resultScores, quiz: quiz)

                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()

                withAnimation(.spring(duration: 0.6)) {
                    showResult = true
                }
            }
        }
    }
}

// MARK: - Option Button

private struct OptionButton: View {
    let option: QuizOption
    let isSelected: Bool
    let quizColor: Color
    let action: () -> Void
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(option.text)
                    .font(CosmicFont.bodySerif(15))
                    .foregroundStyle(isSelected ? theme.textPrimary : theme.textSecondary)
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(quizColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? quizColor.opacity(0.12) : theme.cardBackground)
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isSelected ? quizColor.opacity(0.5) : theme.goldBorder,
                        lineWidth: isSelected ? 1.5 : 0.75
                    )
            }
            .scaleEffect(isSelected ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.3), value: isSelected)
    }
}
