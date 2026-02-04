// MARK: - Main View

import SwiftUI
internal import UniformTypeIdentifiers

// MARK: - Main View
struct FixWiringGameView: View {
    @StateObject private var viewModel: WiringGameViewModel
    @Environment(\.dismiss) var dismiss
    let gameMode: GameMode
    let playerRole: PlayerRole?
    
    init(gameMode: GameMode, playerRole: PlayerRole? = nil, timeLimit: Double = 8.0) {
        self.gameMode = gameMode
        self.playerRole = playerRole
        self._viewModel = StateObject(wrappedValue: WiringGameViewModel(timeLimit: timeLimit))
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.15),
                        Color(red: 0.15, green: 0.15, blue: 0.2),
                        Color(red: 0.1, green: 0.1, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with Timer
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 8) {
                            Text("Fix Wiring")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            // Timer
                            HStack(spacing: 8) {
                                Image(systemName: "timer")
                                    .foregroundColor(viewModel.timeRemaining <= 3 ? .red : .white)
                                Text(String(format: "%.1f", max(0, viewModel.timeRemaining)))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(viewModel.timeRemaining <= 3 ? .red : .white)
                                    .monospacedDigit()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Game Board
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.2, green: 0.2, blue: 0.25))
                        .shadow(radius: 20)
                    
                    GeometryReader { geometry in
                        let wireSpacing: CGFloat = 70
                        let startY: CGFloat = 60
                        let leftPositions = (0..<viewModel.leftWires.count).map { CGFloat($0) * wireSpacing + startY }
                        let rightPositions = (0..<viewModel.rightWires.count).map { CGFloat($0) * wireSpacing + startY }
                        
                        // Wire Connections
                        ForEach(viewModel.connections) { connection in
                            WireConnectionView(
                                connection: connection,
                                leftPositions: leftPositions,
                                rightPositions: rightPositions
                            )
                        }
                        
                        // Left Side Wires
                        VStack(spacing: 20) {
                            ForEach(Array(viewModel.leftWires.enumerated()), id: \.element.id) { index, wire in
                                WireNodeView(
                                    color: wire,
                                    isSelected: viewModel.selectedLeft == index,
                                    isDragging: viewModel.draggedLeftIndex == index,
                                    isHovered: viewModel.hoveredLeftIndex == index
                                )
                                .onTapGesture {
                                    viewModel.handleLeftTap(index: index)
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { _ in
                                            viewModel.startDraggingLeft(index: index)
                                        }
                                        .onEnded { value in
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
                                )
                            }
                        }
                        .padding(.leading, 30)
                        .padding(.top, 30)
                        
                        // Right Side Wires
                        VStack(spacing: 20) {
                            ForEach(Array(viewModel.rightWires.enumerated()), id: \.element.id) { index, wire in
                                WireNodeView(
                                    color: wire,
                                    isSelected: viewModel.selectedRight == index,
                                    isDragging: viewModel.draggedRightIndex == index,
                                    isHovered: viewModel.hoveredRightIndex == index
                                )
                                .onTapGesture {
                                    viewModel.handleRightTap(index: index)
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { _ in
                                            viewModel.startDraggingRight(index: index)
                                        }
                                        .onEnded { value in
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
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 30)
                        .padding(.top, 30)
                    }
                    
                    // Completion Overlay
                    if viewModel.isComplete {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.9))
                        
                        VStack(spacing: 20) {
                            Text("✓")
                                .font(.system(size: 80))
                                .foregroundColor(.green)
                            
                            Text(getSuccessMessage())
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Close")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 15)
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Failure Overlay
                    if viewModel.hasFailed {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.9))
                        
                        VStack(spacing: 20) {
                            Text("✕")
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                            
                            Text("Time's Up!")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.red)
                            
                            Text(getFailureMessage())
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    viewModel.resetGame()
                                }) {
                                    Text("Try Again")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 15)
                                        .background(Color.orange)
                                        .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    dismiss()
                                }) {
                                    Text("Close")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 15)
                                        .background(Color.gray)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .frame(height: 520)
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
    
    private func getSuccessMessage() -> String {
        switch gameMode {
        case .solo:
            return "Puzzle Complete!"
        case .group:
            if playerRole == .attacker {
                return "Attack Successful!"
            } else {
                return "Defense Successful!"
            }
        }
    }
    
    private func getFailureMessage() -> String {
        switch gameMode {
        case .solo:
            return "You failed to complete the wiring"
        case .group:
            if playerRole == .attacker {
                return "Failed to attack the character"
            } else {
                return "Failed to defend the character"
            }
        }
    }
}

// MARK: - Mode Selection View
struct ModeSelectionView: View {
    @Binding var selectedMode: GameMode?
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    // Close button action (can be customized)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(red: 0.63, green: 0.32, blue: 0.18))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 15)
            .padding(.trailing, 15)
            
            // Content
            VStack(spacing: 20) {
                Text("Select Mode")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                
                Text("Choose how you want to play this puzzle challenge.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                // Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        selectedMode = .solo
                    }) {
                        Text("Solo")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(red: 0.29, green: 0.15, blue: 0.07))
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        selectedMode = .group
                    }) {
                        Text("Group")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.29, green: 0.15, blue: 0.07))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color(red: 0.91, green: 0.79, blue: 0.64))
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)
            }
            .padding(.bottom, 40)
        }
        .frame(width: 350)
        .background(Color(red: 0.96, green: 0.87, blue: 0.70))
        .cornerRadius(30)
        .shadow(radius: 20)
    }
}

// MARK: - Solo Challenge Dialog
struct SoloChallengeDialogView: View {
    @Binding var showWiringGame: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    // Close button action
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(red: 0.63, green: 0.32, blue: 0.18))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 15)
            .padding(.trailing, 15)
            
            // Content
            VStack(spacing: 20) {
                Text("Take Your Chance")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                
                Text("Solve this puzzle to prove your skills!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                // Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        showWiringGame = true
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
                        // No button action
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
            .padding(.bottom, 40)
        }
        .frame(width: 350)
        .background(Color(red: 0.96, green: 0.87, blue: 0.70))
        .cornerRadius(30)
        .shadow(radius: 20)
    }
}

// MARK: - Group Attacker Dialog
struct GroupAttackerDialogView: View {
    @Binding var showWiringGame: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    // Close button action
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(red: 0.63, green: 0.32, blue: 0.18))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 15)
            .padding(.trailing, 15)
            
            // Content
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
                
                // Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        showWiringGame = true
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
                        // No button action
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
            .padding(.bottom, 40)
        }
        .frame(width: 350)
        .background(Color(red: 0.96, green: 0.87, blue: 0.70))
        .cornerRadius(30)
        .shadow(radius: 20)
    }
}

// MARK: - Group Defender Dialog
struct GroupDefenderDialogView: View {
    @Binding var showWiringGame: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    // Close button action
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(red: 0.63, green: 0.32, blue: 0.18))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 15)
            .padding(.trailing, 15)
            
            // Content
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
                
                // Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        showWiringGame = true
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
                        // No button action
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
            .padding(.bottom, 40)
        }
        .frame(width: 350)
        .background(Color(red: 0.96, green: 0.87, blue: 0.70))
        .cornerRadius(30)
        .shadow(radius: 20)
    }
}

// MARK: - Main Coordinator View
struct ShowWiringGameSheet: View {
    @State private var selectedMode: GameMode? = nil
    @State private var showAttackerChallenge = false
    @State private var showDefenderChallenge = false
    @State private var showSoloChallenge = false
    @State private var showAttackerGame = false
    @State private var showDefenderGame = false
    @State private var showSoloGame = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.91, green: 0.91, blue: 0.91),
                        Color(red: 0.82, green: 0.82, blue: 0.82)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Mode Selection
            if selectedMode == nil {
                ModeSelectionView(selectedMode: $selectedMode)
            }
            
            // Solo Flow
            if selectedMode == .solo && !showSoloChallenge {
                SoloChallengeDialogView(showWiringGame: $showSoloChallenge)
            }
            
            // Group Flow - Attacker
            if selectedMode == .group && !showAttackerChallenge && !showDefenderChallenge {
                GroupAttackerDialogView(showWiringGame: $showAttackerChallenge)
            }
            
            // Group Flow - Defender (shown after attacker completes)
            if showDefenderChallenge && !showDefenderGame {
                GroupDefenderDialogView(showWiringGame: $showDefenderGame)
            }
        }
        .fullScreenCover(isPresented: $showSoloChallenge) {
            FixWiringGameView(gameMode: .solo, playerRole: nil, timeLimit: 8.0)
        }
        .fullScreenCover(isPresented: $showAttackerChallenge) {
            FixWiringGameView(gameMode: .group, playerRole: .attacker, timeLimit: 8.0)
                .onDisappear {
                    // When attacker finishes, show defender challenge
                    showDefenderChallenge = true
                }
        }
        .fullScreenCover(isPresented: $showDefenderGame) {
            // Defender gets less time (6 seconds instead of 8)
            FixWiringGameView(gameMode: .group, playerRole: .defender, timeLimit: 6.0)
        }
    }
}

// MARK: - Preview
struct FixWiringGameView_Previews: PreviewProvider {
    static var previews: some View {
        ShowWiringGameSheet()
    }
}
