//
//  ChallengeResultPopupViewModel.swift
//  StepGame
//
//  Created by Arwa Alkadi on 07/02/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ChallengeResultPopupViewModel: ObservableObject {

    // MARK: - Types

    enum Mode { case solo, group }
    enum State { case win, lose }
    enum PlayerPlace { case first, second, third }

    struct Row: Identifiable {
        let id = UUID()
        let name: String
        let isMe: Bool
        let avatarImage: String
        let stepsText: String
        let place: PlayerPlace?   // nil for 4th+ OR when losing
    }

    // MARK: - Inputs

    private let challenge: Challenge
    private let me: Player
    private let myParticipant: ChallengeParticipant
    private let participants: [ChallengeParticipant]
    private let playersById: [String: Player]

    // MARK: - Output (UI)

    @Published private(set) var mode: Mode
    @Published private(set) var state: State

    @Published private(set) var titleText: String = ""
    @Published private(set) var footerText: String = ""

    @Published private(set) var rows: [Row] = []          // for group
    @Published private(set) var soloAvatar: String = ""   // for solo

    var showPlaces: Bool { state == .win }

    // MARK: - Init

    init(
        challenge: Challenge,
        me: Player,
        myParticipant: ChallengeParticipant,
        participants: [ChallengeParticipant],
        playersById: [String: Player] = [:]
    ) {
        self.challenge = challenge
        self.me = me
        self.myParticipant = myParticipant
        self.participants = participants
        self.playersById = playersById

        self.mode = (challenge.originalMode == .solo || challenge.maxPlayers == 1) ? .solo : .group

        let result = Self.computeResult(
            challenge: challenge,
            myParticipant: myParticipant,
            participants: participants
        )
        self.state = result.state

        buildUI()
    }

    // MARK: - Main builder

    private func buildUI() {
        titleText = (state == .win) ? "Well Done!" : "Oops!"

        let goal = challenge.goalSteps
        let days = challenge.durationDays

        switch mode {
        case .solo:
            soloAvatar = avatarAsset(for: me.characterType, state: (state == .win ? .active : .lazy))
            footerText = (state == .win)
            ? "\(goal.formatted()) Steps in \(days) Days"
            : "You didn’t complete the \(goal.formatted())\nsteps in \(days) days.. Try again!"

        case .group:
            footerText = (state == .win)
            ? "\(goal.formatted()) Steps in \(days) Days"
            : "No one completed the \(goal.formatted())\nsteps in \(days) days"

            rows = buildGroupRows()
        }
    }

    // MARK: - Group rows

    private func buildGroupRows() -> [Row] {
        let myId = me.id ?? ""   // ✅ Player.id Optional

        let sorted = participants.sorted { $0.steps > $1.steps }

        return sorted.enumerated().map { idx, part in
            let isMeRow = (part.playerId == myId)

            let player = playersById[part.playerId] ?? (isMeRow ? me : nil)

            let displayName = player?.name ?? (isMeRow ? me.name : shortId(part.playerId))
            let avatar = avatarAsset(for: player?.characterType ?? .character1, state: .normal)

            let place: PlayerPlace? = {
                guard state == .win else { return nil }
                switch idx {
                case 0: return .first
                case 1: return .second
                case 2: return .third
                default: return nil
                }
            }()

            return Row(
                name: displayName,
                isMe: isMeRow,
                avatarImage: avatar,
                stepsText: "\(part.steps.formatted()) Steps",
                place: place
            )
        }
    }

    // MARK: - Result logic

    private struct Result {
        let state: State
    }

    private static func computeResult(
        challenge: Challenge,
        myParticipant: ChallengeParticipant,
        participants: [ChallengeParticipant]
    ) -> Result {

        let goal = max(challenge.goalSteps, 1)
        let isSolo = (challenge.originalMode == .solo || challenge.maxPlayers == 1)

        if isSolo {
            return Result(state: myParticipant.steps >= goal ? .win : .lose)
        } else {
            let someoneReached = participants.contains { $0.steps >= goal }
            return Result(state: someoneReached ? .win : .lose)
        }
    }

    // MARK: - Helpers

    private func avatarAsset(for type: CharacterType, state: CharacterState) -> String {
        // إذا عندك assets مثل: character1_avatar / character2_avatar ...
        return "\(type.rawValue)_avatar"

        // لو تبين حسب state:
        // return type.imageKey(state: state)
    }

    private func shortId(_ id: String) -> String {
        if id.count <= 6 { return id }
        let start = id.prefix(3)
        let end = id.suffix(3)
        return "\(start)...\(end)"
    }
}
