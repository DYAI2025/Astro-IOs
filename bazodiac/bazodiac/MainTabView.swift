// MainTabView.swift
// Bazodiac iOS — Custom Tab Bar Navigation
//
// Custom tab bar design with gold glow on active tab.
// Liquid Glass background on iOS 26+ (deployment target).

import SwiftUI
import UIKit

struct MainTabView: View {
    @Environment(CosmicStore.self) private var store

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Page content ──────────────────────────────────────────────
            tabContent
                .ignoresSafeArea(edges: .bottom)

            // ── Custom tab bar ─────────────────────────────────────────────
            CosmicTabBar()
                .padding(.bottom, 0)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch store.selectedTab {
        case .home:    HomeView()
        case .chart:   WesternChartView()
        case .bazi:    BaZiView()
        case .quizzes: QuizzesView()
        case .levi:    LeviView()
        case .eve:     EveView()
        }
    }
}

// MARK: - Custom Tab Bar

private struct CosmicTabBar: View {
    @Environment(CosmicStore.self) private var store

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CosmicStore.Tab.allCases, id: \.self) { tab in
                TabBarItem(tab: tab, isSelected: store.selectedTab == tab) {
                    let impact = UISelectionFeedbackGenerator()
                    impact.selectionChanged()
                    withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                        store.selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, max(34, 20))  // respect home indicator
        .background {
            // iOS 26.2 deployment target — Liquid Glass always available
            GlassEffectContainer(spacing: 0) {
                Color.clear
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Tab Bar Item

private struct TabBarItem: View {
    let tab: CosmicStore.Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                ZStack {
                    // Active glow behind icon
                    if isSelected {
                        Circle()
                            .fill(Color.cosmicGold.opacity(0.12))
                            .frame(width: 36, height: 36)
                            .blur(radius: 8)
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: isSelected ? .regular : .thin))
                        .foregroundStyle(isSelected
                            ? Color.cosmicGold
                            : Color.cosmicGold.opacity(0.35)
                        )
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .symbolEffect(.bounce, value: isSelected)
                }
                .frame(width: 40, height: 34)

                Text(tab.label)
                    .font(CosmicFont.label(8))
                    .tracking(1.5)
                    .foregroundStyle(isSelected
                        ? Color.cosmicGold.opacity(0.8)
                        : Color.cosmicGold.opacity(0.28)
                    )
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.3, bounce: 0.3), value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environment({
            let s = CosmicStore()
            s.profile = .mock
            return s
        }())
}
