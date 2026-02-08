//
//  SheredStepService.swift
//  StepGame
//
//  Created by Aryam on 06/02/2026.
//
import Foundation
import WidgetKit

final class SharedStepService {

    static let shared = SharedStepService()
    private let defaults = UserDefaults(suiteName: "group.com.2026.StepGame")

    private init() {}

    // MARK: - Update from ANY source
    func update(
        avatar: AvatarType,
        stepsToday: Int,
        totalGoal: Int,
        duration: ChallengeDuration
    ) {

        let state = AvatarStateCalculator.calculateState(
            stepsToday: stepsToday,
            totalGoal: totalGoal,
            duration: duration
        )

        defaults?.set(stepsToday, forKey: "stepsToday")
        defaults?.set(totalGoal, forKey: "goal")
        defaults?.set(avatar.rawValue, forKey: "avatar")
        defaults?.set(state.rawValue, forKey: "state")

        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Read for Widget
    func read() -> (avatar: AvatarType, state: AvatarState, steps: Int, goal: Int) {

        let avatarRaw = defaults?.string(forKey: "avatar") ?? "luna"
        let stateRaw  = defaults?.string(forKey: "state") ?? "fat"

        let steps = defaults?.integer(forKey: "stepsToday") ?? 0
        let goal  = defaults?.integer(forKey: "goal") ?? 3000

        return (
            AvatarType(rawValue: avatarRaw) ?? .luna,
            AvatarState(rawValue: stateRaw) ?? .fat,
            steps,
            goal
        )
    }
}
