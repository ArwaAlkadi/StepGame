//
//  WiringGameViewModel.swift
//  StepGame
//
//  Created by Rana Alqubaly on 16/08/1447 AH.
//

import Foundation
import Combine
import SwiftUI


// MARK: - ViewModels
class WiringGameViewModel: ObservableObject {
    @Published var leftWires: [WireColor] = []
    @Published var rightWires: [WireColor] = []
    @Published var connections: [WireConnection] = []
    @Published var selectedLeft: Int? = nil
    @Published var selectedRight: Int? = nil
    @Published var isComplete = false
    @Published var hasFailed = false
    @Published var timeRemaining: Double = 8.0
    @Published var draggedLeftIndex: Int? = nil
    @Published var draggedRightIndex: Int? = nil
    @Published var hoveredLeftIndex: Int? = nil
    @Published var hoveredRightIndex: Int? = nil
    
    private let model: WiringGameModel
    private var timer: Timer?
    var timeLimit: Double = 8.0
    
    init(timeLimit: Double = 8.0) {
        self.timeLimit = timeLimit
        self.model = WiringGameModel()
        updateState()
        startTimer()
    }
    
    private func updateState() {
        leftWires = model.leftWires
        rightWires = model.rightWires
        connections = model.connections
        isComplete = model.isComplete()
        
        if isComplete {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timeRemaining = timeLimit
        hasFailed = false
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 && !self.isComplete {
                self.timeRemaining -= 0.1
            } else if self.timeRemaining <= 0 && !self.isComplete {
                self.hasFailed = true
                self.stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func handleLeftTap(index: Int) {
        guard !hasFailed && !isComplete else { return }
        
        if let rightIndex = selectedRight {
            if model.connect(leftIndex: index, rightIndex: rightIndex) {
                selectedRight = nil
                selectedLeft = nil
            }
        } else {
            if connections.contains(where: { $0.leftIndex == index }) {
                model.disconnect(leftIndex: index)
                selectedLeft = nil
            } else {
                selectedLeft = selectedLeft == index ? nil : index
                selectedRight = nil
            }
        }
        updateState()
    }
    
    func handleRightTap(index: Int) {
        guard !hasFailed && !isComplete else { return }
        
        if let leftIndex = selectedLeft {
            if model.connect(leftIndex: leftIndex, rightIndex: index) {
                selectedLeft = nil
                selectedRight = nil
            }
        } else {
            if connections.contains(where: { $0.rightIndex == index }) {
                model.disconnectRight(rightIndex: index)
                selectedRight = nil
            } else {
                selectedRight = selectedRight == index ? nil : index
                selectedLeft = nil
            }
        }
        updateState()
    }
    
    func startDraggingLeft(index: Int) {
        guard !hasFailed && !isComplete else { return }
        draggedLeftIndex = index
        if connections.contains(where: { $0.leftIndex == index }) {
            model.disconnect(leftIndex: index)
            updateState()
        }
    }
    
    func dropOnRight(rightIndex: Int) {
        guard !hasFailed && !isComplete else { return }
        guard let leftIndex = draggedLeftIndex else { return }
        
        _ = model.connect(leftIndex: leftIndex, rightIndex: rightIndex)
        draggedLeftIndex = nil
        hoveredRightIndex = nil
        updateState()
    }
    
    func startDraggingRight(index: Int) {
        guard !hasFailed && !isComplete else { return }
        draggedRightIndex = index
        if connections.contains(where: { $0.rightIndex == index }) {
            model.disconnectRight(rightIndex: index)
            updateState()
        }
    }
    
    func dropOnLeft(leftIndex: Int) {
        guard !hasFailed && !isComplete else { return }
        guard let rightIndex = draggedRightIndex else { return }
        
        _ = model.connect(leftIndex: leftIndex, rightIndex: rightIndex)
        draggedRightIndex = nil
        hoveredLeftIndex = nil
        updateState()
    }
    
    func cancelDrag() {
        draggedLeftIndex = nil
        draggedRightIndex = nil
        hoveredLeftIndex = nil
        hoveredRightIndex = nil
    }
    
    func resetGame() {
        model.reset()
        selectedLeft = nil
        selectedRight = nil
        draggedLeftIndex = nil
        draggedRightIndex = nil
        hoveredLeftIndex = nil
        hoveredRightIndex = nil
        updateState()
        startTimer()
    }
    
    deinit {
        stopTimer()
    }
}

class GameCoordinatorViewModel: ObservableObject {
    @Published var currentView: GameView = .groupAttackerChallenge
    @Published var attackerCompleted: Bool = false
    
    enum GameView {
        case groupAttackerChallenge
        case groupDefenderChallenge
        case attackerGame
        case defenderGame
    }
    
    func startAttackerGame() {
        currentView = .attackerGame
    }
    
    func attackerGameCompleted() {
        attackerCompleted = true
        currentView = .groupDefenderChallenge
    }
    
    func startDefenderGame() {
        currentView = .defenderGame
    }
    
    func reset() {
        currentView = .groupAttackerChallenge
        attackerCompleted = false
    }
}

// MARK: - Reusable Components
struct WireNodeView: View {
    let color: WireColor
    let isSelected: Bool
    let isDragging: Bool
    let isHovered: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.color)
                .frame(width: 50, height: 50)
                .shadow(color: color.color.opacity(0.8), radius: isSelected || isDragging || isHovered ? 20 : 10)
            
            Circle()
                .stroke(Color.black.opacity(0.3), lineWidth: 4)
                .frame(width: 50, height: 50)
            
            if isSelected || isHovered {
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 58, height: 58)
            }
            
            if isDragging {
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 3)
                    .frame(width: 65, height: 65)
            }
        }
        .scaleEffect(isSelected || isDragging ? 1.1 : isHovered ? 1.05 : 1.0)
        .opacity(isDragging ? 0.6 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .animation(.spring(response: 0.3), value: isDragging)
        .animation(.spring(response: 0.3), value: isHovered)
    }
}

struct WireConnectionView: View {
    let connection: WireConnection
    let leftPositions: [CGFloat]
    let rightPositions: [CGFloat]
    
    var body: some View {
        let startY = leftPositions[connection.leftIndex]
        let endY = rightPositions[connection.rightIndex]
        
        Path { path in
            path.move(to: CGPoint(x: 60, y: startY))
            path.addCurve(
                to: CGPoint(x: 340, y: endY),
                control1: CGPoint(x: 200, y: startY),
                control2: CGPoint(x: 200, y: endY)
            )
        }
        .stroke(connection.color.color, lineWidth: 6)
        .shadow(color: connection.color.color.opacity(0.6), radius: 8)
    }
}
