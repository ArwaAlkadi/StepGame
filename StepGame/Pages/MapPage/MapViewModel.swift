//
//  MapViewModel.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import UIKit

@MainActor
final class MapViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var challenge: Challenge? = nil
    @Published private(set) var participants: [ChallengeParticipant] = []
    @Published private(set) var myParticipant: ChallengeParticipant? = nil

    // MARK: - Dependencies

    private let firebase = FirebaseService.shared
    private weak var session: GameSession?

    // MARK: - Listeners

    private var challengeListener: ListenerRegistration?
    private var participantsListener: ListenerRegistration?

    // MARK: - Sync

    private var syncTimerCancellable: AnyCancellable?
    private var appForegroundCancellable: AnyCancellable?
    private var lastUploadedSteps: Int? = nil

   
    // MARK: - Map Path (Normalized 0...1)

    private let pathPoints: [CGPoint] = [
        .init(x: 0.803, y: 0.060),
        .init(x: 0.795, y: 0.071),
        .init(x: 0.784, y: 0.085),
        .init(x: 0.767, y: 0.100),
        .init(x: 0.765, y: 0.111),
        .init(x: 0.748, y: 0.124),
        .init(x: 0.740, y: 0.136),
        .init(x: 0.714, y: 0.150),
        .init(x: 0.640, y: 0.163),
        .init(x: 0.581, y: 0.182),
        .init(x: 0.517, y: 0.197),
        .init(x: 0.476, y: 0.215),
        .init(x: 0.490, y: 0.228),
        .init(x: 0.527, y: 0.246),
        .init(x: 0.542, y: 0.257),
        .init(x: 0.577, y: 0.271),
        .init(x: 0.611, y: 0.283),
        .init(x: 0.615, y: 0.294),
        .init(x: 0.615, y: 0.310),
        .init(x: 0.603, y: 0.324),
        .init(x: 0.571, y: 0.339),
        .init(x: 0.553, y: 0.353),
        .init(x: 0.553, y: 0.362),
        .init(x: 0.512, y: 0.374),
        .init(x: 0.483, y: 0.385),
        .init(x: 0.434, y: 0.398),
        .init(x: 0.343, y: 0.410),
        .init(x: 0.286, y: 0.411),
    ]

    private let flagAnchors: [CGPoint] = [
        .init(x: 0.736, y: 0.862),
        .init(x: 0.445, y: 0.711),
        .init(x: 0.719, y: 0.541),
        .init(x: 0.202, y: 0.408),
        .init(x: 0.751, y: 0.311),
        .init(x: 0.378, y: 0.136),
        .init(x: 0.780, y: 0.072)
    ]

    // MARK: - Bind / Unbind

    func bind(session: GameSession) {
        self.session = session

        unbind() // remove old listeners first

        self.challenge = session.challenge

        guard let chId = session.challenge?.id else {
            participants = []
            myParticipant = nil
            lastUploadedSteps = nil
            return
        }

        challengeListener = firebase.listenChallenge(challengeId: chId) { [weak self] updated in
            guard let self else { return }
            Task { @MainActor in
                self.challenge = updated
                self.session?.challenge = updated
            }
        }

        participantsListener = firebase.listenParticipants(challengeId: chId) { [weak self] list in
            guard let self else { return }
            Task { @MainActor in
                self.participants = list

                let myUid = self.session?.uid ?? ""
                self.myParticipant = list.first(where: { $0.playerId == myUid })

                if let current = self.myParticipant?.steps {
                    self.lastUploadedSteps = current
                }
            }
        }
    }

    func unbind() {
        challengeListener?.remove()
        challengeListener = nil

        participantsListener?.remove()
        participantsListener = nil
    }

    // MARK: - Steps Sync (Challenge Duration: startDate -> now)

    func startStepsSync(health: HealthKitManager) {
        stopStepsSync()

        Task { await syncOnce(health: health) }

        syncTimerCancellable = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.syncOnce(health: health) }
            }

        appForegroundCancellable = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.syncOnce(health: health) }
            }
    }

    func stopStepsSync() {
        syncTimerCancellable?.cancel()
        syncTimerCancellable = nil

        appForegroundCancellable?.cancel()
        appForegroundCancellable = nil
    }

    private func syncOnce(health: HealthKitManager) async {
        guard let session else { return }
        guard let ch = session.challenge, let chId = ch.id else { return }
        guard let uid = session.uid else { return }
        guard health.isAuthorized else { return }

        // ✅ Steps inside challenge period
        let start = ch.startDate
        let end = Date()

        do {
            let stepsInChallenge = try await health.fetchSteps(from: start, to: end)

            // no-op if unchanged
            if lastUploadedSteps == stepsInChallenge { return }

            let goal = max(ch.goalSteps, 1)
            let progress = min(max(Double(stepsInChallenge) / Double(goal), 0), 1)
            let state = computedCharacterState(challenge: ch, steps: stepsInChallenge)

            try await firebase.updateParticipantSteps(
                challengeId: chId,
                uid: uid,
                steps: stepsInChallenge,
                progress: progress,
                characterState: state
            )

            lastUploadedSteps = stepsInChallenge
        } catch {
            // optional: session.errorMessage = error.localizedDescription
        }
    }

    // MARK: - HUD Text

    var titleText: String {
        challenge?.name ?? ""
    }

    var playerName: String {
        session?.player?.name ?? "Player"
    }

    var playerSteps: Int {
        myParticipant?.steps ?? 0
    }

    var stepsLeftText: String {
        guard let ch = challenge else { return "0 Step Left" }
        let left = max(0, ch.goalSteps - playerSteps)
        return "\(left.formatted()) Step Left"
    }

    var daysLeftText: String {
        guard let ch = challenge else { return "0 Day Left" }
        let remaining = ch.effectiveEndDate.timeIntervalSince(Date())
        if remaining <= 0 { return "0 Day Left" }
        let days = Int(ceil(remaining / 86400.0))
        return "\(days) Day Left"
    }

    // MARK: - Progress / Character

    var progress: CGFloat {
        guard let ch = challenge else { return 0 }
        let goal = max(ch.goalSteps, 1)
        return min(max(CGFloat(playerSteps) / CGFloat(goal), 0), 1)
    }

    var computedState: CharacterState {
        guard let ch = challenge else { return .normal }
        return computedCharacterState(challenge: ch, steps: playerSteps)
    }

    var characterImageName: String {
        guard let me = session?.player else { return "character1_normal" }
        return me.characterType.imageKey(state: computedState)
    }

    // MARK: - Flags

    var milestones: [Int] {
        guard let ch = challenge else { return [] }
        return makeMilestones(goalSteps: ch.goalSteps, count: flagAnchors.count, unit: 500)
    }

    func isFlagReached(_ milestone: Int) -> Bool {
        playerSteps >= milestone
    }

    func flagPosition(index: Int, mapSize: CGSize) -> CGPoint {
        let a = flagAnchors[index]
        return CGPoint(x: mapSize.width * a.x, y: mapSize.height * a.y)
    }

    // MARK: - Player Position

    func playerPosition(mapSize: CGSize) -> CGPoint {
        positionForProgress(progress: progress, mapSize: mapSize)
    }

    // MARK: - Character State Logic (Relaxed)

    private func computedCharacterState(challenge: Challenge, steps: Int, now: Date = Date()) -> CharacterState {
        let goal = max(challenge.goalSteps, 1)

        let stepsProgress = CGFloat(steps) / CGFloat(goal)
        let expected = expectedProgressByTime(challenge: challenge, now: now)
        let diff = stepsProgress - expected

        let activeThreshold: CGFloat = 0.10
        let lazyThreshold: CGFloat = -0.30

        if diff >= activeThreshold { return .active }
        if diff <= lazyThreshold { return .lazy }
        return .normal
    }

    private func expectedProgressByTime(challenge: Challenge, now: Date = Date()) -> CGFloat {
        let total = challenge.effectiveEndDate.timeIntervalSince(challenge.startDate)
        if total <= 0 { return 1 }

        let elapsed = now.timeIntervalSince(challenge.startDate)
        let p = elapsed / total
        return min(max(CGFloat(p), 0), 1)
    }

    // MARK: - Path Helpers

    private func positionForProgress(progress: CGFloat, mapSize: CGSize) -> CGPoint {
        guard pathPoints.count >= 2 else { return .zero }

        let clamped = min(max(progress, 0), 1)
        let maxIndex = pathPoints.count - 1

        let exactIndex = clamped * CGFloat(maxIndex)
        let lowerIndex = Int(floor(exactIndex))
        let upperIndex = min(lowerIndex + 1, maxIndex)

        let t = exactIndex - CGFloat(lowerIndex)

        let p1 = pathPoints[lowerIndex]
        let p2 = pathPoints[upperIndex]

        let xNorm = p1.x + (p2.x - p1.x) * t
        let yNorm = p1.y + (p2.y - p1.y) * t

        return CGPoint(x: xNorm * mapSize.width, y: yNorm * mapSize.height)
    }

    // MARK: - Milestones

    private func makeMilestones(goalSteps: Int, count: Int, unit: Int) -> [Int] {
        guard count > 0 else { return [] }

        let goal = max(goalSteps, unit)
        let rawStep = Double(goal) / Double(count)

        var ms: [Int] = []
        for i in 1...count {
            let rawValue = Double(i) * rawStep
            let roundedUp = Int(ceil(rawValue / Double(unit))) * unit
            ms.append(roundedUp)
        }

        for i in 1..<ms.count where ms[i] <= ms[i - 1] {
            ms[i] = ms[i - 1] + unit
        }

        if let last = ms.last, last < goal {
            ms[ms.count - 1] = Int(ceil(Double(goal) / Double(unit))) * unit
        }

        return ms
    }
}
