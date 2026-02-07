//
//  GameSession.swift
//  StepGame
//
//  Created by Arwa Alkadi on 03/02/2026.
//

import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
final class GameSession: ObservableObject {

    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Auth / Player
    @Published private(set) var uid: String? = nil
    @Published var player: Player? = nil
    @Published var playerName: String = ""

    // MARK: - Challenge Navigation
    @Published var challenge: Challenge? = nil

    // MARK: - Challenges List
    @Published var challenges: [Challenge] = []

    var activeChallenges: [Challenge] {
        challenges.filter { $0.status == .active || $0.status == .waiting }
    }

    var endedChallenges: [Challenge] {
        challenges.filter { $0.status == .ended }
    }

    var hasAnyChallenges: Bool {
        !challenges.isEmpty
    }

    // MARK: - Participants (Selected Challenge)
    @Published private(set) var participants: [ChallengeParticipant] = []
    @Published private(set) var myParticipant: ChallengeParticipant? = nil

    // MARK: - Private
    private let firebase = FirebaseService.shared

    private var myChallengesListener: ListenerRegistration?
    private var selectedChallengeListener: ListenerRegistration?
    private var participantsListener: ListenerRegistration?

    private var stepSyncCancellable: AnyCancellable?

    deinit {
        myChallengesListener?.remove()
        selectedChallengeListener?.remove()
        participantsListener?.remove()
        stepSyncCancellable?.cancel()
    }

    // MARK: - Bootstrapping
    func bootstrap() async {
        if uid != nil { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let signedUid = try await firebase.signInIfNeeded()
            uid = signedUid

            do {
                let p = try await firebase.fetchPlayer(uid: signedUid)
                player = p
                playerName = p.name
                startMyChallengesListener(uid: signedUid)
            } catch {
                player = nil
                playerName = ""
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Challenge List Listener
    private func startMyChallengesListener(uid: String) {
        myChallengesListener?.remove()

        myChallengesListener = firebase.listenMyChallenges(uid: uid) { [weak self] list in
            guard let self else { return }
            Task { @MainActor in
                self.challenges = list

                let selectedId = self.challenge?.id
                let stillExists = selectedId.flatMap { id in list.contains(where: { $0.id == id }) } ?? false

                if !stillExists {
                    self.challenge = self.pickDefaultChallenge(from: list)
                }

                if let id = self.challenge?.id {
                    self.startSelectedChallengeListener(challengeId: id)
                    self.startParticipantsListenerIfNeeded(challengeId: id)
                }
            }
        }
    }

    private func pickDefaultChallenge(from list: [Challenge]) -> Challenge? {
        if let active = list.first(where: { $0.status == .active }) { return active }
        if let waiting = list.first(where: { $0.status == .waiting }) { return waiting }
        return list.first
    }

    // MARK: - Selected Challenge Listener
    private func startSelectedChallengeListener(challengeId: String) {
        selectedChallengeListener?.remove()

        selectedChallengeListener = firebase.listenChallenge(challengeId: challengeId) { [weak self] updated in
            guard let self else { return }
            Task { @MainActor in
                guard let updated else {
                    self.challenge = nil
                    self.participants = []
                    self.myParticipant = nil
                    return
                }
                self.challenge = updated

                if let id = updated.id {
                    self.startParticipantsListenerIfNeeded(challengeId: id)
                }
            }
        }
    }

    private func startParticipantsListenerIfNeeded(challengeId: String) {
        participantsListener?.remove()

        participantsListener = firebase.listenParticipants(challengeId: challengeId) { [weak self] list in
            guard let self else { return }
            Task { @MainActor in
                self.participants = list
                self.recomputeMyParticipant()
            }
        }
    }

    private func recomputeMyParticipant() {
        guard let uid else {
            myParticipant = nil
            return
        }
        myParticipant = participants.first(where: { $0.playerId == uid })
    }

    func selectChallenge(_ ch: Challenge) {
        challenge = ch
        participants = []
        myParticipant = nil

        if let id = ch.id {
            startSelectedChallengeListener(challengeId: id)
            startParticipantsListenerIfNeeded(challengeId: id)
        }
    }

    // MARK: - Player
    func createPlayer(name: String) async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard let uid else {
            errorMessage = "Missing user session."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let p = try await firebase.createOrUpdatePlayer(
                uid: uid,
                name: trimmed,
                characterType: .character1
            )
            player = p
            playerName = p.name
            startMyChallengesListener(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create Challenge
    func createNewChallenge(
        name: String,
        mode: ChallengeMode,
        goalSteps: Int,
        durationDays: Int
    ) async {
        guard let uid else {
            errorMessage = "Missing user session."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let ch = try await firebase.createChallenge(
                hostUid: uid,
                name: name,
                mode: mode,
                goalSteps: goalSteps,
                durationDays: durationDays
            )
            selectChallenge(ch)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Join With Code
    func joinWithCode(_ code: String) async {
        guard let uid else {
            errorMessage = "Missing user session."
            return
        }

        let cleaned = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.count >= 4 else {
            errorMessage = "Invalid code. Try again."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let ch = try await firebase.joinChallenge(by: cleaned, uid: uid)
            selectChallenge(ch)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Start Challenge (Host)
    func startSelectedChallengeIfHost() async {
        guard let uid else {
            errorMessage = "Missing user session."
            return
        }
        guard let ch = challenge, let challengeId = ch.id else {
            errorMessage = "Missing challenge."
            return
        }
        guard ch.createdBy == uid else {
            errorMessage = "Only the host can start this challenge."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await firebase.startChallenge(challengeId: challengeId, hostUid: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - HealthKit -> Firebase (Challenge Period)
    /// Call this from MapView.onAppear (or when a challenge becomes active).
    /// It periodically reads steps from (startedAt ?? startDate) -> now and updates Firestore participant.
    func beginStepsSync(health: HealthKitManager) {
        stepSyncCancellable?.cancel()

        stepSyncCancellable = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.syncMyStepsOnce(health: health) }
            }
    }

    func stopStepsSync() {
        stepSyncCancellable?.cancel()
        stepSyncCancellable = nil
    }

    func syncMyStepsOnce(health: HealthKitManager) async {
        guard let uid else { return }
        guard let ch = challenge, let challengeId = ch.id else { return }

        // Only sync when active
        guard ch.status == .active else { return }

        // Must be authorized
        guard health.isAuthorized else { return }

        do {
            let start = ch.startedAt ?? ch.startDate
            let steps = try await health.fetchSteps(from: start, to: Date())

            let goal = max(ch.goalSteps, 1)
            let progress = min(max(Double(steps) / Double(goal), 0), 1)

            // Keep state simple here (MapViewModel has a richer UI state)
            let state: CharacterState = (progress >= 1.0) ? .active : .normal

            try await firebase.updateParticipantSteps(
                challengeId: challengeId,
                uid: uid,
                steps: steps,
                progress: progress,
                characterState: state
            )
        } catch {
            // Don’t spam UI with Health errors; keep it silent unless you want to surface it later.
        }
    }

    // MARK: - Convenience
    func clearError() {
        errorMessage = nil
    }
}
