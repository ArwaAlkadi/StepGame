//
//   SetupChallengeViewModel.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class SetupChallengeViewModel: ObservableObject {

    // Inputs
    @Published var challengeName: String = ""
    @Published var selectedPeriod: PeriodOption = .threeDays
    @Published var steps: Double = 6000
    @Published var mode: ModeOption = .solo

    // Validation
    let maxNameCount: Int = 20
    @Published var errorMessage: String? = nil

    enum Outcome {
        case soloCreated
        case groupCreated(joinCode: String)
        case failed
    }

    func clampName() {
        if challengeName.count > maxNameCount {
            challengeName = String(challengeName.prefix(maxNameCount))
        }
    }

    func createChallenge(session: GameSession) async -> Outcome {
        errorMessage = nil

        let trimmed = challengeName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a challenge name."
            return .failed
        }

        let goalSteps = max(Int(steps), 1)
        let durationDays = selectedPeriod.days
        let challengeMode: ChallengeMode = (mode == .group) ? .social : .solo

        // ✅ يستخدم GameSession.createNewChallenge المتوفر عندك
        await session.createNewChallenge(
            name: trimmed,
            mode: challengeMode,
            goalSteps: goalSteps,
            durationDays: durationDays
        )

        // لو صار فيه خطأ داخل السيشن
        if let msg = session.errorMessage, !msg.isEmpty {
            errorMessage = msg
            return .failed
        }

        // ✅ اقرأ التحدي اللي اختاره السيشن
        guard let created = session.challenge else {
            errorMessage = "Failed to create challenge. Please try again."
            return .failed
        }

        if created.originalMode == .social {
            return .groupCreated(joinCode: created.joinCode)
        } else {
            return .soloCreated
        }
    }
}

// MARK: - Options

enum PeriodOption: CaseIterable, Equatable {
    case threeDays, week, month

    var title: String {
        switch self {
        case .threeDays: return "3 Days"
        case .week: return "Week"
        case .month: return "Month"
        }
    }

    var days: Int {
        switch self {
        case .threeDays: return 3
        case .week: return 7
        case .month: return 30
        }
    }
}

enum ModeOption: Equatable {
    case solo, group
}
