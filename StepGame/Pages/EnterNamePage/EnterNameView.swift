
import SwiftUI

struct EnterNameView: View {
    @State private var playerName: String = ""
    @State private var navigateToStart = false
    private let maxCharacters = 20
    
    var body: some View {
        ZStack {
            // Background Image
            Image("Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Bottom Container with Light2 background
                ZStack(alignment: .top) {
                    // Light2 rounded container
                    VStack(spacing: 30) {
                        // Spacer for character
                        //Spacer()
                          //  .frame(height: 10)
                        
                        // Title
                        Text("Enter Your Name!")
                            .font(.custom("RussoOne-Regular", size: 28))
                            .foregroundColor(.light3)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                            .padding(.top, 20)
                        
                        // Name Input Field
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Name", text: $playerName)
                                .font(.custom("RussoOne-Regular", size: 18))
                                .foregroundColor(Color("Light1"))
                                .padding()
                                .background(Color("Light3").opacity(0.4))
                                .cornerRadius(25)
                                .frame(maxWidth: 320)
                                .onChange(of: playerName) { oldValue, newValue in
                                    if newValue.count > maxCharacters {
                                        playerName = String(newValue.prefix(maxCharacters))
                                    }
                                }
                            
                            // Character counter
                            Text("\(playerName.count)/\(maxCharacters)")
                                .font(.custom("RussoOne-Regular", size: 12))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.leading, 15)
                        }
                        
                        // Start Button
                        Button(action: {
                            if !playerName.trimmingCharacters(in: .whitespaces).isEmpty {
                                navigateToStart = true
                            }
                        }) {
                            Text("Start")
                                .font(.custom("RussoOne-Regular", size: 22))
                                .foregroundColor(.white)
                                .frame(width: 220, height: 55)
                                .background(Color("Light1"))
                                .cornerRadius(30)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(playerName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                        .padding(.bottom, 50)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color("Light2"))
                    )
                    .padding(.horizontal, 0)
                    
                    // Character Image overlapping the container
                    Image("Enter nameP")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                        .offset(y: -213)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationDestination(isPresented: $navigateToStart) {
            StartView(playerName: playerName)
        }
    }
}

#Preview {
    EnterNameView()
}

//
//  EnterNameView.swift
//  StepGame
//
//  Created by Claude on 02/02/2026.
//

//import SwiftUI
//import FirebaseAuth
//import FirebaseFirestore
//
//struct EnterNameView: View {
//    @State private var playerName: String = ""
//    @State private var navigateToStart = false
//    @State private var showHealthKitAlert = false
//    @State private var isCreatingUser = false
//    @StateObject private var healthKitService = HealthKitService()
//
//    private let maxCharacters = 20
//    
//    var body: some View {
//        ZStack {
//            // Background Image
//            Image("Background")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                Spacer()
//                
//                // Bottom Container with Light2 background
//                ZStack(alignment: .top) {
//                    // Light2 rounded container
//                    VStack(spacing: 30) {
//                        // Title
//                        Text("Enter Your Name!")
//                            .font(.custom("RussoOne-Regular", size: 28))
//                            .foregroundColor(.light3)
//                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
//                            .padding(.top, 20)
//                        
//                        // Name Input Field
//                        VStack(alignment: .leading, spacing: 6) {
//                            TextField("Name", text: $playerName)
//                                .font(.custom("RussoOne-Regular", size: 18))
//                                .foregroundColor(Color("Light1"))
//                                .padding()
//                                .background(Color("Light3").opacity(0.4))
//                                .cornerRadius(25)
//                                .frame(maxWidth: 320)
//                                .onChange(of: playerName) { oldValue, newValue in
//                                    if newValue.count > maxCharacters {
//                                        playerName = String(newValue.prefix(maxCharacters))
//                                    }
//                                }
//                            
//                            // Character counter
//                            Text("\(playerName.count)/\(maxCharacters)")
//                                .font(.custom("RussoOne-Regular", size: 12))
//                                .foregroundColor(.white.opacity(0.8))
//                                .padding(.leading, 15)
//                        }
//                        
//                        // Start Button
//                        Button(action: {
//                            Task {
//                                await createUserAndRequestHealthKit()
//                            }
//                        }) {
//                            if isCreatingUser {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                    .frame(width: 220, height: 55)
//                                    .background(Color("Light1"))
//                                    .cornerRadius(30)
//                            } else {
//                                Text("Start")
//                                    .font(.custom("RussoOne-Regular", size: 22))
//                                    .foregroundColor(.white)
//                                    .frame(width: 220, height: 55)
//                                    .background(Color("Light1"))
//                                    .cornerRadius(30)
//                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
//                            }
//                        }
//                        .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty || isCreatingUser)
//                        .opacity(playerName.trimmingCharacters(in: .whitespaces).isEmpty || isCreatingUser ? 0.6 : 1.0)
//                        .padding(.bottom, 50)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .background(
//                        RoundedRectangle(cornerRadius: 40)
//                            .fill(Color("Light2"))
//                    )
//                    .padding(.horizontal, 0)
//                    
//                    // Character Image overlapping the container
//                    Image("Enter nameP")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 240, height: 240)
//                        .offset(y: -213)
//                }
//            }
//            .ignoresSafeArea(edges: .bottom)
//        }
//        .navigationDestination(isPresented: $navigateToStart) {
//            StartView(playerName: playerName)
//        }
//        .alert("HealthKit Access Required", isPresented: $showHealthKitAlert) {
//            Button("OK") { }
//        } message: {
//            Text("Please allow access to Health app in Settings to track your steps.")
//        }
//    }
//    
//    private func createUserAndRequestHealthKit() async {
//        isCreatingUser = true
//        
//        do {
//            // Step 1: Create Firebase Anonymous User (this gives us a unique user ID)
//            let authResult = try await Auth.auth().signInAnonymously()
//            let userId = authResult.user.uid
//            
//            // Step 2: Request HealthKit Authorization
//            if HealthKitService.isHealthKitAvailable() {
//                try await healthKitService.requestAuthorization()
//            } else {
//                showHealthKitAlert = true
//            }
//            
//            // Step 3: Create Player document in Firestore
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
//            // Step 4: Navigate to Start Page
//            await MainActor.run {
//                isCreatingUser = false
//                navigateToStart = true
//            }
//            
//        } catch {
//            await MainActor.run {
//                isCreatingUser = false
//                showHealthKitAlert = true
//            }
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
//}
//
//#Preview {
//    EnterNameView()
//}
