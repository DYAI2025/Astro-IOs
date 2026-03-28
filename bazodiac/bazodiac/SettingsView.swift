// SettingsView.swift
// Bazodiac iOS — Settings Dropdown Menu
//
// Zugang über Gear-Icon im Atlas-Header.
// Menüpunkte: Profil, Subscription, Hell/Dunkel, Sprache, Support, FAQ, Abmelden.
// Profil-Unterseite zeigt alle hinterlegten Daten.

import SwiftUI
import UIKit

// MARK: - Settings Sheet

struct SettingsSheet: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    @State private var showProfile = false
    @State private var showSubscription = false
    @State private var showFAQ = false
    @State private var showSupport = false
    @State private var showSignOutConfirm = false

    var body: some View {
        NavigationStack {
            List {
                // ── Profil ──────────────────────────────────────
                Section {
                    Button { showProfile = true } label: {
                        settingsRow(icon: "person.circle", label: isDE ? "Profil" : "Profile")
                    }

                    Button { showSubscription = true } label: {
                        settingsRow(icon: "creditcard", label: "Subscription",
                                    detail: isDE ? "Kostenlos" : "Free")
                    }
                }

                // ── Darstellung ─────────────────────────────────
                Section {
                    // Hell/Dunkel
                    Button { store.toggleTheme() } label: {
                        settingsRow(
                            icon: theme.isDark ? "sun.max.fill" : "moon.stars.fill",
                            label: isDE ? "Hell / Dunkel" : "Light / Dark",
                            detail: theme.isDark
                                ? (isDE ? "Dunkel" : "Dark")
                                : (isDE ? "Hell" : "Light")
                        )
                    }

                    // Sprache
                    Button { toggleLanguage() } label: {
                        settingsRow(
                            icon: "globe",
                            label: isDE ? "Sprache" : "Language",
                            detail: isDE ? "Deutsch" : "English"
                        )
                    }
                }

                // ── Hilfe ───────────────────────────────────────
                Section {
                    Button { showSupport = true } label: {
                        settingsRow(icon: "envelope", label: "Support")
                    }

                    Button { showFAQ = true } label: {
                        settingsRow(icon: "questionmark.circle", label: "FAQ")
                    }
                }

                // ── Abmelden ────────────────────────────────────
                Section {
                    Button { showSignOutConfirm = true } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16, weight: .light))
                                .foregroundStyle(Color.elementFire.opacity(0.7))
                                .frame(width: 28)
                            Text(isDE ? "Abmelden" : "Sign Out")
                                .font(CosmicFont.heading(15, weight: .light))
                                .foregroundStyle(Color.elementFire.opacity(0.8))
                            Spacer()
                        }
                    }
                }

                // ── Footer ──────────────────────────────────────
                Section {
                    VStack(spacing: 4) {
                        Text("Bazodiac")
                            .font(CosmicFont.display(16))
                            .foregroundStyle(theme.textTertiary)
                        Text("v1.0.0 · Fusion Astrology")
                            .font(CosmicFont.mono(10))
                            .foregroundStyle(theme.textTertiary.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(theme.background)
            .navigationTitle(isDE ? "Einstellungen" : "Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(theme.textTertiary)
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileDetailView()
                    .environment(store)
                    .environment(\.cosmicTheme, theme)
            }
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
                    .environment(store)
                    .environment(\.cosmicTheme, theme)
            }
            .sheet(isPresented: $showFAQ) {
                FAQView()
                    .environment(\.cosmicTheme, theme)
            }
            .sheet(isPresented: $showSupport) {
                SupportView()
                    .environment(\.cosmicTheme, theme)
            }
            .alert(isDE ? "Wirklich abmelden?" : "Sign out?",
                   isPresented: $showSignOutConfirm) {
                Button(isDE ? "Abmelden" : "Sign Out", role: .destructive) {
                    store.signOut()
                    dismiss()
                }
                Button(isDE ? "Abbrechen" : "Cancel", role: .cancel) {}
            } message: {
                Text(isDE ? "Dein Profil und alle lokalen Daten werden gelöscht." :
                        "Your profile and all local data will be deleted.")
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Helpers

    private var isDE: Bool { store.language == .german }

    private func toggleLanguage() {
        let impact = UISelectionFeedbackGenerator()
        impact.selectionChanged()
        withAnimation(.spring(duration: 0.3)) {
            store.language = store.language == .german ? .english : .german
        }
        PersistenceService.saveLanguage(store.language.rawValue)
    }

    private func settingsRow(icon: String, label: String, detail: String? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(theme.gold.opacity(0.7))
                .frame(width: 28)
            Text(label)
                .font(CosmicFont.heading(15, weight: .light))
                .foregroundStyle(theme.textPrimary)
            Spacer()
            if let detail {
                Text(detail)
                    .font(CosmicFont.mono(12))
                    .foregroundStyle(theme.textTertiary)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .thin))
                .foregroundStyle(theme.textTertiary)
        }
    }
}

// MARK: - Profile Detail View

struct ProfileDetailView: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    private var isDE: Bool { store.language == .german }

    var body: some View {
        NavigationStack {
            List {
                if let p = store.profile {
                    // ── Persönliche Daten ────────────────────────
                    Section(header: Text(isDE ? "PERSÖNLICHE DATEN" : "PERSONAL DATA")) {
                        profileRow(label: isDE ? "Name" : "Name", value: p.birthData.name)
                        profileRow(label: isDE ? "Geburtsdatum" : "Birth Date",
                                   value: p.birthData.birthDate.formatted(.dateTime.day().month(.wide).year()))
                        profileRow(label: isDE ? "Geburtszeit" : "Birth Time",
                                   value: p.birthData.birthDate.formatted(.dateTime.hour().minute()))
                        profileRow(label: isDE ? "Geburtsort" : "Birth Place",
                                   value: p.birthData.birthPlace)
                        profileRow(label: isDE ? "Koordinaten" : "Coordinates",
                                   value: String(format: "%.4f, %.4f", p.birthData.latitude, p.birthData.longitude))
                        profileRow(label: isDE ? "Zeitzone" : "Timezone",
                                   value: p.birthData.timezone)
                    }

                    // ── Western Astrologie ───────────────────────
                    Section(header: Text(isDE ? "WESTERN ASTROLOGIE" : "WESTERN ASTROLOGY")) {
                        profileRow(label: isDE ? "Sonne" : "Sun",
                                   value: "\(p.westernData.sunSign.germanName) \(String(format: "%.1f°", p.westernData.sunDegree))")
                        profileRow(label: isDE ? "Mond" : "Moon",
                                   value: "\(p.westernData.moonSign.germanName) \(String(format: "%.1f°", p.westernData.moonDegree))")
                        profileRow(label: isDE ? "Aszendent" : "Ascendant",
                                   value: "\(p.westernData.ascendant.germanName) \(String(format: "%.1f°", p.westernData.ascendantDegree))")
                        profileRow(label: isDE ? "Planeten" : "Planets",
                                   value: "\(p.westernData.planets.count)")
                    }

                    // ── BaZi ─────────────────────────────────────
                    Section(header: Text("BAZI 四柱命理")) {
                        profileRow(label: isDE ? "Tagesmeister" : "Day Master",
                                   value: "\(p.baziData.day.stem.char) \(p.baziData.day.stem.english)")
                        profileRow(label: isDE ? "Jahrestier" : "Year Animal",
                                   value: "\(p.baziData.year.branch.animal) \(p.baziData.year.branch.char)")
                        profileRow(label: isDE ? "Vier Säulen" : "Four Pillars",
                                   value: "\(p.baziData.year.stem.char)\(p.baziData.year.branch.char) · \(p.baziData.month.stem.char)\(p.baziData.month.branch.char) · \(p.baziData.day.stem.char)\(p.baziData.day.branch.char) · \(p.baziData.hour.stem.char)\(p.baziData.hour.branch.char)")
                    }

                    // ── Wu-Xing ──────────────────────────────────
                    Section(header: Text("WU-XING 五行")) {
                        profileRow(label: isDE ? "Dominantes Element" : "Dominant Element",
                                   value: "\(p.wuxingData.dominant.chineseChar) \(p.wuxingData.dominant.germanName)")
                        profileRow(label: isDE ? "Schwächstes" : "Weakest",
                                   value: "\(p.wuxingData.weakest.chineseChar) \(p.wuxingData.weakest.germanName)")

                        ForEach(CosmicElement.allCases) { el in
                            let val = p.wuxingData.balance[el] ?? 0
                            HStack {
                                Text("\(el.chineseChar) \(el.germanName)")
                                    .font(CosmicFont.heading(14, weight: .light))
                                    .foregroundStyle(theme.textPrimary)
                                Spacer()
                                Text("\(Int(val * 100))%")
                                    .font(CosmicFont.mono(12))
                                    .foregroundStyle(el.color)
                            }
                        }
                    }

                    // ── Account ──────────────────────────────────
                    Section(header: Text(isDE ? "ACCOUNT" : "ACCOUNT")) {
                        profileRow(label: "Subscription",
                                   value: isDE ? "Kostenlos" : "Free")
                        profileRow(label: isDE ? "Mitglied seit" : "Member since",
                                   value: memberSinceDate())
                    }
                } else {
                    Section {
                        Text(isDE ? "Kein Profil vorhanden" : "No profile available")
                            .foregroundStyle(theme.textTertiary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(theme.background)
            .navigationTitle(isDE ? "Profil" : "Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(theme.textTertiary)
                    }
                }
            }
        }
    }

    private func profileRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(CosmicFont.heading(14, weight: .light))
                .foregroundStyle(theme.textSecondary)
            Spacer()
            Text(value)
                .font(CosmicFont.mono(12))
                .foregroundStyle(theme.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func memberSinceDate() -> String {
        // Nutze das BirthData-Erstellungsdatum als Proxy (kein Auth-Datum ohne Supabase)
        let created = UserDefaults.standard.object(forKey: "bazodiac.memberSince") as? Date ?? Date()
        if UserDefaults.standard.object(forKey: "bazodiac.memberSince") == nil {
            UserDefaults.standard.set(Date(), forKey: "bazodiac.memberSince")
        }
        return created.formatted(.dateTime.day().month(.twoDigits).year())
    }
}

// MARK: - Subscription View (Platzhalter)

struct SubscriptionView: View {
    @Environment(CosmicStore.self) private var store
    @Environment(\.cosmicTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    private var isDE: Bool { store.language == .german }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundStyle(theme.gold.opacity(0.6))

                Text(isDE ? "Kostenloser Zugang" : "Free Access")
                    .font(CosmicFont.display(28))
                    .foregroundStyle(theme.textPrimary)

                Text(isDE
                     ? "Du nutzt Bazodiac aktuell kostenlos.\nPremium-Funktionen werden bald verfügbar sein."
                     : "You're using Bazodiac for free.\nPremium features coming soon.")
                    .font(CosmicFont.bodySerif(14))
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)

                Spacer()
                Spacer()
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(theme.background)
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(theme.textTertiary)
                    }
                }
            }
        }
    }
}

// MARK: - FAQ View

struct FAQView: View {
    @Environment(\.cosmicTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    private let faqs: [(q: String, a: String)] = [
        ("Was ist Fusion Astrology?",
         "Bazodiac verbindet westliche Astrologie, chinesisches BaZi und Wu-Xing mathematisch zu einem einzigen Profil. Kein Raten — jede Berechnung ist nachvollziehbar."),
        ("Was ist der Day Pulse / Day Trace?",
         "Dein täglicher Impuls, berechnet aus dem Harmony Index (Kosinus-Ähnlichkeit deiner astrologischen Vektoren). Pulse = ruhiger Tag, Trace = es passiert etwas."),
        ("Wer sind Levi und Eve?",
         "Zwei KI-Begleiter mit dem gleichen Wissen über dein Profil, aber unterschiedlichem Charakter. Levi ist analytisch und klar, Eve ist direkt und ehrlich."),
        ("Sind meine Daten sicher?",
         "Deine Daten bleiben lokal auf deinem Gerät. Keine API-Schlüssel im App-Binary. Berechnungen laufen über verschlüsselte Server-Proxys."),
        ("Muss ich an Astrologie glauben?",
         "Nein. Bazodiac ist ein Denkmodell für Selbstreflexion — ein Placebo für die Seele. Es wirkt, obwohl wir es durch Mathematik entzaubern."),
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(faqs, id: \.q) { faq in
                    DisclosureGroup {
                        Text(faq.a)
                            .font(CosmicFont.bodySerif(14))
                            .foregroundStyle(theme.textSecondary)
                            .lineSpacing(4)
                    } label: {
                        Text(faq.q)
                            .font(CosmicFont.heading(15, weight: .light))
                            .foregroundStyle(theme.textPrimary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(theme.background)
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(theme.textTertiary)
                    }
                }
            }
        }
    }
}

// MARK: - Support View

struct SupportView: View {
    @Environment(\.cosmicTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "envelope.circle")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundStyle(theme.gold.opacity(0.6))

                Text("Support")
                    .font(CosmicFont.display(28))
                    .foregroundStyle(theme.textPrimary)

                Text("hello@bazodiac.com")
                    .font(CosmicFont.mono(14))
                    .foregroundStyle(theme.gold)

                Button {
                    if let url = URL(string: "mailto:hello@bazodiac.com") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("E-Mail schreiben")
                        .font(CosmicFont.label(10))
                        .tracking(3)
                        .foregroundStyle(theme.gold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(theme.goldFaint, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(theme.goldBorder, lineWidth: 0.75))
                }
                .buttonStyle(.plain)

                Spacer()
                Spacer()
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(theme.background)
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(theme.textTertiary)
                    }
                }
            }
        }
    }
}
