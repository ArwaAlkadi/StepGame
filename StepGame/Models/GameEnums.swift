//
//  GameEnums.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import Foundation

enum ChallengeMode: String, Codable {
    case solo
    case social
}

enum ChallengeStatus: String, Codable {
    case active
    case completed
    case cancelled
}

enum CharacterType: String, Codable {
    case character1
    case character2
    case character3
    
    func image(state: CharacterState) -> String {
        let prefix = self.rawValue.capitalized
        let suffix = state.rawValue.capitalized
        return "\(prefix)\(suffix)"
    }
}

enum CharacterState: String, Codable {
    case active
    case normal
    case tired
}

enum PuzzleMode: String, Codable {
    case attack
    case defense
}

struct PuzzleEffect: Codable {
    var targetPlayerId: String
    var attackerId: String
    var attackTime: TimeInterval
    var appliedAt: Date
    var expiresAt: Date
    var isActive: Bool
}
