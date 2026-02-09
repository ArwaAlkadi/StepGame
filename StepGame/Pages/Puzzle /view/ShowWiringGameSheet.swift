//
//  ShowWiringGameSheet.swift
//  StepGame
//
//  Created by Rana Alqubaly on 17/08/1447 AH.
//

import SwiftUI


// MARK: - Main Coordinator View
struct ShowWiringGameSheet: View {
    @ObservedObject var coordinator: GameCoordinatorViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.91, green: 0.91, blue: 0.91),
                        Color(red: 0.82, green: 0.82, blue: 0.82)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            switch coordinator.currentView {
            case .none:
                EmptyView()

            


            case .soloGame:
                WiringGameView(
                    coordinator: coordinator,
                    gameMode: .solo,
                    playerRole: nil,
                    timeLimit: 6.0
                )


            case .attackerGame:
                WiringGameView(
                    coordinator: coordinator,
                    gameMode: .group,
                    playerRole: .attacker,
                    timeLimit: 6.0
                )

            case .defenderGame:
                WiringGameView(
                    coordinator: coordinator,
                    gameMode: .group,
                    playerRole: .defender,
                    timeLimit: 6.0
                )
            }

        }
    }
}


