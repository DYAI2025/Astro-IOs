// bazodiacApp.swift
// Bazodiac iOS — App Entry Point
//
// Phase-based root navigation:
//   .splash     → SplashView  (cinematic intro)
//   .birthForm  → BirthFormView (first-launch data entry)
//   .dashboard  → MainTabView  (main experience)
//
// No SwiftData — replaced by CosmicStore (@Observable).
// CosmicStore injected as @State at root for full app lifetime.

import SwiftUI

@main
struct BazodiacApp: App {

    // @Observable store — created once, lives for app lifetime
    @State private var cosmicStore = CosmicStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(cosmicStore)
                .preferredColorScheme(.dark)   // Always dark — no light mode
        }
    }
}

// MARK: - Root View

/// Phase-driven root navigator — no NavigationStack needed for this linear flow.
struct RootView: View {
    @Environment(CosmicStore.self) private var store

    var body: some View {
        ZStack {
            Color.obsidian.ignoresSafeArea()

            switch store.appPhase {
            case .splash:
                SplashView()
                    .transition(.opacity)

            case .birthForm:
                BirthFormView()
                    .transition(
                        .asymmetric(
                            insertion: .push(from: .bottom),
                            removal:   .opacity
                        )
                    )

            case .dashboard:
                MainTabView()
                    .transition(
                        .asymmetric(
                            insertion: .push(from: .trailing),
                            removal:   .opacity
                        )
                    )
            }
        }
        .animation(.easeInOut(duration: 0.6), value: store.appPhase)
    }
}
