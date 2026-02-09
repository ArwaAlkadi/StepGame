//
//  ChallengeResultSheet.swift
//  StepGame
//
//

import SwiftUI

// MARK: - Result Summary View
struct ResultSummaryView: View {

    let challenge: Challenge
    let participants: [ChallengeParticipant]
    let playersById: [String: Player]

    var body: some View {
        ZStack {
            Color.light3.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {

                Text("Results")
                    .font(.custom("RussoOne-Regular", size: 34))
                    .foregroundStyle(.light1)

                Text(challenge.name)
                    .font(.custom("RussoOne-Regular", size: 18))
                    .foregroundStyle(.light1.opacity(0.85))

                resultsList
                    .padding(.top, 6)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Results List
    private var resultsList: some View {
        let winnerId = challenge.winnerId

        let finishers = participants
            .filter { $0.finishedAt != nil }
            .sorted { a, b in
                let ap = a.place ?? ((winnerId != nil && a.playerId == winnerId) ? 1 : Int.max)
                let bp = b.place ?? ((winnerId != nil && b.playerId == winnerId) ? 1 : Int.max)
                if ap != bp { return ap < bp }
                return a.steps > b.steps
            }

        let nonFinishers = participants
            .filter { $0.finishedAt == nil }
            .sorted { $0.steps > $1.steps }

        let sorted = finishers + nonFinishers

        return VStack(spacing: 10) {
            ForEach(sorted, id: \.playerId) { part in
                row(for: part, winnerId: winnerId)
            }
        }
    }

    // MARK: - Row
    private func row(for part: ChallengeParticipant, winnerId: String?) -> some View {
        let player = playersById[part.playerId]
        let name = player?.name ?? shortId(part.playerId)
        let avatar = (player?.characterType ?? .character1).avatarKey()

        let place: Int? = {
            if let p = part.place { return p }
            if let w = winnerId, part.playerId == w { return 1 }
            return nil
        }()

        return HStack(spacing: 12) {
            Image(avatar)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .background(Circle().fill(Color.light2.opacity(0.25)))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if let p = place, (1...3).contains(p) {
                        Image(placeAssetName(p))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }

                    Text(name)
                        .font(.custom("RussoOne-Regular", size: 16))
                        .foregroundStyle(.light1)
                }

                Text("\(part.steps.formatted()) Steps")
                    .font(.custom("RussoOne-Regular", size: 12))
                    .foregroundStyle(.light1.opacity(0.75))
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.light4.opacity(0.9))
        )
    }

    /// Trophy asset for top 3 places
    private func placeAssetName(_ place: Int) -> String {
        switch place {
        case 1: return "Place1"
        case 2: return "Place2"
        case 3: return "Place3"
        default: return "Place1"
        }
    }

    /// Shortens a uid for display
    private func shortId(_ id: String) -> String {
        if id.count <= 6 { return id }
        return "\(id.prefix(3))...\(id.suffix(3))"
    }
}
