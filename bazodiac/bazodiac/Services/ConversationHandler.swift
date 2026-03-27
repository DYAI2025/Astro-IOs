// ConversationHandler.swift
// Bazodiac iOS — Brücke zwischen ElevenLabsService und SwiftUI Views
//
// Kapselt den WebSocket-Lifecycle für Levi und Eve.
// Jede View bekommt ihren eigenen Handler mit Agent-spezifischen Callbacks.

import SwiftUI

// MARK: - Levi Conversation Handler

@MainActor
@Observable
final class LeviConversationHandler: ElevenLabsDelegate {

    var isConnected = false
    var onText: ((String) -> Void)?
    var onPartial: ((String) -> Void)?
    var onError: ((String) -> Void)?

    private let service = ElevenLabsService.shared

    func connect(profile: CosmicProfile?, language: CosmicStore.Language) {
        service.delegate = self
        let context = ElevenLabsService.buildContext(from: profile, language: language)
        service.connect(agent: .levi, userContext: context)
    }

    func send(text: String) {
        service.sendText(text)
    }

    func disconnect() {
        service.disconnect()
        isConnected = false
    }

    // MARK: - ElevenLabsDelegate

    func didReceiveText(_ text: String) {
        onText?(text)
    }

    func didReceivePartialText(_ text: String) {
        onPartial?(text)
    }

    func didConnect(conversationId: String) {
        isConnected = true
    }

    func didDisconnect() {
        isConnected = false
    }

    func didEncounterError(_ error: String) {
        onError?(error)
        isConnected = false
    }
}

// MARK: - Eve Conversation Handler

@MainActor
@Observable
final class EveConversationHandler: ElevenLabsDelegate {

    var isConnected = false
    var onText: ((String) -> Void)?
    var onPartial: ((String) -> Void)?
    var onError: ((String) -> Void)?

    // Eve braucht eigene Service-Instanz (kann parallel zu Levi laufen)
    private let service: ElevenLabsService = {
        // Für parallele Konversationen müsste ElevenLabsService
        // mehrere Instanzen unterstützen. Aktuell: shared singleton.
        // Phase 2: eigene Instanz pro Agent.
        return ElevenLabsService.shared
    }()

    func connect(profile: CosmicProfile?, language: CosmicStore.Language) {
        service.delegate = self
        let context = ElevenLabsService.buildContext(from: profile, language: language)
        service.connect(agent: .eve, userContext: context)
    }

    func send(text: String) {
        service.sendText(text)
    }

    func disconnect() {
        service.disconnect()
        isConnected = false
    }

    // MARK: - ElevenLabsDelegate

    func didReceiveText(_ text: String) {
        onText?(text)
    }

    func didReceivePartialText(_ text: String) {
        onPartial?(text)
    }

    func didConnect(conversationId: String) {
        isConnected = true
    }

    func didDisconnect() {
        isConnected = false
    }

    func didEncounterError(_ error: String) {
        onError?(error)
        isConnected = false
    }
}
