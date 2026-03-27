// QuizModels.swift
// Bazodiac iOS — Quiz Domain Models
//
// Cluster → Quiz hierarchy.
// Each cluster has its own accent color and SF Symbol icon.
// Quiz states: locked · available · completed

import SwiftUI

// MARK: - Quiz Status

enum QuizStatus {
    case locked
    case available
    case completed
}

// MARK: - Quiz

struct Quiz: Identifiable {
    let id          = UUID()
    let name:          String
    let questionCount: Int
    var status:        QuizStatus
}

// MARK: - Quiz Cluster

struct QuizCluster: Identifiable {
    let id    = UUID()
    let name:  String
    let icon:  String       // SF Symbol name
    let color: Color
    let quizzes: [Quiz]

    var completedCount: Int { quizzes.filter { if case .completed = $0.status { return true }; return false }.count }
    var totalCount:     Int { quizzes.count }
    var progressLabel:  String { "\(completedCount)/\(totalCount)" }
    var isFullyDone:    Bool { completedCount == totalCount }
}

// Hashable for NavigationStack navigationDestination(for:)
extension QuizCluster: Hashable {
    static func == (lhs: QuizCluster, rhs: QuizCluster) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Mock Data

extension QuizCluster {
    static let mockClusters: [QuizCluster] = [

        QuizCluster(
            name: "Kosmische Identität",
            icon: "sparkles",
            color: Color(hex: "#7C5CBF"),
            quizzes: [
                Quiz(name: "Persönlichkeits-Profil",  questionCount: 12, status: .completed),
                Quiz(name: "Kraft-Tier",               questionCount:  8, status: .completed),
                Quiz(name: "Celebrity Soulmate",        questionCount: 10, status: .available),
                Quiz(name: "Kosmischer Archetyp",      questionCount: 15, status: .locked),
            ]
        ),

        QuizCluster(
            name: "Liebe & Verbindung",
            icon: "heart.fill",
            color: Color(hex: "#C45C87"),
            quizzes: [
                Quiz(name: "Liebessprachen",        questionCount:  8, status: .completed),
                Quiz(name: "Beziehungs-Stil",       questionCount: 10, status: .available),
                Quiz(name: "Partner-Kompatibilität", questionCount: 12, status: .locked),
            ]
        ),

        QuizCluster(
            name: "Soziale Rolle",
            icon: "person.2.fill",
            color: Color(hex: "#4A85C4"),
            quizzes: [
                Quiz(name: "Sozialer Typ",    questionCount:  9, status: .available),
                Quiz(name: "Führungs-Stil",   questionCount:  7, status: .locked),
                Quiz(name: "Team-Dynamik",    questionCount: 11, status: .locked),
            ]
        ),

        QuizCluster(
            name: "BaZi Vertiefung",
            icon: "square.grid.2x2.fill",
            color: Color(hex: "#C49A3C"),
            quizzes: [
                Quiz(name: "Tag-Meister Deep Dive",  questionCount: 14, status: .available),
                Quiz(name: "Säulen-Interaktion",     questionCount: 10, status: .locked),
                Quiz(name: "Luck-Pfeiler",           questionCount:  8, status: .locked),
                Quiz(name: "10-Götter System",       questionCount: 16, status: .locked),
            ]
        ),

        QuizCluster(
            name: "Elemente & Energie",
            icon: "pentagon.fill",
            color: Color(hex: "#4A9B6E"),
            quizzes: [
                Quiz(name: "Element-Balance",    questionCount:  6, status: .completed),
                Quiz(name: "Erzeugungs-Zyklus",  questionCount:  8, status: .available),
                Quiz(name: "Kontroll-Zyklus",    questionCount:  8, status: .locked),
            ]
        ),
    ]
}
