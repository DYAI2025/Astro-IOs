// QuizzesView.swift
// Bazodiac iOS — Quiz Hub
//
// Navigation:  QuizzesView (cluster grid)
//              → ClusterDetailView (quiz tiles)
//
// Quiz tile states:
//   completed  — gold outline, gold glow, checkmark
//   available  — cluster-color outline, cluster-color tint
//   locked     — gray, lock icon, name hidden

import SwiftUI
import UIKit

struct QuizzesView: View {
    private let clusters = QuizCluster.mockClusters

    var body: some View {
        NavigationStack {
            ZStack {
                Color.obsidian.ignoresSafeArea()
                StarfieldView(starCount: 60).ignoresSafeArea().opacity(0.35)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        quizzesHeader
                            .padding(.top, 60)
                            .padding(.bottom, 28)

                        clusterGrid
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: QuizCluster.self) { cluster in
                ClusterDetailView(cluster: cluster)
            }
        }
    }

    // MARK: - Header

    private var quizzesHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 26, weight: .thin))
                .foregroundStyle(Color.cosmicGold.opacity(0.7))

            Text("Quizzes")
                .font(CosmicFont.display(30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.cosmicGold.opacity(0.9), Color.cosmicGold.opacity(0.55)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .tracking(2)

            Text("Entdecke deine kosmischen Muster")
                .goldLabel(0.4)
                .tracking(4)

            // Total progress summary
            let total     = clusters.reduce(0) { $0 + $1.totalCount }
            let completed = clusters.reduce(0) { $0 + $1.completedCount }
            Text("\(completed) / \(total) abgeschlossen")
                .font(CosmicFont.mono(11))
                .foregroundStyle(Color.cosmicGold.opacity(0.35))
                .padding(.top, 4)
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Cluster Grid (2 columns)

    private var clusterGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
            spacing: 14
        ) {
            ForEach(clusters) { cluster in
                NavigationLink(value: cluster) {
                    ClusterTile(cluster: cluster)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Cluster Tile

private struct ClusterTile: View {
    let cluster: QuizCluster
    @State private var pressed = false

    var body: some View {
        VStack(spacing: 10) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(cluster.color.opacity(0.15))
                    .frame(width: 52, height: 52)
                Circle()
                    .strokeBorder(cluster.color.opacity(0.4), lineWidth: 0.75)
                    .frame(width: 52, height: 52)
                Image(systemName: cluster.icon)
                    .font(.system(size: 20, weight: .thin))
                    .foregroundStyle(cluster.color)
            }

            // Name
            Text(cluster.name)
                .font(CosmicFont.heading(13, weight: .regular))
                .foregroundStyle(Color.cosmicGold.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // Progress badge
            Text(cluster.progressLabel)
                .font(CosmicFont.mono(11))
                .foregroundStyle(cluster.color.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(cluster.color.opacity(0.12), in: Capsule())
                .overlay(Capsule().strokeBorder(cluster.color.opacity(0.25), lineWidth: 0.5))
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(cluster.color.opacity(pressed ? 0.1 : 0.05))
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    cluster.isFullyDone
                        ? Color.cosmicGold.opacity(0.55)
                        : cluster.color.opacity(0.22),
                    lineWidth: cluster.isFullyDone ? 1 : 0.75
                )
        }
        .shadow(color: cluster.color.opacity(pressed ? 0.2 : 0.0), radius: 10)
        .scaleEffect(pressed ? 0.95 : 1.0)
        .animation(.spring(duration: 0.25, bounce: 0.3), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded   { _ in pressed = false }
        )
    }
}

// MARK: - Cluster Detail View

private struct ClusterDetailView: View {
    let cluster: QuizCluster
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.obsidian.ignoresSafeArea()
            StarfieldView(starCount: 50).ignoresSafeArea().opacity(0.3)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    clusterHeader
                        .padding(.top, 16)
                        .padding(.bottom, 28)

                    GoldLine()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    quizGrid
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    dismiss()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .light))
                        Text("Quizzes")
                            .font(CosmicFont.label(10))
                            .tracking(2)
                    }
                    .foregroundStyle(Color.cosmicGold.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Cluster Header

    private var clusterHeader: some View {
        VStack(spacing: 12) {
            // Large icon
            ZStack {
                Circle()
                    .fill(cluster.color.opacity(0.12))
                    .frame(width: 72, height: 72)
                Circle()
                    .strokeBorder(cluster.color.opacity(0.4), lineWidth: 1)
                    .frame(width: 72, height: 72)
                Image(systemName: cluster.icon)
                    .font(.system(size: 28, weight: .thin))
                    .foregroundStyle(cluster.color)
            }

            Text(cluster.name)
                .font(CosmicFont.display(24))
                .foregroundStyle(Color.cosmicGold.opacity(0.9))
                .tracking(1)

            // Progress arc + label
            HStack(spacing: 12) {
                ProgressArc(
                    value: Double(cluster.completedCount),
                    total: Double(cluster.totalCount),
                    color: cluster.color
                )
                .frame(width: 28, height: 28)

                Text("\(cluster.completedCount) von \(cluster.totalCount) abgeschlossen")
                    .font(CosmicFont.mono(11))
                    .foregroundStyle(cluster.color.opacity(0.7))
            }
        }
        .padding(.horizontal, 32)
    }

    // MARK: Quiz Grid (2 columns of rectangular tiles)

    private var quizGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(cluster.quizzes) { quiz in
                QuizTile(quiz: quiz, clusterColor: cluster.color)
            }
        }
    }
}

// MARK: - Progress Arc

private struct ProgressArc: View {
    let value: Double
    let total: Double
    let color: Color

    private var fraction: Double { total > 0 ? value / total : 0 }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: 2.5)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(color.opacity(0.8), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Quiz Tile

private struct QuizTile: View {
    let quiz: Quiz
    let clusterColor: Color

    @State private var appeared = false

    var body: some View {
        ZStack {
            tileBackground
            tileContent
        }
        .frame(height: 108)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(tileStroke)
        .shadow(color: tileShadow, radius: 8)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.92)
        .onAppear {
            withAnimation(.spring(duration: 0.55).delay(Double.random(in: 0...0.25))) {
                appeared = true
            }
        }
    }

    // MARK: - Visual states

    @ViewBuilder
    private var tileBackground: some View {
        switch quiz.status {
        case .completed:
            Color.cosmicGold.opacity(0.07)
        case .available:
            clusterColor.opacity(0.07)
        case .locked:
            Color.cosmicAsh.opacity(0.5)
        }
    }

    @ViewBuilder
    private var tileStroke: some View {
        switch quiz.status {
        case .completed:
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.cosmicGold.opacity(0.9), Color.cosmicGold.opacity(0.5)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.25
                )
        case .available:
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(clusterColor.opacity(0.45), lineWidth: 0.75)
        case .locked:
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 0.5)
        }
    }

    private var tileShadow: Color {
        switch quiz.status {
        case .completed: return Color.cosmicGold.opacity(0.12)
        case .available: return clusterColor.opacity(0.08)
        case .locked:    return .clear
        }
    }

    @ViewBuilder
    private var tileContent: some View {
        switch quiz.status {

        case .completed:
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.cosmicGold)
                    Spacer()
                    // Subtle radiant badge
                    Text("✓")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.cosmicGold.opacity(0.5))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.cosmicGold.opacity(0.1), in: Capsule())
                        .overlay(Capsule().strokeBorder(Color.cosmicGold.opacity(0.3), lineWidth: 0.5))
                }
                Spacer()
                Text(quiz.name)
                    .font(CosmicFont.heading(12, weight: .regular))
                    .foregroundStyle(Color.cosmicGold.opacity(0.9))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(quiz.questionCount) Fragen")
                    .font(CosmicFont.mono(10))
                    .foregroundStyle(Color.cosmicGold.opacity(0.4))
            }
            .padding(14)

        case .available:
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "play.circle")
                    .font(.system(size: 14, weight: .thin))
                    .foregroundStyle(clusterColor.opacity(0.8))
                Spacer()
                Text(quiz.name)
                    .font(CosmicFont.heading(12, weight: .regular))
                    .foregroundStyle(clusterColor.opacity(0.9))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(quiz.questionCount) Fragen")
                    .font(CosmicFont.mono(10))
                    .foregroundStyle(clusterColor.opacity(0.5))
            }
            .padding(14)

        case .locked:
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 18, weight: .thin))
                    .foregroundStyle(Color.white.opacity(0.15))
                Text("Gesperrt")
                    .font(CosmicFont.label(9))
                    .tracking(2)
                    .foregroundStyle(Color.white.opacity(0.2))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Preview

#Preview("Quizzes Hub") {
    QuizzesView()
        .environment({
            let s = CosmicStore()
            s.profile = .mock
            return s
        }())
}

#Preview("Cluster Detail") {
    NavigationStack {
        ClusterDetailView_Preview()
    }
}

// Workaround: private struct can't be in preview directly
private struct ClusterDetailView_Preview: View {
    var body: some View {
        // inline for preview only
        ZStack {
            Color.obsidian.ignoresSafeArea()
            Text("See ClusterDetailView")
                .foregroundStyle(Color.cosmicGold)
        }
    }
}
