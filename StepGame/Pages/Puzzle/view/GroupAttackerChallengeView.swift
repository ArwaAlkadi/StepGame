//
//  GroupAttackerChallengeView.swift
//  StepGame
//
//  Created by Rana Alqubaly on 17/08/1447 AH.
//

import SwiftUI


// MARK: - Popup Views
struct GroupAttackerChallengeView: View {
    @ObservedObject var viewModel: GameCoordinatorViewModel
    
    var body: some View {
        DialogBaseView(onClose: { viewModel.reset() }) {
            VStack(spacing: 20) {
                Text("Take Your Chance")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                
                Text("Win this puzzle to mess up your friend's character for 3 hours.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 15) {
                    Button(action: {
                        viewModel.startAttackerGame()
                    }) {
                        Text("Yes")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 120)
                            .padding(.vertical, 15)
                            .background(Color(red: 0.29, green: 0.15, blue: 0.07))
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        viewModel.reset()
                    }) {
                        Text("No")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.29, green: 0.15, blue: 0.07))
                            .frame(width: 120)
                            .padding(.vertical, 15)
                            .background(Color(red: 0.91, green: 0.79, blue: 0.64))
                            .cornerRadius(25)
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}

struct GroupDefenderChallengeView: View {
    @ObservedObject var viewModel: GameCoordinatorViewModel
    
    var body: some View {
        DialogBaseView(onClose: { viewModel.reset() }) {
            VStack(spacing: 20) {
                Text("Defend Your Progress")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                
                Text("Solve the puzzle to protect your progress. Hurry!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 15) {
                    Button(action: {
                        viewModel.startDefenderGame()
                    }) {
                        Text("Defend")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 120)
                            .padding(.vertical, 15)
                            .background(Color(red: 0.29, green: 0.15, blue: 0.07))
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        viewModel.reset()
                    }) {
                        Text("Give Up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.29, green: 0.15, blue: 0.07))
                            .frame(width: 120)
                            .padding(.vertical, 15)
                            .background(Color(red: 0.91, green: 0.79, blue: 0.64))
                            .cornerRadius(25)
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}

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
