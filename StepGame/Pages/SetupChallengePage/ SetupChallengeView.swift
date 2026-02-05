

//import SwiftUI
//
//struct SetupChallengeView: View {
//    let playerName: String
//    @Environment(\.dismiss) var dismiss
//    
//    @State private var challengeName: String = ""
//    @State private var selectedPeriod: ChallengePeriod = .threeDays
//    @State private var stepGoal: Double = 1000
//    @State private var selectedMode: ChallengeMode = .solo
//    
//    private let maxChallengeNameLength = 20
//    private let minSteps = 1000.0
//    private let maxSteps = 500000.0
//    
//    enum ChallengePeriod: String, CaseIterable {
//        case threeDays = "3 Days"
//        case week = "Week"
//        case month = "Month"
//        
//        var days: Int {
//            switch self {
//            case .threeDays: return 3
//            case .week: return 7
//            case .month: return 30
//            }
//        }
//    }
//    
//    var body: some View {
//        ZStack {
//            // Blurred Background
//            //Color.black.opacity(0.4)
//              //  .ignoresSafeArea()
//            
//            // Modal Card
//            VStack(spacing: 0) {
//                // Header with close button
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        dismiss()
//                    }) {
//                        ZStack {
//                            Circle()
//                                .fill(Color("Light1"))
//                                .frame(width: 35, height: 35)
//                            
//                            Image(systemName: "xmark")
//                                .font(.system(size: 16, weight: .bold))
//                                .foregroundColor(.white)
//                        }
//                    }
//                    .padding(.trailing, 15)
//                    .padding(.top, 15)
//                }
//                
//                // Title
//                Text("Create a New Challenge").frame(maxWidth: .infinity, alignment: .leading)
//                    .font(.custom("RussoOne-Regular", size: 22))
//                    .foregroundColor(Color("Light1"))
//                    .padding(.top, 5)
//                    .padding(.bottom, 20)
//                
//                VStack(alignment: .leading, spacing: 20) {
//                    // Challenge Name Input
//                    VStack(alignment: .leading, spacing: 5) {
//                        TextField("Challenge Name", text: $challengeName)
//                            .font(.custom("RussoOne-Regular", size: 15))
//                            .foregroundColor(Color("Light1").opacity(0.6))
//                            .padding()
//                            .background(Color("Light2")).opacity(0.3)
//                            .cornerRadius(23)
//                            .onChange(of: challengeName) { oldValue, newValue in
//                                if newValue.count > maxChallengeNameLength {
//                                    challengeName = String(newValue.prefix(maxChallengeNameLength))
//                                }
//                            }
//                        
//                        Text("\(challengeName.count)/\(maxChallengeNameLength)")
//                            .font(.custom("RussoOne-Regular", size: 11))
//                            .foregroundColor(Color("Light1").opacity(0.6))
//                            .padding(.leading, 5)
//                    }
//                    
//                    // Period Selection
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Period")
//                            .font(.custom("RussoOne-Regular", size: 16))
//                            .foregroundColor(Color("Light1"))
//                        
//                        HStack(spacing: 12) {
//                            ForEach(ChallengePeriod.allCases, id: \.self) { period in
//                                Button(action: {
//                                    selectedPeriod = period
//                                }) {
//                                    Text(period.rawValue)
//                                        .font(.custom("RussoOne-Regular", size: 15))
//                                        .foregroundColor(selectedPeriod == period ? .white : Color("Light1"))
//                                        .frame(width: 90, height: 40)
//                                        .background(
//                                            selectedPeriod == period ?
//                                            Color("Light1") : Color.white
//                                        )
//                                        .cornerRadius(20)
//                                }
//                            }
//                        }
//                    }
//                    
//                    
//                    // Steps Slider
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Steps")
//                            .font(.custom("RussoOne-Regular", size: 16))
//                            .foregroundColor(Color("Light1"))
//                        
//                        VStack(spacing: 6) {
//                            Slider(value: $stepGoal, in: minSteps...maxSteps, step: 1000)
//                                .tint(Color("Light1"))
//                            
//                            
//                            HStack {
//                                Text("\(Int(minSteps).formatted())")
//                                    .font(.custom("RussoOne-Regular", size: 11))
//                                    .foregroundColor(Color("Light1").opacity(0.6))
//                                
//                                Spacer()
//                                
//                                Text("\(Int(stepGoal).formatted())")
//                                    .font(.custom("RussoOne-Regular", size: 15))
//                                    .foregroundColor(Color("Light1"))
//                                
//                                Spacer()
//                                
//                                Text("\(Int(maxSteps).formatted())")
//                                    .font(.custom("RussoOne-Regular", size: 11))
//                                    .foregroundColor(Color("Light1").opacity(0.6))
//                            }
//                        }
//                    }
//                    
//                    // Mode Selection
//                    HStack(spacing: 25) {
//                        // Solo Mode
//                        Button(action: {
//                            selectedMode = .solo
//                        }) {
//                            HStack(spacing: 8) {
//                                Image(systemName: "person.fill")
//                                    .font(.system(size: 16))
//                                Text("Solo")
//                                    .font(.custom("RussoOne-Regular", size: 15))
//                            }
//                            .foregroundColor(selectedMode == .solo ? .white : Color("Light1"))
//                            .frame(width: 120, height: 40)
//                            .background(
//                                selectedMode == .solo ?
//                                Color("Light1") : Color.white
//                            )
//                            .cornerRadius(25)
//                        }
//                        
//                        // Group Mode
//                        Button(action: {
//                            selectedMode = .social
//                        }) {
//                            HStack(spacing: 8) {
//                                Image(systemName: "person.2.fill")
//                                    .font(.system(size: 16))
//                                Text("Group")
//                                    .font(.custom("RussoOne-Regular", size: 15))
//                            }
//                            .foregroundColor(selectedMode == .social ? .white : Color("Light1"))
//                            .frame(width: 120, height: 40)
//                            .background(
//                                selectedMode == .social ?
//                                Color("Light1") : Color.white
//                            )
//                            .cornerRadius(25)
//                        }
//                    }
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    
//                    // Create Button
//                    Button(action: {
//                        createChallenge()
//                    }) {
//                        Text("Create")
//                            .font(.custom("RussoOne-Regular", size: 18))
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 50)
//                            .background(Color("Light2"))
//                            .cornerRadius(30)
//                    }
//                    
//                    .disabled(challengeName.trimmingCharacters(in: .whitespaces).isEmpty)
//                    .opacity(challengeName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
//                    .padding(.top, 5)
//                }
//                .padding(.horizontal, 25)
//                .padding(.bottom, 25)
//                
//            }
//           // .ignoresSafeArea()
//            .background(Color("Light3"))
//            .cornerRadius(30)
//            .padding(.horizontal, 25)
//            
//            .frame(maxHeight: 900)
//           // .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
//        }
//        
//        .presentationDetents([.height(550)])
//        .background(Color("Light3"))
//    }
//    
//    private func createChallenge() {
//        // TODO: Implement challenge creation logic
//        // This will involve:
//        // 1. Creating a new Challenge object
//        // 2. Saving to Firebase
//        // 3. Generating join code for social challenges
//        // 4. Navigating to the challenge view
//        
//        print("Creating challenge:")
//        print("Name: \(challengeName)")
//        print("Period: \(selectedPeriod.days) days")
//        print("Steps: \(Int(stepGoal))")
//        print("Mode: \(selectedMode)")
//        
//        dismiss()
//    }
//}
//
//#Preview {
//    ZStack {
//        Color.gray.ignoresSafeArea()
//        SetupChallengeView(playerName: "Aisha")
//    }
//}


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SetupChallengeView: View {
    let playerName: String
    @Environment(\.dismiss) var dismiss
    
    @State private var challengeName: String = ""
    @State private var selectedPeriod: ChallengePeriod = .threeDays
    @State private var stepGoal: Double = 1000
    @State private var selectedMode: ChallengeMode = .solo
    @State private var showShareCodePopup = false
    @State private var generatedJoinCode = ""
    @State private var isCreating = false
    
    private let maxChallengeNameLength = 20
    private let minSteps = 1000.0
    private let maxSteps = 500000.0
    
    enum ChallengePeriod: String, CaseIterable {
        case threeDays = "3 Days"
        case week = "Week"
        case month = "Month"
        
        var days: Int {
            switch self {
            case .threeDays: return 3
            case .week: return 7
            case .month: return 30
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Modal Card
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color("Light1"))
                                .frame(width: 35, height: 35)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 15)
                    .padding(.top, 15)
                }
                
                // Title
                Text("Create a New Challenge").frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("RussoOne-Regular", size: 22))
                    .foregroundColor(Color("Light1"))
                    .padding(.top, 5)
                    .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Challenge Name Input
                    VStack(alignment: .leading, spacing: 5) {
                        TextField("Challenge Name", text: $challengeName)
                            .font(.custom("RussoOne-Regular", size: 15))
                            .foregroundColor(Color("Light1")) // Changed to full opacity when typing
                            .padding()
                            .background(Color("Light2").opacity(0.3))
                            .cornerRadius(23)
                            .frame(width: 350) // Fixed width
                            .onChange(of: challengeName) { oldValue, newValue in
                                if newValue.count > maxChallengeNameLength {
                                    challengeName = String(newValue.prefix(maxChallengeNameLength))
                                }
                            }
                        
                        Text("\(challengeName.count)/\(maxChallengeNameLength)")
                            .font(.custom("RussoOne-Regular", size: 11))
                            .foregroundColor(Color("Light1").opacity(0.6))
                            .padding(.leading, 5)
                    }
                    
                    // Period Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Period")
                            .font(.custom("RussoOne-Regular", size: 16))
                            .foregroundColor(Color("Light1"))
                        
                        HStack(spacing: 12) {
                            ForEach(ChallengePeriod.allCases, id: \.self) { period in
                                Button(action: {
                                    selectedPeriod = period
                                }) {
                                    Text(period.rawValue)
                                        .font(.custom("RussoOne-Regular", size: 15))
                                        .foregroundColor(selectedPeriod == period ? .white : Color("Light1"))
                                        .frame(width: 90, height: 40)
                                        .background(
                                            selectedPeriod == period ?
                                            Color("Light1") : Color.white
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    
                    // Steps Slider
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Steps")
                            .font(.custom("RussoOne-Regular", size: 16))
                            .foregroundColor(Color("Light1"))
                        
                        VStack(spacing: 6) {
                            Slider(value: $stepGoal, in: minSteps...maxSteps, step: 1000)
                                .tint(Color("Light1"))
                            
                            HStack {
                                Text("\(Int(minSteps).formatted())")
                                    .font(.custom("RussoOne-Regular", size: 11))
                                    .foregroundColor(Color("Light1").opacity(0.6))
                                
                                Spacer()
                                
                                Text("\(Int(stepGoal).formatted())")
                                    .font(.custom("RussoOne-Regular", size: 15))
                                    .foregroundColor(Color("Light1"))
                                
                                Spacer()
                                
                                Text("\(Int(maxSteps).formatted())")
                                    .font(.custom("RussoOne-Regular", size: 11))
                                    .foregroundColor(Color("Light1").opacity(0.6))
                            }
                        }
                    }
                    
                    // Mode Selection
                    HStack(spacing: 25) {
                        // Solo Mode
                        Button(action: {
                            selectedMode = .solo
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 16))
                                Text("Solo")
                                    .font(.custom("RussoOne-Regular", size: 15))
                            }
                            .foregroundColor(selectedMode == .solo ? .white : Color("Light1"))
                            .frame(width: 120, height: 40)
                            .background(
                                selectedMode == .solo ?
                                Color("Light1") : Color.white
                            )
                            .cornerRadius(25)
                        }
                        
                        // Group Mode
                        Button(action: {
                            selectedMode = .social
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 16))
                                Text("Group")
                                    .font(.custom("RussoOne-Regular", size: 15))
                            }
                            .foregroundColor(selectedMode == .social ? .white : Color("Light1"))
                            .frame(width: 120, height: 40)
                            .background(
                                selectedMode == .social ?
                                Color("Light1") : Color.white
                            )
                            .cornerRadius(25)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Create Button
                    Button(action: {
                        Task {
                            await createChallenge()
                        }
                    }) {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            Text("Create")
                                .font(.custom("RussoOne-Regular", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .background(Color("Light2"))
                    .cornerRadius(30)
                    .disabled(challengeName.trimmingCharacters(in: .whitespaces).isEmpty || isCreating)
                    .opacity(challengeName.trimmingCharacters(in: .whitespaces).isEmpty || isCreating ? 0.6 : 1.0)
                    .padding(.top, 5)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 25)
            }
            .background(Color("Light3"))
            .cornerRadius(30)
            .padding(.horizontal, 25)
            .frame(maxHeight: 900)
            
            // Share Code Popup (for group mode)
            if showShareCodePopup {
                ShareCodePopup(isPresented: $showShareCodePopup, joinCode: generatedJoinCode)
            }
        }
        .presentationDetents([.height(550)])
        .background(Color("Light3"))
    }
    
    private func createChallenge() async {
        isCreating = true
        
        // Check if running in preview mode
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            // Preview mode - simulate
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                if selectedMode == .social {
                    generatedJoinCode = generateJoinCode()
                    showShareCodePopup = true
                } else {
                    dismiss()
                    // TODO: Navigate to map/game
                }
                isCreating = false
            }
            return
        }
        #endif
        
        do {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                isCreating = false
                return
            }
            
            let joinCode = generateJoinCode()
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .day, value: selectedPeriod.days, to: startDate) ?? startDate
            
            let challenge = Challenge(
                joinCode: joinCode,
                mode: selectedMode.rawValue,
                originalMode: selectedMode.rawValue,
                goalSteps: Int(stepGoal),
                durationDays: selectedPeriod.days,
                status: "active",
                createdBy: userId,
                playerIds: [userId],
                startDate: startDate,
                endDate: endDate,
                createdAt: Date()
            )
            
            try await saveChallengeToFirestore(challenge: challenge)
            
            await MainActor.run {
                isCreating = false
                
                if selectedMode == .social {
                    // Show share code popup for group challenges
                    generatedJoinCode = joinCode
                    showShareCodePopup = true
                } else {
                    // Go directly to map for solo challenges
                    dismiss()
                    // TODO: Navigate to map/game view
                    print("Solo challenge created, navigating to map")
                }
            }
            
        } catch {
            await MainActor.run {
                isCreating = false
            }
            print("Error creating challenge: \(error.localizedDescription)")
        }
    }
    
    private func generateJoinCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
    
    private func saveChallengeToFirestore(challenge: Challenge) async throws {
        let db = Firestore.firestore()
        
        let challengeData: [String: Any] = [
            "joinCode": challenge.joinCode,
            "mode": challenge.mode,
            "originalMode": challenge.originalMode,
            "goalSteps": challenge.goalSteps,
            "durationDays": challenge.durationDays,
            "status": challenge.status,
            "createdBy": challenge.createdBy,
            "playerIds": challenge.playerIds,
            "startDate": Timestamp(date: challenge.startDate),
            "endDate": Timestamp(date: challenge.endDate),
            "createdAt": Timestamp(date: challenge.createdAt)
        ]
        
        try await db.collection("challenges").addDocument(data: challengeData)
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        SetupChallengeView(playerName: "Aisha")
    }
}
