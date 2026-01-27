//
//   PlayerModel.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import Foundation
import FirebaseFirestore

struct Player: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var steps: Int
    var progress: Double
    var characterType: String
    var characterState: String
    var totalChallenges: Int
    var completedChallenges: Int
    var totalSteps: Int
    var lastUpdated: Date
    var createdAt: Date
    
    init(
        id: String? = nil,
        name: String,
        steps: Int = 0,
        progress: Double = 0.0,
        characterType: String = "character1",
        characterState: String = "normal",
        totalChallenges: Int = 0,
        completedChallenges: Int = 0,
        totalSteps: Int = 0,
        lastUpdated: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.steps = steps
        self.progress = progress
        self.characterType = characterType
        self.characterState = characterState
        self.totalChallenges = totalChallenges
        self.completedChallenges = completedChallenges
        self.totalSteps = totalSteps
        self.lastUpdated = lastUpdated
        self.createdAt = createdAt
    }
}
