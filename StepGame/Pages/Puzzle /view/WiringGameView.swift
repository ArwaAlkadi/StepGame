//
//  WiringGameView.swift
//  StepGame
//
//  Created by Rana Alqubaly on 17/08/1447 AH.
//

import SwiftUI


// MARK: - Game View
struct WiringGameView: View {
    @StateObject private var viewModel: WiringGameViewModel
    @ObservedObject var coordinator: GameCoordinatorViewModel
    let gameMode: GameMode
    let playerRole: PlayerRole?
    @Environment(\.dismiss) var dismiss
    
    @State private var showResult = false
    @State private var gameResult: GameResult = .success
    
    init(coordinator: GameCoordinatorViewModel, gameMode: GameMode, playerRole: PlayerRole?, timeLimit: Double = 8.0) {
        self.coordinator = coordinator
        self.gameMode = gameMode
        self.playerRole = playerRole
        self._viewModel = StateObject(wrappedValue: WiringGameViewModel(timeLimit: timeLimit))
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.96, green: 0.87, blue: 0.70),
                        Color(red: 0.94, green: 0.85, blue: 0.68),
                        Color(red: 0.96, green: 0.87, blue: 0.70)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("Fix Wiring")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                        
                        HStack(spacing: 8) {
                            Image(systemName: "timer")
                                .foregroundColor(viewModel.timeRemaining <= 3 ? .red : Color(red: 0.17, green: 0.09, blue: 0.06))
                            Text(String(format: "%.1f", max(0, viewModel.timeRemaining)))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(viewModel.timeRemaining <= 3 ? .red : Color(red: 0.17, green: 0.09, blue: 0.06))
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.91, green: 0.79, blue: 0.64))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                        coordinator.reset()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color(red: 0.63, green: 0.32, blue: 0.18))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Game Board
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.85, green: 0.75, blue: 0.60))
                        .shadow(radius: 20)
                    
                    GeometryReader { geometry in
                        let wireSpacing: CGFloat = 70
                        let startY: CGFloat = 60
                        let leftPositions = (0..<viewModel.leftWires.count).map { CGFloat($0) * wireSpacing + startY }
                        let rightPositions = (0..<viewModel.rightWires.count).map { CGFloat($0) * wireSpacing + startY }
                        
                        ForEach(viewModel.connections) { connection in
                            WireConnectionView(connection: connection, leftPositions: leftPositions, rightPositions: rightPositions)
                        }
                        
                        // Active dragging wire
                        if let dragLocation = viewModel.currentDragLocation {
                            ActiveDragWireView(
                                dragLocation: dragLocation,
                                draggedLeftIndex: viewModel.draggedLeftIndex,
                                draggedRightIndex: viewModel.draggedRightIndex,
                                leftPositions: leftPositions,
                                rightPositions: rightPositions,
                                leftWires: viewModel.leftWires,
                                rightWires: viewModel.rightWires,
                                width: geometry.size.width
                            )
                        }
                        
                        
                        
                        LeftWiresColumn(
                            viewModel: viewModel,
                            geometry: geometry,
                            rightPositions: rightPositions
                        )
                        
                        RightWiresColumn(
                            viewModel: viewModel,
                            geometry: geometry,
                            leftPositions: leftPositions
                        )
                    }
                }
            }
            
            // Result overlay
            if showResult {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                GameResultView(
                    result: gameResult,
                    mode: gameMode,
                    role: playerRole,
                    onClose: {
                        dismiss()
                        coordinator.reset()
                    },
                    onRetry: {
                        showResult = false
                        viewModel.resetGame()
                    }
                )

            }
        }
        .onChange(of: viewModel.isComplete) { completed in
            if completed {
                gameResult = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showResult = true
                }
            }
        }
        .onChange(of: viewModel.hasFailed) { failed in
            if failed {
                gameResult = .failure
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showResult = true
                }
                
            }
        }
    }
    
    private func handleLeftDragEnd(value: DragGesture.Value, geometry: GeometryProxy, rightPositions: [CGFloat]) {
        let endLocation = value.location
        
        if endLocation.x > geometry.size.width / 2 {
            var closestIndex = 0
            var minDistance = CGFloat.infinity
            
            for i in 0..<rightPositions.count {
                let distance = abs(endLocation.y - rightPositions[i])
                if distance < minDistance {
                    minDistance = distance
                    closestIndex = i
                }
            }
            
            if minDistance < 50 {
                viewModel.dropOnRight(rightIndex: closestIndex)
            } else {
                viewModel.cancelDrag()
            }
        } else {
            viewModel.cancelDrag()
        }
    }
    
    private func handleRightDragEnd(value: DragGesture.Value, geometry: GeometryProxy, leftPositions: [CGFloat]) {
        let endLocation = value.location
        
        if endLocation.x < geometry.size.width / 2 {
            var closestIndex = 0
            var minDistance = CGFloat.infinity
            
            for i in 0..<leftPositions.count {
                let distance = abs(endLocation.y - leftPositions[i])
                if distance < minDistance {
                    minDistance = distance
                    closestIndex = i
                }
            }
            
            if minDistance < 50 {
                viewModel.dropOnLeft(leftIndex: closestIndex)
            } else {
                viewModel.cancelDrag()
            }
        } else {
            viewModel.cancelDrag()
        }
    }
    
}
