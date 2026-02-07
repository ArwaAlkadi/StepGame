//
//  WaitingViewModel.swift
//  StepGame
//
//  Created by Arwa Alkadi on 30/01/2026.
//

import Foundation
import SwiftUI
import UIKit
import Combine
import FirebaseFirestore

struct LobbyPlayer: Identifiable, Equatable {
    let id: String
    let name: String
    let isMe: Bool
    let avatarAsset: String
}

final class WaitingRoomViewModel: ObservableObject {

    // UI
    @Published private(set) var lobbyPlayers: [LobbyPlayer] = []
    @Published private(set) var isHost: Bool = false
    @Published private(set) var isStarting: Bool = false

    // State
    @Published private(set) var challenge: Challenge? = nil
    @Published private(set) var participants: [ChallengeParticipant] = []

    private weak var session: GameSession?
    private let firebase = FirebaseService.shared

    private var challengeListener: ListenerRegistration?
    private var participantsListener: ListenerRegistration?

    deinit {
        unbind()
    }

    // MARK: - Computed UI (for View)

    var titleText: String {
        challenge?.name ?? "Waiting..."
    }

    var goalStepsText: String {
        guard let ch = challenge else { return "" }
        return "\(ch.goalSteps.formatted()) Steps"
    }

    var joinCodeText: String {
        (challenge?.joinCode ?? "").uppercased()
    }

    var footerTextForPlayer: String {
        "Waiting for the host to\nstart the challenge"
    }

    /// السماح للهوست يبدأ:
    /// - لازم تكون التشالنج waiting
    /// - وإذا Social: لازم فيه 2 لاعبين على الأقل
    var canStart: Bool {
        guard let ch = challenge else { return false }
        guard ch.status == .waiting else { return false }

        if ch.originalMode == .social {
            return ch.playerIds.count >= 2
        }
        return true
    }

    // MARK: - Bind / Unbind

    func bind(session: GameSession) {
        self.session = session

        unbind() // remove old listeners if any

        self.challenge = session.challenge
        refreshUI()

        guard let chId = session.challenge?.id else { return }

        challengeListener = firebase.listenChallenge(challengeId: chId) { [weak self] updated in
            guard let self else { return }
            DispatchQueue.main.async {
                self.challenge = updated
                self.session?.challenge = updated
                self.refreshUI()
            }
        }

        participantsListener = firebase.listenParticipants(challengeId: chId) { [weak self] list in
            guard let self else { return }
            DispatchQueue.main.async {
                self.participants = list
                self.refreshUI()
            }
        }
    }

    /// مهم: لازم تكون مو private لأن الـ View يناديها في onDisappear
    func unbind() {
        challengeListener?.remove()
        challengeListener = nil

        participantsListener?.remove()
        participantsListener = nil
    }

    // MARK: - Actions

    func copyJoinCode() {
        UIPasteboard.general.string = joinCodeText
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func startChallenge() async {
        guard canStart else { return }
        guard let session else { return }

        DispatchQueue.main.async { self.isStarting = true }
        defer { DispatchQueue.main.async { self.isStarting = false } }

        await session.startSelectedChallengeIfHost()
        // listeners بيرجعون يحدّثون status تلقائياً لما يصير active
    }

    // MARK: - UI Update

    private func refreshUI() {
        guard let session else { return }
        guard let ch = challenge else { return }

        let myId = session.uid ?? session.player?.id ?? ""
        let host = (ch.createdBy == myId)

        let players = makeLobbyPlayers(challenge: ch, session: session)

        // publish on main
        DispatchQueue.main.async {
            self.isHost = host
            self.lobbyPlayers = players
        }
    }

    private func makeLobbyPlayers(challenge: Challenge, session: GameSession) -> [LobbyPlayer] {
        let ids = challenge.playerIds
        let me = session.player
        let myId = me?.id ?? session.uid ?? ""

        return ids.enumerated().map { idx, pid in
            if pid == myId, let me {
                return LobbyPlayer(
                    id: pid,
                    name: me.name,
                    isMe: true,
                    avatarAsset: me.characterType.imageKey(state: .normal)
                )
            } else {
                return LobbyPlayer(
                    id: pid,
                    name: "Player \(idx + 1)",
                    isMe: false,
                    avatarAsset: "character1_normal"
                )
            }
        }
    }
}
