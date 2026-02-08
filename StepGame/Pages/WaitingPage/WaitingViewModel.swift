//
//  WaitingViewModel.swift
//  StepGame
//
//  Created by Arwa Alkadi on 30/01/2026.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class WaitingRoomViewModel: ObservableObject {
    @Published var challenge: Challenge?
    @Published var players: [Player] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var challengeListener: ListenerRegistration?
    private var playersListener: ListenerRegistration?

    let challengeId: String
    let currentUserId: String

    init(challengeId: String, currentUserId: String) {
        self.challengeId = challengeId
        self.currentUserId = currentUserId
    }

    var isHost: Bool {
        challenge?.createdBy == currentUserId
    }

    var maxPlayers: Int {
        challenge?.maxPlayers ?? 2
    }

    var canStart: Bool {
        guard let ch = challenge else { return false }
        if ch.originalMode == "solo" { return players.count >= 1 }
        return players.count >= 2
    }

    func startListening() {
        isLoading = true

        // 1) Listen challenge
        challengeListener = db.collection("challenges")
            .document(challengeId)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err = err {
                    self.errorMessage = err.localizedDescription
                    self.isLoading = false
                    return
                }
                guard let snap else { return }

                do {
                    self.challenge = try snap.data(as: Challenge.self)
                    self.isLoading = false
                    // بعد ما تجيب challenge اربط players listener
                    self.listenPlayers()
                } catch {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
    }

    private func listenPlayers() {
        playersListener?.remove()
        playersListener = db.collection("challenges")
            .document(challengeId)
            .collection("players")
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err = err {
                    self.errorMessage = err.localizedDescription
                    return
                }
                guard let docs = snap?.documents else { return }
                self.players = docs.compactMap { try? $0.data(as: Player.self) }
            }
    }

    func stopListening() {
        challengeListener?.remove()
        playersListener?.remove()
    }

    func startChallenge() async {
        // مثال: تغيرين status + تضيفين startDate
        guard canStart else { return }
        do {
            try await db.collection("challenges")
                .document(challengeId)
                .updateData([
                    "status": "started",
                    "startDate": Date()
                ])
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
