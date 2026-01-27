//
//  ChallengeModel.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import Foundation
import FirebaseFirestore

struct Challenge: Identifiable, Codable {
    @DocumentID var id: String?
    var joinCode: String
    var mode: String
    var originalMode: String
    var goalSteps: Int
    var durationDays: Int
    var status: String
    var createdBy: String
    var playerIds: [String]
    var startDate: Date
    var endDate: Date
    var createdAt: Date
    
    var currentMode: String {
        if originalMode == "social" && playerIds.count == 1 {
            return "solo"
        }
        return mode
    }
    
    var maxPlayers: Int {
        return originalMode == "solo" ? 1 : 2
    }
    
    var isFull: Bool {
        return playerIds.count >= maxPlayers
    }
    
    func canJoin() -> Bool {
        return !isFull && status == "active"
    }
    
    var hasConvertedToSolo: Bool {
        return originalMode == "social" && currentMode == "solo"
    }
    
    init(
        id: String? = nil,
        joinCode: String,
        mode: String,
        originalMode: String? = nil,
        goalSteps: Int,
        durationDays: Int,
        status: String = "active",
        createdBy: String,
        playerIds: [String] = [],
        startDate: Date = Date(),
        endDate: Date,
        createdAt: Date = Date()
    ) {
        self.id = id
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
        self.createdAt = createdAt
    }
}
