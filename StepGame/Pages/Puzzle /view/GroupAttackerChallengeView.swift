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
                    .font(.custom("RussoOne-Regular", size: 28))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                
                Text("Win this puzzle to mess up your friend's character for 3 hours.")
                    .font(.custom("RussoOne-Regular", size: 18))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 15) {
                    Button(action: {
                        viewModel.startAttackerGame()
                    }) {
                        Text("Yes")
                            .font(.custom("RussoOne-Regular", size: 18))
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
                            .font(.custom("RussoOne-Regular", size: 18))
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


