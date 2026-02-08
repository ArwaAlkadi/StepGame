
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// dummy data
let USE_DUMMY_DATA_JOIN = true


struct JoinWithCodeView: View {
    let playerName: String
    @Binding var isPresented: Bool
    
    @State private var joinCode: String = ""
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var isJoining: Bool = false
    
    private let maxCodeLength = 6
    
    var body: some View {
        ZStack {
            // Blurred Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Modal Card - Centered
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
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
                Text("Join with a code")
                    .font(.custom("RussoOne-Regular", size: 24))
                    .foregroundColor(Color("Light1"))
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                
                VStack(spacing: 20) {
                    // Join Code Input
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("", text: $joinCode)
                            .font(.custom("RussoOne-Regular", size: 18))
                            .foregroundColor(Color("Light1"))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .autocapitalization(.allCharacters)
                            .onChange(of: joinCode) { oldValue, newValue in
                                // Limit to 6 characters
                                if newValue.count > maxCodeLength {
                                    joinCode = String(newValue.prefix(maxCodeLength))
                                }
                                // Clear error when user types
                                if showError {
                                    showError = false
                                    errorMessage = ""
                                }
                            }
                            .overlay(
                                Group {
                                    if joinCode.isEmpty {
                                        Text("ex: qu123z..")
                                            .font(.custom("RussoOne-Regular", size: 18))
                                            .foregroundColor(Color("Light1").opacity(0.4))
                                            .padding(.leading, 16)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .leading
                            )
                        
                        // Error Message
                        if showError {
                            Text(errorMessage)
                                .font(.custom("RussoOne-Regular", size: 12))
                                .foregroundColor(.red)
                                .padding(.leading, 5)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Join Button
                    Button(action: {
                        Task {
                            await joinChallenge()
                        }
                    }) {
                        if isJoining {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 200, height: 55)
                        } else {
                            Text("Join")
                                .font(.custom("RussoOne-Regular", size: 20))
                                .foregroundColor(.white)
                                .frame(width: 200, height: 55)
                        }
                    }
                    .background(Color("Light1"))
                    .cornerRadius(30)
                    .disabled(joinCode.isEmpty || isJoining)
                    .opacity(joinCode.isEmpty || isJoining ? 0.6 : 1.0)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
            .background(Color("Light3"))
            .cornerRadius(30)
            .frame(width: 350)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
    
    private func joinChallenge() async {
        //MARK: start of the  Dummy data mode - for testing without Firebase
        if USE_DUMMY_DATA_JOIN {
            print("🎮 DUMMY MODE: Joining challenge")
            print("Code entered: \(joinCode)")
            
            // Simulate delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Simulate validation - codes starting with "QU" are valid
            if joinCode.uppercased().hasPrefix("QU") {
                await MainActor.run {
                    isJoining = false
                    isPresented = false
                    print("✅ Successfully joined challenge with code: \(joinCode)")
                }
            } else {
                await MainActor.run {
                    errorMessage = "Invalid code. Try again."
                    showError = true
                    isJoining = false
                    print("❌ Invalid code: \(joinCode)")
                }
            }
            return
        }
        // MARK: end of the dummyy data
        isJoining = true
        
        do {
            let db = Firestore.firestore()
            let code = joinCode.uppercased().trimmingCharacters(in: .whitespaces)
            
            // Step 1: Find challenge with this join code
            let querySnapshot = try await db.collection("challenges")
                .whereField("joinCode", isEqualTo: code)
                .whereField("status", isEqualTo: "active")
                .getDocuments()
            
            guard let challengeDoc = querySnapshot.documents.first else {
                // Challenge not found
                await MainActor.run {
                    errorMessage = "Invalid code. Try again."
                    showError = true
                    isJoining = false
                }
                return
            }
            
            let challengeData = challengeDoc.data()
            guard let playerIds = challengeData["playerIds"] as? [String] else {
                await MainActor.run {
                    errorMessage = "Invalid challenge data."
                    showError = true
                    isJoining = false
                }
                return
            }
            
            // Get maxPlayers with default value of 2
            let maxPlayers = challengeData["maxPlayers"] as? Int ?? 2
            
            // Step 2: Check if challenge is full
            if playerIds.count >= maxPlayers {
                await MainActor.run {
                    errorMessage = "Challenge is full."
                    showError = true
                    isJoining = false
                }
                return
            }
            
            // Step 3: Get current user ID
            guard let userId = Auth.auth().currentUser?.uid else {
                await MainActor.run {
                    errorMessage = "User not authenticated."
                    showError = true
                    isJoining = false
                }
                return
            }
            
            // Step 4: Check if user already in challenge
            if playerIds.contains(userId) {
                await MainActor.run {
                    errorMessage = "Already in this challenge."
                    showError = true
                    isJoining = false
                }
                return
            }
            
            // Step 5: Add player to challenge
            var updatedPlayerIds = playerIds
            updatedPlayerIds.append(userId)
            
            try await db.collection("challenges").document(challengeDoc.documentID)
                .updateData(["playerIds": updatedPlayerIds])
            
            // Step 6: Success - dismiss and navigate to challenge
            await MainActor.run {
                isJoining = false
                isPresented = false
                // TODO: Navigate to challenge view
                print("Successfully joined challenge: \(challengeDoc.documentID)")
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Error joining challenge."
                showError = true
                isJoining = false
            }
            print("Error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        JoinWithCodeView(playerName: "Aisha", isPresented: .constant(true))
    }
}
