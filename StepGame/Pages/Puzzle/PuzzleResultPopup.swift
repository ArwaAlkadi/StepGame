//
//  PuzzleResultPopup.swift
//  StepGame
//
//

import Foundation
import Foundation

enum PuzzleContext: String, Codable {
    case solo
    case groupAttack
    case groupDefense
}

enum PuzzleEndReason: Equatable {
    case solved
    case timeOut
    case notSolved
    case slowerThanOpponent(myTime: Double, opponentTime: Double)
    case opponentDidNotPlay
}

struct PuzzleResult: Identifiable {
    let id = UUID()

    let context: PuzzleContext
    let success: Bool

    let myTime: Double
    let opponentTime: Double?

    let reason: PuzzleEndReason
    let title: String
    let message: String
}


import SwiftUI

struct PuzzleResultSheet: View {
    let result: PuzzleResult
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 14) {

            Text(result.title)
                .font(.custom("RussoOne-Regular", size: 24))
                .foregroundStyle(.white)

            Text(result.message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)

            if let opp = result.opponentTime, result.context == .groupDefense {
                VStack(spacing: 6) {
                    Text("Your time: \(fmt(result.myTime))")
                    Text("Opponent time: \(fmt(opp))")
                }
                .font(.custom("RussoOne-Regular", size: 14))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.top, 6)
            }

            Button {
                onClose()
            } label: {
                Text("OK")
                    .font(.custom("RussoOne-Regular", size: 18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.blue.opacity(0.85))
                    .cornerRadius(14)
            }
            .padding(.top, 6)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.88))
        )
        .padding(.horizontal, 20)
    }

    private func fmt(_ t: Double) -> String {
        String(format: "%.2fs", t)
    }
}






import SwiftUI
import Combine



