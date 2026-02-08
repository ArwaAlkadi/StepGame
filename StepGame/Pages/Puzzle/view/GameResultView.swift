//
//  GameResultView.swift
//  StepGame
//
//  Created by Rana Alqubaly on 20/08/1447 AH.
//

import SwiftUI


struct GameResultView: View {
    let result: GameResult
    let mode: GameMode
    let role: PlayerRole?
    let onClose: () -> Void
    let onRetry: () -> Void
    
    var body: some View {
        var lunaImageName: String {
                            result == .success ? "luna happy" : "luna sad"
                        }
        DialogBaseView(onClose: onClose) {
            VStack(spacing: 20) {
                

                
                    
                Text(getTitle())
                    .font(.custom("RussoOne-Regular", size: 35))
                                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                                    .multilineTextAlignment(.center)
            
                Image(lunaImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 250)
                
                
                Text(getMessage())
                    .font(.custom("RussoOne-Regular", size: 25))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
            
            }
            //.padding(.top, 20)
        }
    }
    
    private func getTitle() -> String {
        if result == .success {
            switch mode {
            case .solo:
                return "Awesome!"
            case .group:
                return role == .attacker ? "Awesome!" : "Awesome!"
            }
        } else {
            return "Oops!"
        }
    }
    
    private func getMessage() -> String {
        if result == .success {
            switch mode {
            case .solo:
                return "You solved the puzzle"
            case .group:
                return role == .attacker ? "You solved the puzzle" : "You solved the puzzle"
            }
        } else {
            return "You didn't solve the puzzle on time"
        }
    }
}
