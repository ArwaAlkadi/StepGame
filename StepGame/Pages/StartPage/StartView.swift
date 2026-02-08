

import SwiftUI

struct StartView: View {
    let playerName: String
    @State private var showSetupChallenge = false
    @State private var showJoinWithCode = false
    
    var body: some View {
        ZStack {
            // Background Image
            Image("Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Profile Icon (top right)
                HStack {
                    Spacer()
                    Button(action: {
                        // Navigate to profile
                    }) {
                        Image("Avatar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .opacity(0.2)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.top, -220)
                }
                
                Spacer()
                
                // Greeting Text
                VStack(spacing: 10) {
                    Text("Hello, \(playerName)!")
                        .font(.custom("RussoOne-Regular", size: 32))
                        .foregroundColor(Color("Light1"))
                        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                    
                    Text("stay active")
                        .font(.custom("RussoOne-Regular", size: 28))
                        .foregroundColor(Color("Light1"))
                        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                }
                .padding(.bottom, 40)
                
                // Buttons
                VStack(spacing: 20) {
                    // Start New Challenge Button
                    Button(action: {
                        showSetupChallenge = true
                    }) {
                        Text("Start new challenge")
                            .font(.custom("RussoOne-Regular", size: 20))
                            .foregroundColor(.light3)
                            .frame(width: 280, height: 55)
                            .background(Color("Light1"))
                            .cornerRadius(30)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    
                    // Join with Code Button
                    Button(action: {
                        showJoinWithCode = true
                    }) {
                        Text("Join with code")
                            .font(.custom("RussoOne-Regular", size: 20))
                            .foregroundColor(.light3)
                            .frame(width: 280, height: 55)
                            .background(Color("Light1"))
                            .cornerRadius(30)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                }
                .padding(.bottom, 80)
            }
            
            // Join with Code Popup (centered overlay)
            if showJoinWithCode {
                JoinWithCodeView(playerName: playerName, isPresented: $showJoinWithCode)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showSetupChallenge) {
            SetupChallengeView(playerName: playerName)
        }
    }
}

#Preview {
    StartView(playerName: "Aisha")
}
