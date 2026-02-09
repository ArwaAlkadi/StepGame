//
//  MapViewModel.swift
//  StepGame
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import UIKit

// MARK: - Map ViewModel
@MainActor
final class MapViewModel: ObservableObject {

    // MARK: - Published State
    @Published private(set) var challenge: Challenge? = nil
    @Published private(set) var participants: [ChallengeParticipant] = []
    @Published private(set) var playersById: [String: Player] = [:]
    @Published private(set) var myParticipant: ChallengeParticipant? = nil

    @Published var isShowingResultPopup: Bool = false
    @Published var resultPopupVM: ChallengeResultPopupViewModel? = nil

    // MARK: - Map Player VM
    struct MapPlayerVM: Identifiable {
        let id: String
        let name: String
        let hudAvatar: String
        let mapSprite: String
        let steps: Int
        let progress: Double
        let isMe: Bool
    }

    @Published private(set) var mapPlayers: [MapPlayerVM] = []

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

    deinit {
        MainActor.assumeIsolated {
            unbind()
            stopStepsSync()
        }
        syncTimerCancellable?.cancel()
        syncTimerCancellable = nil
        appForegroundCancellable?.cancel()
        appForegroundCancellable = nil
    }

    /// Map path points (normalized 0...1)
    private let pathPoints: [CGPoint] = [
        .init(x: 0.315, y: 0.938),
        .init(x: 0.383, y: 0.894),
        .init(x: 0.522, y: 0.863),
        .init(x: 0.640, y: 0.854),
        .init(x: 0.659, y: 0.808),
        .init(x: 0.603, y: 0.767),
        .init(x: 0.547, y: 0.721),
        .init(x: 0.489, y: 0.686),
        .init(x: 0.538, y: 0.627),
        .init(x: 0.547, y: 0.571),
        .init(x: 0.512, y: 0.531),
        .init(x: 0.463, y: 0.498),
        .init(x: 0.449, y: 0.452),
        .init(x: 0.460, y: 0.410),
        .init(x: 0.480, y: 0.363),
        .init(x: 0.580, y: 0.354),
        .init(x: 0.648, y: 0.328),
        .init(x: 0.625, y: 0.278),
        .init(x: 0.512, y: 0.242),
        .init(x: 0.502, y: 0.174),
        .init(x: 0.602, y: 0.145),
        .init(x: 0.632, y: 0.073),
    ]

    /// Flag anchor points (normalized 0...1)
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

        unbind()

        self.challenge = session.challenge
        rebuildAllUI()
        evaluateResultPopupIfNeeded()

        guard let chId = session.challenge?.id else { return }

        challengeListener = firebase.listenChallenge(challengeId: chId) { [weak self] updated in
            guard let self else { return }
            Task { @MainActor in
                self.challenge = updated
                self.session?.challenge = updated
                self.rebuildAllUI()
                self.evaluateResultPopupIfNeeded()
                self.maybeEndChallengeIfNeeded()
            }
        }

        participantsListener = firebase.listenParticipants(challengeId: chId) { [weak self] list in
            guard let self else { return }
            Task { @MainActor in
                self.participants = list
                self.recomputeMyParticipant()
                await self.fetchPlayersIfNeeded()
                self.rebuildAllUI()
                self.evaluateResultPopupIfNeeded()
                self.maybeEndChallengeIfNeeded()
            }
        }
    }

    func unbind() {
        challengeListener?.remove()
        challengeListener = nil

        participantsListener?.remove()
        participantsListener = nil
    }

    private func recomputeMyParticipant() {
        let myId = session?.uid ?? session?.player?.id ?? ""
        myParticipant = participants.first(where: { $0.playerId == myId })
    }

    private func fetchPlayersIfNeeded() async {
        let ids = participants.map { $0.playerId }
        let missing = ids.filter { playersById[$0] == nil }
        guard !missing.isEmpty else { return }

        do {
            let fetched = try await firebase.fetchPlayers(uids: missing)
            var dict = playersById
            for p in fetched {
                if let id = p.id { dict[id] = p }
            }
            playersById = dict
        } catch {
        }
    }

    // MARK: - UI Builders
    private func rebuildAllUI() {
        guard let session else { return }
        guard let ch = challenge else { return }

        let myId = session.uid ?? session.player?.id ?? ""
        let goal = max(ch.goalSteps, 1)

        let vms: [MapPlayerVM] = participants.map { part in
            let isMe = (part.playerId == myId)
            let p = isMe ? session.player : playersById[part.playerId]
            let type = p?.characterType ?? .character1

            let name = p?.name ?? (isMe ? "Me" : shortId(part.playerId))
            let hudAvatar = type.avatarKey()

            let progress = min(max(Double(part.steps) / Double(goal), 0), 1)

            let state = computedCharacterState(challenge: ch, steps: part.steps)
            let mapSprite = type.imageKey(state: state)

            return MapPlayerVM(
                id: part.playerId,
                name: name,
                hudAvatar: hudAvatar,
                mapSprite: mapSprite,
                steps: part.steps,
                progress: progress,
                isMe: isMe
            )
        }

        mapPlayers = vms.sorted { a, b in
            if a.isMe != b.isMe { return a.isMe }
            return a.steps > b.steps
        }
    }

    // MARK: - HUD Text
    var titleText: String { challenge?.name ?? "" }

    var isGroupChallenge: Bool {
        guard let ch = challenge else { return false }
        return (ch.originalMode == .social && ch.maxPlayers > 1)
    }

    var hudAvatars: [String] {
        guard isGroupChallenge else { return [] }
        return mapPlayers.map { $0.hudAvatar }
    }

    var myHudAvatar: String {
        if let me = mapPlayers.first(where: { $0.isMe }) { return me.hudAvatar }
        return (session?.player?.characterType.avatarKey() ?? "character1_avatar")
    }

    var mySteps: Int {
        mapPlayers.first(where: { $0.isMe })?.steps ?? 0
    }

    var stepsLeftText: String {
        guard let ch = challenge else { return "0 Step Left" }
        let left = max(0, ch.goalSteps - mySteps)
        return "\(left.formatted()) Step Left"
    }

    var daysLeftText: String {
        guard let ch = challenge else { return "0 Day Left" }

        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        let endDayStart = cal.startOfDay(for: ch.effectiveEndDate)

        let diff = cal.dateComponents([.day], from: todayStart, to: endDayStart).day ?? 0
        let daysLeft = max(0, diff)

        return "\(daysLeft) Day Left"
    }

    // MARK: - Positions
    func positionForPlayer(_ player: MapPlayerVM, mapSize: CGSize) -> CGPoint {
        let base = positionForProgress(progress: CGFloat(player.progress), mapSize: mapSize)

        let grouped = mapPlayers
            .sorted { $0.id < $1.id }
            .filter { abs($0.progress - player.progress) < 0.001 }

        guard grouped.count > 1 else { return base }
        guard let idx = grouped.firstIndex(where: { $0.id == player.id }) else { return base }

        let angle = (2.0 * Double.pi) * (Double(idx) / Double(grouped.count))
        let radius: CGFloat = player.isMe ? 18 : 14

        let dx = CGFloat(cos(angle)) * radius
        let dy = CGFloat(sin(angle)) * radius

        return CGPoint(x: base.x + dx, y: base.y + dy)
    }

    // MARK: - Flags
    var milestones: [Int] {
        guard let ch = challenge else { return [] }
        return makeMilestones(goalSteps: ch.goalSteps, count: flagAnchors.count, unit: 500)
    }

    func isFlagReached(_ milestone: Int) -> Bool { mySteps >= milestone }

    func flagPosition(index: Int, mapSize: CGSize) -> CGPoint {
        let a = flagAnchors[index]
        return CGPoint(x: mapSize.width * a.x, y: mapSize.height * a.y)
    }

    // MARK: - Steps Sync (Today)
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

    // MARK: - Steps Sync Once
    private func syncOnce(health: HealthKitManager) async {
        guard let session else { return }
        guard let ch = session.challenge, let chId = ch.id else { return }
        guard let uid = session.uid else { return }
        guard health.isAuthorized else { return }
        guard ch.status == .active else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        do {
            let stepsToday = try await health.fetchSteps(from: startOfDay, to: now)
            if lastUploadedSteps == stepsToday { return }

            let goal = max(ch.goalSteps, 1)
            let progress = min(max(Double(stepsToday) / Double(goal), 0), 1)
            let state: CharacterState = (progress >= 1) ? .active : .normal

            try await firebase.updateParticipantSteps(
                challengeId: chId,
                uid: uid,
                steps: stepsToday,
                progress: progress,
                characterState: state
            )

            lastUploadedSteps = stepsToday

            if stepsToday >= goal {
                try? await firebase.tryMarkFinishedAndClaimWinnerIfNeeded(
                    challengeId: chId,
                    uid: uid,
                    now: now
                )
            }

            Task { [weak self] in
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await self?.syncRetryIfChanged(health: health, start: startOfDay, end: Date())
            }
        } catch {
        }
    }

    /// Retry sync to handle delayed Health updates
    private func syncRetryIfChanged(health: HealthKitManager, start: Date, end: Date) async {
        guard let session else { return }
        guard let ch = session.challenge, let chId = ch.id else { return }
        guard let uid = session.uid else { return }
        guard health.isAuthorized else { return }
        guard ch.status == .active else { return }

        do {
            let stepsToday = try await health.fetchSteps(from: start, to: end)
            if lastUploadedSteps == stepsToday { return }

            let goal = max(ch.goalSteps, 1)
            let progress = min(max(Double(stepsToday) / Double(goal), 0), 1)
            let state: CharacterState = (progress >= 1) ? .active : .normal

            try await firebase.updateParticipantSteps(
                challengeId: chId,
                uid: uid,
                steps: stepsToday,
                progress: progress,
               characterState: state
            )

            lastUploadedSteps = stepsToday

            if stepsToday >= goal {
                try? await firebase.tryMarkFinishedAndClaimWinnerIfNeeded(
                    challengeId: chId,
                    uid: uid,
                    now: Date()
                )
            }
        } catch {
        }
    }

    // MARK: - Result Popup Rules
    private func evaluateResultPopupIfNeeded(now: Date = Date()) {
        guard !isShowingResultPopup else { return }
        guard let ch = challenge, let chId = ch.id else { return }
        guard let me = session?.player else { return }
        guard let myPart = myParticipant else { return }

        if myPart.hasShownResultPopup { return }

        let iFinished = (myPart.finishedAt != nil)
        let timeEnded = (now >= ch.effectiveEndDate)

        guard iFinished || timeEnded else { return }

        let vm = ChallengeResultPopupViewModel(
            challenge: ch,
            me: me,
            myParticipant: myPart,
            participants: participants,
            playersById: playersById
        )

        resultPopupVM = vm
        isShowingResultPopup = true

        Task {
            do { try await firebase.markDidShowResultPopup(challengeId: chId, uid: myPart.playerId) }
            catch { }
        }
    }

    func dismissResultPopup() {
        isShowingResultPopup = false
        resultPopupVM = nil
    }

    // MARK: - Character State Logic
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
        let start = challenge.startedAt ?? challenge.startDate
        let end = challenge.effectiveEndDate

        let total = end.timeIntervalSince(start)
        if total <= 0 { return 1 }

        let elapsed = now.timeIntervalSince(start)
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

    // MARK: - Challenge End
    private func maybeEndChallengeIfNeeded(now: Date = Date()) {
        guard let ch = challenge, let chId = ch.id else { return }
        guard ch.status != .ended else { return }

        let timeEnded = (now >= ch.effectiveEndDate)
        let allFinished = !participants.isEmpty && participants.allSatisfy { $0.finishedAt != nil }

        guard timeEnded || allFinished else { return }

        Task {
            do { try await firebase.markChallengeEnded(challengeId: chId, now: now) }
            catch { }
        }
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

    ///Shortens a uid for display
    private func shortId(_ id: String) -> String {
        if id.count <= 6 { return id }
        return "\(id.prefix(3))...\(id.suffix(3))"
    }
}
