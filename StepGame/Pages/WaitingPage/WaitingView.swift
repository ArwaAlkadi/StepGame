//
//  WaitingView.swift
//  StepGame
//
//  Created by Arwa Alkadi on 30/01/2026.
//

import SwiftUI

struct WaitingRoomView: View {
    let challengeName: String
    let goalStepsText: String
    let joinCode: String
    let isHost: Bool
    let canStart: Bool
    let players: [WaitingPlayer]
    let maxPlayers: Int
    let onCopyCode: () -> Void
    let onStart: () -> Void
    init(
        challengeName: String = "",
        goalStepsText: String = "",
        joinCode: String = "",
        isHost: Bool = false,
        canStart: Bool = false,
        players: [WaitingPlayer] = [],
        maxPlayers: Int = 2,
        onCopyCode: @escaping () -> Void = {},
        onStart: @escaping () -> Void = {}
    ) {
        self.challengeName = challengeName
        self.goalStepsText = goalStepsText
        self.joinCode = joinCode
        self.isHost = isHost
        self.canStart = canStart
        self.players = players
        self.maxPlayers = maxPlayers
        self.onCopyCode = onCopyCode
        self.onStart = onStart
    }

    
    var body: some View {
        ZStack{
            Color("Light3")
            .ignoresSafeArea()
            VStack(spacing: 22) {
                
                header
                
                joinCodeRow
                
                Spacer(minLength: 8)
                
                if players.isEmpty {
                    emptyState
                } else {
                    playersState
                }
                
                Spacer(minLength: 8)
                
                bottomSection
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
            
        }
    }
}


struct WaitingPlayer: Identifiable, Hashable {
    let id: String
    let name: String
    let isMe: Bool
    
}

extension WaitingRoomView {
    
    
    var header: some View {
        VStack(spacing: 2) {
            Text("challlengs")
                .font(.custom("RussoOne-Regular", size: 30))
                .foregroundColor(Color("Light2"))
            Text(goalStepsText)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundColor(Color("Light2"))
            
            VStack{
                HStack(spacing:8){
                    Image("shoes")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height:12)
                        .foregroundColor(Color("Light5"))
                    
                    Text("2,000 Steps")
                        .font(.custom("RussoOne-Regular", size: 12))
                        .foregroundColor(Color("Light5"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                
                .background(
                    Capsule()
                        .fill(Color("Light2"))
                )
                
            }
        }
        .padding(.top, 10)
    }
    
    var joinCodeRow: some View {
        HStack(spacing: 8) {
            
            Text(joinCode)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Button(action: onCopyCode) {
                Image("CopyIcon")
                    .resizable()
                    .frame(width: 20,height: 20)
                
                    .foregroundColor(Color("Light2"))
                
                Text("SF436N")
                    .font(.custom("RussoOne-Regular", size: 20))
                    .foregroundColor(Color("Light1"))
                
                
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color("Light4"))
        .clipShape(Capsule())
    }
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Image("Tent")
            Text("Waiting for players to join…")
                .font(.custom("RussoOne-Regular", size: 24))
                .foregroundColor(Color("Light1"))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }
    var playersState: some View {
        VStack(spacing: 22) {
            
            Image(systemName: "tent.fill")
                .font(.system(size: 40))
                .background(Color("Light3"))
            
        }
        .padding(.top, 20)
    }
   
    var bottomSection: some View {
        Group {
            if isHost {
                Button(action: onStart) {
                    Text("Start!")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canStart ? Color.brown : Color.gray.opacity(0.4))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .disabled(!canStart)
                .padding(.bottom, 6)
                
                //            } else {
                //                Text("Waiting for the host to start the challenge")
                //                    .font(.system(size: 16, weight: .semibold))
                //                    .foregroundColor(Color.brown.opacity(0.8))
                //                    .multilineTextAlignment(.center)
                //                    .padding(.horizontal, 18)
                //                    .padding(.bottom, 10)
            }
        }
        
    }
}


#Preview {
    WaitingRoomView()
}
