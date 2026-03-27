// PlaceSearchService.swift
// Bazodiac iOS — Ortssuche mit MKLocalSearch + CLGeocoder
//
// Löst PH-2: BirthFormView braucht lat/lon/timezone aus Freitext-Ortsangabe.
// Kein API-Key nötig — nutzt Apple MapKit (MKLocalSearchCompleter).

import MapKit
import CoreLocation
import SwiftUI

// MARK: - Place Result

struct PlaceResult: Identifiable, Equatable {
    let id = UUID()
    let name: String        // "München, Deutschland"
    let latitude: Double
    let longitude: Double
    let timezone: String    // IANA: "Europe/Berlin"
}

// MARK: - Place Completer (Autocomplete)

@MainActor
@Observable
final class PlaceCompleter: NSObject {
    var query: String = "" {
        didSet { if query != oldValue { completer.queryFragment = query } }
    }
    var results: [MKLocalSearchCompletion] = []
    var isSearching = false
    var selectedPlace: PlaceResult?
    var errorMessage: String?

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    // MARK: - Ort auflösen (Completion → lat/lon/timezone)

    func resolve(_ completion: MKLocalSearchCompletion) async {
        isSearching = true
        errorMessage = nil

        let request = MKLocalSearch.Request(completion: completion)
        let search  = MKLocalSearch(request: request)

        do {
            let response = try await search.start()
            guard let item = response.mapItems.first else {
                errorMessage = "Ort nicht gefunden"
                isSearching = false
                return
            }

            let coord = item.placemark.coordinate
            let tz    = await resolveTimezone(coord)
            let label = buildLabel(item.placemark, fallback: completion.title)

            selectedPlace = PlaceResult(
                name: label,
                latitude: coord.latitude,
                longitude: coord.longitude,
                timezone: tz
            )
        } catch {
            errorMessage = "Suche fehlgeschlagen: \(error.localizedDescription)"
        }

        isSearching = false
    }

    // MARK: - Timezone aus Koordinaten

    private func resolveTimezone(_ coord: CLLocationCoordinate2D) async -> String {
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let tz = placemarks.first?.timeZone {
                return tz.identifier
            }
        } catch {}
        // Fallback: grobe Schätzung aus Längengrad
        let offsetHours = Int(coord.longitude / 15)
        return "Etc/GMT\(offsetHours >= 0 ? "-" : "+")\(abs(offsetHours))"
    }

    // MARK: - Lesbares Label

    private func buildLabel(_ placemark: CLPlacemark, fallback: String) -> String {
        var parts: [String] = []
        if let city    = placemark.locality           { parts.append(city) }
        if let country = placemark.country            { parts.append(country) }
        return parts.isEmpty ? fallback : parts.joined(separator: ", ")
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension PlaceCompleter: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            self.results = completer.results
        }
    }
    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor in
            self.results = []
        }
    }
}

// MARK: - PlaceSearchField View

struct PlaceSearchField: View {
    @Bindable var store: CosmicStore
    @State private var completer = PlaceCompleter()
    @State private var showSuggestions = false
    @FocusState private var focused: Bool
    @Environment(\.cosmicTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Eingabezeile ──────────────────────────────────────────
            HStack(spacing: 14) {
                Image(systemName: completer.isSearching ? "arrow.clockwise" : "mappin.circle")
                    .font(.system(size: 14, weight: .thin))
                    .foregroundStyle(theme.gold.opacity(0.45))
                    .frame(width: 22)
                    .symbolEffect(.rotate, isActive: completer.isSearching)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Geburtsort")
                        .goldLabel(0.45)

                    TextField("Stadt, Land", text: $completer.query)
                        .font(CosmicFont.heading(15, weight: .light))
                        .foregroundStyle(theme.textPrimary)
                        .tint(theme.gold)
                        .focused($focused)
                        .submitLabel(.done)
                        .onChange(of: focused) { _, isFocused in
                            withAnimation(.spring(duration: 0.3)) {
                                showSuggestions = isFocused && !completer.results.isEmpty
                            }
                        }
                        .onChange(of: completer.results) { _, results in
                            withAnimation(.spring(duration: 0.2)) {
                                showSuggestions = focused && !results.isEmpty
                            }
                        }
                }

                // Häkchen wenn Ort gewählt
                if completer.selectedPlace != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .thin))
                        .foregroundStyle(Color.elementWood.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            // ── Autocomplete-Dropdown ─────────────────────────────────
            if showSuggestions && !completer.results.isEmpty {
                VStack(spacing: 0) {
                    ForEach(completer.results.prefix(5), id: \.title) { result in
                        Button {
                            focused = false
                            showSuggestions = false
                            completer.query = result.title + (result.subtitle.isEmpty ? "" : ", \(result.subtitle)")
                            Task {
                                await completer.resolve(result)
                                if let place = completer.selectedPlace {
                                    store.birthData.birthPlace = place.name
                                    store.birthData.latitude   = place.latitude
                                    store.birthData.longitude  = place.longitude
                                    store.birthData.timezone   = place.timezone
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 10, weight: .thin))
                                    .foregroundStyle(theme.gold.opacity(0.4))
                                    .frame(width: 16)

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(result.title)
                                        .font(CosmicFont.heading(13, weight: .light))
                                        .foregroundStyle(theme.textPrimary.opacity(0.9))
                                    if !result.subtitle.isEmpty {
                                        Text(result.subtitle)
                                            .font(CosmicFont.mono(10))
                                            .foregroundStyle(theme.textTertiary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if result.title != completer.results.prefix(5).last?.title {
                            Rectangle()
                                .fill(theme.goldBorder)
                                .frame(height: 0.5)
                                .padding(.leading, 52)
                        }
                    }
                }
                .background(theme.surfaceElevated.opacity(0.98))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(theme.goldBorder, lineWidth: 0.75)
                )
                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal:   .opacity
                ))
                .zIndex(10)
            }

            // Fehlermeldung
            if let err = completer.errorMessage {
                Text(err)
                    .font(CosmicFont.mono(10))
                    .foregroundStyle(Color.elementFire.opacity(0.7))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }
        }
        .onAppear {
            // Bestehenden Wert übernehmen
            if !store.birthData.birthPlace.isEmpty {
                completer.query = store.birthData.birthPlace
                if store.birthData.latitude != 0 {
                    completer.selectedPlace = PlaceResult(
                        name: store.birthData.birthPlace,
                        latitude: store.birthData.latitude,
                        longitude: store.birthData.longitude,
                        timezone: store.birthData.timezone
                    )
                }
            }
        }
    }
}
