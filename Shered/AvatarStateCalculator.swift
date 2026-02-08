//
//  Untitled.swift
//  StepGame
//
//  Created by Aryam on 06/02/2026.
//
struct AvatarStateCalculator {

    static func calculateState(
        stepsToday: Int,
        totalGoal: Int,
        duration: ChallengeDuration
    ) -> AvatarState {

        let dailyTarget = max(1, totalGoal / duration.days)
        let progress = Double(stepsToday) / Double(dailyTarget)

        if progress < 0.4 {
            return .fat
        } else if progress < 1.0 {
            return .normal
        } else {
            return .strong
        }
    }
}
