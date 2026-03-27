// BirthFormView.swift
// Bazodiac iOS — Cosmic Birth Data Entry
//
// Elegant form with dark luxury aesthetic.
// Staggered field reveal, gold hairline dividers, animated CTA.

import SwiftUI
import UIKit

struct BirthFormView: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    @State private var appeared = false

    var body: some View {
        ZStack {
            // Background
            theme.background.ignoresSafeArea()
            StarfieldView(starCount: 60, goldTint: true)
                .ignoresSafeArea()
                .opacity(0.5)

            // Radial glow behind form
            RadialGradient(
                colors: [Color.cosmicGold.opacity(0.04), .clear],
                center: .init(x: 0.5, y: 0.3),
                startRadius: 0,
                endRadius: 280
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    formHeader
                        .padding(.top, 70)
                        .padding(.bottom, 36)

                    formFields
                        .padding(.horizontal, 24)

                    calculateButton
                        .padding(.horizontal, 24)
                        .padding(.top, 36)
                        .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.9).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Header

    private var formHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .thin))
                .foregroundStyle(theme.textSecondary)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.spring(duration: 1).delay(0.2), value: appeared)

            Text("Kosmischer Blueprint")
                .font(CosmicFont.display(30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.textPrimary, theme.textSecondary],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .tracking(2)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.spring(duration: 1.1).delay(0.35), value: appeared)

            Text("Gib deine Geburtsdaten ein, um dein\npersönliches kosmisches Koordinatensystem zu berechnen.")
                .font(CosmicFont.bodySerif(13))
                .foregroundStyle(Color.cosmicGold.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.top, 4)
                .opacity(appeared ? 1 : 0)
                .animation(.easeIn(duration: 1).delay(0.55), value: appeared)
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(spacing: 0) {
            NameField()
            GoldLine()
            BirthDateField()
            GoldLine()
            BirthTimeField()
            GoldLine()
            BirthPlaceField()
        }
        .cosmicCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(duration: 1).delay(0.65), value: appeared)
    }

    // MARK: - Calculate Button

    private var calculateButton: some View {
        CalculateButton()
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 14)
            .animation(.spring(duration: 0.9).delay(0.85), value: appeared)
    }
}

// MARK: - Individual Fields

private struct NameField: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        @Bindable var store = store
        FormRow(icon: "person", label: "Name") {
            TextField("Dein Name", text: $store.birthData.name)
                .font(CosmicFont.heading(15, weight: .light))
                .foregroundStyle(theme.textPrimary.opacity(0.85))
                .tint(Color.cosmicGold)
                .submitLabel(.next)
        }
    }
}

private struct BirthDateField: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        @Bindable var store = store
        FormRow(icon: "calendar", label: "Geburtsdatum") {
            DatePicker(
                "",
                selection: $store.birthData.birthDate,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(Color.cosmicGold)
            .preferredColorScheme(theme.isDark ? .dark : .light)
            .scaleEffect(0.9, anchor: .trailing)
        }
    }
}

private struct BirthTimeField: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        @Bindable var store = store
        FormRow(icon: "clock", label: "Geburtszeit") {
            DatePicker(
                "",
                selection: $store.birthData.birthDate,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(Color.cosmicGold)
            .preferredColorScheme(theme.isDark ? .dark : .light)
            .scaleEffect(0.9, anchor: .trailing)
        }
    }
}

/// PH-2 BEHOBEN: PlaceSearchField ersetzt einfaches TextField
/// Liefert lat/lon/timezone via MKLocalSearch + CLGeocoder
private struct BirthPlaceField: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        @Bindable var store = store
        PlaceSearchField(store: store)
    }
}

// MARK: - Form Row Container

private struct FormRow<Content: View>: View {
    let icon: String
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .thin))
                .foregroundStyle(Color.cosmicGold.opacity(0.45))
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .goldLabel(0.45)

                content
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Calculate Button

private struct CalculateButton: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme
    @State private var pulsing = false

    var body: some View {
        Button {
            guard !store.isLoading else { return }
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            Task { await store.submitBirthData() }
        } label: {
            ZStack {
                // Pulse aura
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Color.cosmicGold.opacity(pulsing ? 0.35 : 0.08), lineWidth: 1.5)
                    .scaleEffect(pulsing ? 1.05 : 1.0)
                    .animation(
                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: pulsing
                    )

                // Button base
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Color.cosmicGold.opacity(0.25), lineWidth: 0.75)
                    .background(
                        Color.cosmicGold.opacity(0.05)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    )

                if store.isLoading {
                    HStack(spacing: 10) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.cosmicGold.opacity(0.7))
                            .scaleEffect(0.7)
                        Text("Berechnung läuft …")
                            .font(CosmicFont.label(10))
                            .tracking(3)
                            .foregroundStyle(theme.textSecondary)
                    }
                } else {
                    VStack(spacing: 4) {
                        Text("Kosmischen Blueprint berechnen")
                            .font(CosmicFont.label(10))
                            .tracking(3)
                            .foregroundStyle(Color.cosmicGold.opacity(0.8))

                        Text("Western · BaZi · Wu-Xing")
                            .font(CosmicFont.label(8))
                            .tracking(2)
                            .foregroundStyle(theme.textTertiary)
                    }
                }
            }
            .frame(height: 60)
        }
        .buttonStyle(.plain)
        .disabled(store.isLoading || store.birthData.name.isEmpty)
        .opacity(store.birthData.name.isEmpty ? 0.4 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: store.birthData.name.isEmpty)
        .onAppear { pulsing = true }
    }
}

// MARK: - Preview

#Preview {
    BirthFormView()
        .environment(CosmicStore())
}
