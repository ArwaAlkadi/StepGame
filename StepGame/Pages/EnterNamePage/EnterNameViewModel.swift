//import Foundation
//import FirebaseAuth
//import FirebaseFirestore
//
//@MainActor
//class EnterNameViewModel: ObservableObject {
//
//    // Input
//    @Published var playerName: String = ""
//
//    // UI State
//    @Published var navigateToStart = false
//    @Published var showHealthKitAlert = false
//    @Published var isCreatingUser = false
//
//    private let maxCharacters = 20
//
//    // Services
//    let healthKitService: HealthKitService
//
//    init(healthKitService: HealthKitService = HealthKitService()) {
//        self.healthKitService = healthKitService
//    }
//
//    func trimToMaxCharacters() {
//        if playerName.count > maxCharacters {
//            playerName = String(playerName.prefix(maxCharacters))
//        }
//    }
//
//    func startTapped() {
//        Task {
//            await createUserAndRequestHealthKit()
//        }
//    }
//
//    private func createUserAndRequestHealthKit() async {
//        isCreatingUser = true
//
//        do {
//            // Step 1: Firebase anonymous sign in
//            let authResult = try await Auth.auth().signInAnonymously()
//            let userId = authResult.user.uid
//
//            // Step 2: HealthKit authorization
//            if HealthKitService.isHealthKitAvailable() {
//                try await healthKitService.requestAuthorization()
//            } else {
//                showHealthKitAlert = true
//            }
//
//            // Step 3: Create Player document
//            let player = Player(
//                id: userId,
//                name: playerName.trimmingCharacters(in: .whitespaces),
//                steps: 0,
//                progress: 0.0,
//                characterType: "character1",
//                characterState: "normal",
//                totalChallenges: 0,
//                completedChallenges: 0,
//                totalSteps: 0,
//                lastUpdated: Date(),
//                createdAt: Date()
//            )
//
//            try await savePlayerToFirestore(player: player)
//
//            // Step 4: Navigate
//            isCreatingUser = false
//            navigateToStart = true
//
//        } catch {
//            isCreatingUser = false
//            showHealthKitAlert = true
//            print("Error creating user: \(error.localizedDescription)")
//        }
//    }
//
//    private func savePlayerToFirestore(player: Player) async throws {
//        let db = Firestore.firestore()
//
//        let playerData: [String: Any] = [
//            "name": player.name,
//            "steps": player.steps,
//            "progress": player.progress,
//            "characterType": player.characterType,
//            "characterState": player.characterState,
//            "totalChallenges": player.totalChallenges,
//            "completedChallenges": player.completedChallenges,
//            "totalSteps": player.totalSteps,
//            "lastUpdated": Timestamp(date: player.lastUpdated),
//            "createdAt": Timestamp(date: player.createdAt)
//        ]
//
//        try await db.collection("players").document(player.id!).setData(playerData)
//    }
//
//    func canStart() -> Bool {
//        !playerName.trimmingCharacters(in: .whitespaces).isEmpty && !isCreatingUser
//    }
//
//    func counterText() -> String {
//        "\(playerName.count)/\(maxCharacters)"
//    }
//}
