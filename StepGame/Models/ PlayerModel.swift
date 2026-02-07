//
//  PlayerModel.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import Foundation
import FirebaseFirestore
import Combine

// MARK: - Enums

enum ChallengeMode: String, Codable {
    case solo
    case social
}

enum ChallengeStatus: String, Codable {
    case waiting
    case active
    case ended
}

enum PuzzleMode: String, Codable {
    case attack
    case defense
}

enum CharacterType: String, Codable, CaseIterable {
    case character1, character2, character3
    func imageKey(state: CharacterState) -> String { "\(rawValue)_\(state.rawValue)" }
}

enum CharacterState: String, Codable, CaseIterable {
    case active
    case normal
    case lazy
}

// MARK: - Player

struct Player: Identifiable, Codable {
    @DocumentID var id: String?

    var name: String

    var totalChallenges: Int
    var completedChallenges: Int
    var totalSteps: Int

    var characterType: CharacterType

    var lastUpdated: Date
    var createdAt: Date

    init(
        id: String? = nil,
        name: String,
        totalChallenges: Int = 0,
        completedChallenges: Int = 0,
        totalSteps: Int = 0,
        characterType: CharacterType = .character1,
        lastUpdated: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.totalChallenges = totalChallenges
        self.completedChallenges = completedChallenges
        self.totalSteps = totalSteps
        self.characterType = characterType
        self.lastUpdated = lastUpdated
        self.createdAt = createdAt
    }
}

// MARK: - Challenge

struct Challenge: Identifiable, Codable {
    @DocumentID var id: String?

    var name: String
    var joinCode: String

    var mode: ChallengeMode
    var originalMode: ChallengeMode

    var goalSteps: Int
    var durationDays: Int
    var status: ChallengeStatus

    var createdBy: String
    var playerIds: [String]

    var startDate: Date
    var endDate: Date
    var extensionSeconds: Int

    var createdAt: Date
    var startedAt: Date? = nil

    var effectiveEndDate: Date {
        endDate.addingTimeInterval(TimeInterval(extensionSeconds))
    }

    var currentMode: ChallengeMode {
        if originalMode == .social && playerIds.count == 1 { return .solo }
        return mode
    }

    var maxPlayers: Int { originalMode == .solo ? 1 : 2 }
    var isFull: Bool { playerIds.count >= maxPlayers }

    func canJoin() -> Bool {
        !isFull && (status == .active || status == .waiting)
    }

    init(
        id: String? = nil,
        name: String,
        joinCode: String,
        mode: ChallengeMode,
        originalMode: ChallengeMode? = nil,
        goalSteps: Int,
        durationDays: Int,
        status: ChallengeStatus = .waiting,
        createdBy: String,
        playerIds: [String] = [],
        startDate: Date = Date(),
        endDate: Date,
        extensionSeconds: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.joinCode = joinCode
        self.mode = mode
        self.originalMode = originalMode ?? mode
        self.goalSteps = goalSteps
        self.durationDays = durationDays
        self.status = status
        self.createdBy = createdBy
        self.playerIds = playerIds
        self.startDate = startDate
        self.endDate = endDate
        self.extensionSeconds = extensionSeconds
        self.createdAt = createdAt
    }
}

// MARK: - ChallengeParticipant

struct ChallengeParticipant: Identifiable, Codable {
    @DocumentID var id: String?

    var challengeId: String
    var playerId: String

    var steps: Int
    var progress: Double
    var characterState: CharacterState

    var lastUpdated: Date
    var createdAt: Date

    var sabotageState: CharacterState?
    var sabotageExpiresAt: Date?
    var sabotageByPlayerId: String?

    init(
        id: String? = nil,
        challengeId: String,
        playerId: String,
        steps: Int = 0,
        progress: Double = 0.0,
        characterState: CharacterState = .normal,
        lastUpdated: Date = Date(),
        createdAt: Date = Date(),
        sabotageState: CharacterState? = nil,
        sabotageExpiresAt: Date? = nil,
        sabotageByPlayerId: String? = nil
    ) {
        self.id = id
        self.challengeId = challengeId
        self.playerId = playerId
        self.steps = steps
        self.progress = progress
        self.characterState = characterState
        self.lastUpdated = lastUpdated
        self.createdAt = createdAt
        self.sabotageState = sabotageState
        self.sabotageExpiresAt = sabotageExpiresAt
        self.sabotageByPlayerId = sabotageByPlayerId
    }

    func effectiveState(now: Date = Date()) -> CharacterState {
        if let s = sabotageState,
           let exp = sabotageExpiresAt,
           now < exp { return s }
        return characterState
    }
}

// MARK: - PuzzleEffect (placeholder)

struct PuzzleEffect: Identifiable, Codable {
    @DocumentID var id: String?

    var challengeId: String
    var targetPlayerId: String
    var attackerId: String
    var mode: PuzzleMode
    var attackTime: TimeInterval
    var appliedAt: Date
    var expiresAt: Date
    var isActive: Bool
}
