//
//  FirebaseService.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

final class FirebaseService {

    static let shared = FirebaseService()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: - Auth (Anonymous)
    func signInIfNeeded() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid {
            return uid
        }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    // MARK: - Players
    func createOrUpdatePlayer(
        uid: String,
        name: String,
        characterType: CharacterType = .character1
    ) async throws -> Player {

        let ref = db.collection("players").document(uid)
        let now = Date()

        let data: [String: Any] = [
            "name": name,
            "totalChallenges": 0,
            "completedChallenges": 0,
            "totalSteps": 0,
            "characterType": characterType.rawValue,
            "lastUpdated": Timestamp(date: now),
            "createdAt": Timestamp(date: now)
        ]

        try await ref.setData(data, merge: true)
        return try await fetchPlayer(uid: uid)
    }

    func fetchPlayer(uid: String) async throws -> Player {
        let doc = try await db.collection("players").document(uid).getDocument()
        guard let player = try? doc.data(as: Player.self) else {
            throw NSError(
                domain: "Player",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Player not found"]
            )
        }
        return player
    }

    // MARK: - Challenges
    func createChallenge(
        hostUid: String,
        name: String,
        mode: ChallengeMode,
        goalSteps: Int,
        durationDays: Int
    ) async throws -> Challenge {

        let joinCode = Self.generateJoinCode()

        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: durationDays, to: start)
        ?? start.addingTimeInterval(TimeInterval(durationDays * 86400))

        let isSocial = (mode == .social)

        // Social: waiting until host starts.
        // Solo: active immediately.
        let status: ChallengeStatus = isSocial ? .waiting : .active
        let startedAt: Date? = isSocial ? nil : start

        var challenge = Challenge(
            name: name,
            joinCode: joinCode,
            mode: mode,
            originalMode: mode,
            goalSteps: goalSteps,
            durationDays: durationDays,
            status: status,
            createdBy: hostUid,
            playerIds: [hostUid],
            startDate: start,
            endDate: end,
            extensionSeconds: 0,
            createdAt: Date()
        )
        challenge.startedAt = startedAt

        let ref = db.collection("challenges").document()
        try ref.setData(from: challenge)

        var saved = challenge
        saved.id = ref.documentID

        // Host participant doc
        let part = ChallengeParticipant(
            challengeId: ref.documentID,
            playerId: hostUid,
            steps: 0,
            progress: 0,
            characterState: .normal
        )

        try await db.collection("challenges")
            .document(ref.documentID)
            .collection("participants")
            .document(hostUid)
            .setData(from: part)

        return saved
    }

    func joinChallenge(by joinCode: String, uid: String) async throws -> Challenge {

        let q = try await db.collection("challenges")
            .whereField("joinCode", isEqualTo: joinCode)
            .limit(to: 1)
            .getDocuments()

        guard let doc = q.documents.first else {
            throw NSError(domain: "Join", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invalid code"])
        }

        var ch = try doc.data(as: Challenge.self)
        guard let challengeId = ch.id else {
            throw NSError(domain: "Join", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing challenge id"])
        }

        if ch.playerIds.contains(uid) { return ch }

        if ch.playerIds.count >= ch.maxPlayers {
            throw NSError(domain: "Join", code: 409, userInfo: [NSLocalizedDescriptionKey: "Challenge is full"])
        }

        var newIds = ch.playerIds
        newIds.append(uid)

        // Keep status as-is (social stays waiting until host starts)
        try await db.collection("challenges").document(challengeId).updateData([
            "playerIds": newIds
        ])

        // Joiner participant doc
        let part = ChallengeParticipant(
            challengeId: challengeId,
            playerId: uid,
            steps: 0,
            progress: 0,
            characterState: .normal
        )

        try await db.collection("challenges")
            .document(challengeId)
            .collection("participants")
            .document(uid)
            .setData(from: part)

        let updatedDoc = try await db.collection("challenges").document(challengeId).getDocument()
        return try updatedDoc.data(as: Challenge.self)
    }

    // MARK: - Start Social Challenge (Host)
    func startChallenge(challengeId: String, hostUid: String) async throws {
        // Client-side host check happens in GameSession; server rules should enforce too.
        try await db.collection("challenges")
            .document(challengeId)
            .updateData([
                "status": ChallengeStatus.active.rawValue,
                "startedAt": Timestamp(date: Date())
            ])
    }

    // MARK: - Participant Updates (Steps)
    func updateParticipantSteps(
        challengeId: String,
        uid: String,
        steps: Int,
        progress: Double,
        characterState: CharacterState
    ) async throws {

        let ref = db.collection("challenges")
            .document(challengeId)
            .collection("participants")
            .document(uid)

        let now = Date()

        try await ref.setData([
            "challengeId": challengeId,
            "playerId": uid,
            "steps": steps,
            "progress": progress,
            "characterState": characterState.rawValue,
            "lastUpdated": Timestamp(date: now),
            "createdAt": Timestamp(date: now) // merge true keeps original if already exists
        ], merge: true)
    }

    // MARK: - Realtime Listeners
    func listenMyChallenges(uid: String, onChange: @escaping ([Challenge]) -> Void) -> ListenerRegistration {
        db.collection("challenges")
            .whereField("playerIds", arrayContains: uid)
            .addSnapshotListener { snap, _ in
                let docs = snap?.documents ?? []
                let list: [Challenge] = docs.compactMap { try? $0.data(as: Challenge.self) }
                onChange(list.sorted { $0.createdAt > $1.createdAt })
            }
    }

    func listenChallenge(challengeId: String, onChange: @escaping (Challenge?) -> Void) -> ListenerRegistration {
        db.collection("challenges")
            .document(challengeId)
            .addSnapshotListener { snap, _ in
                guard let snap else { onChange(nil); return }
                let model = try? snap.data(as: Challenge.self)
                onChange(model)
            }
    }

    func listenParticipants(challengeId: String, onChange: @escaping ([ChallengeParticipant]) -> Void) -> ListenerRegistration {
        db.collection("challenges")
            .document(challengeId)
            .collection("participants")
            .addSnapshotListener { snap, _ in
                let docs = snap?.documents ?? []
                let list: [ChallengeParticipant] = docs.compactMap { try? $0.data(as: ChallengeParticipant.self) }
                onChange(list)
            }
    }

    // MARK: - Helpers
    static func generateJoinCode() -> String {
        let letters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<6).compactMap { _ in letters.randomElement() })
    }
}
