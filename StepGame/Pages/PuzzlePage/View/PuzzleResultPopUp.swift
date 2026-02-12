//
//  PuzzleResultPopUp.swift
//  StepGame
//

import SwiftUI

// MARK: - Puzzle Result Sheet
struct PuzzleResultSheet: View {
    let result: PuzzleResult
    let onClose: () -> Void

    @EnvironmentObject private var session: GameSession

    var body: some View {
        ZStack {
            card
                .padding(.horizontal, 26)
        }
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 16) {
            headerRow

           

            VStack(spacing: 10) {
                Text(result.title)
                    .font(.custom("RussoOne-Regular", size: 28))
                    .foregroundStyle(.light1)
                    .multilineTextAlignment(.center)

                characterPreview
                    .padding()
                
                Text(result.message)
                    .font(.custom("RussoOne-Regular", size: 14))
                    .foregroundStyle(.light1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)

                if let opp = result.opponentTime, result.context == .groupDefense {
                    VStack(spacing: 6) {
                        Text("Your time: \(fmt(result.myTime))")
                        Text("Opponent time: \(fmt(opp))")
                    }
                    .font(.custom("RussoOne-Regular", size: 14))
                    .foregroundStyle(.light1)
                    .padding(.top, 6)
                }
            }
            .padding(.bottom, 6)
        }
        .padding(18)
        .frame(maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.light3)
               
        )
    }

    private var headerRow: some View {
        HStack {
            Spacer()

            Button { onClose() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.light1)
                   
                   
            }
            .buttonStyle(.plain)
        }
    }

    private var characterPreview: some View {
        Image(characterImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .padding(.top, 2)
            .accessibilityLabel("Character")
    }

    
    // MARK: - Character Image

    private var characterImageName: String {
        let type = session.player?.characterType ?? .character1

        // base = "character1" / "character2" / "character3"
        let base = type.rawValue

        // suffix = "win" or "lose"
        let suffix = result.success ? "win" : "lose"

        return "\(base)_\(suffix)"
    }

    // MARK: - Helpers

    private func fmt(_ t: Double) -> String {
        String(format: "%.2fs", t)
    }
}


// MARK: - Preview

#Preview("PuzzleResultSheet") {
    // Dummy session for preview
    let session = GameSession()
    return PuzzleResultSheet(
        result: PuzzleResult(
            context: .solo,
            success: true,
            myTime: 1.23,
            opponentTime: nil,
            reason: .solved,
            title: "Awesome!",
            message: "You solved the puzzle"
        ),
        onClose: {}
    )
    .environmentObject(session)
}
