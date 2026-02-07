//
//  WaitingView.swift
//  StepGame
//
//  Created by Arwa Alkadi on 30/01/2026.
//

import SwiftUI
import Combine

struct WaitingRoomView: View {

    @EnvironmentObject private var session: GameSession
    @StateObject private var vm = WaitingRoomViewModel()

    var body: some View {
        ZStack {
            Color.light3.ignoresSafeArea()

            VStack(spacing: 18) {

                // Title
                Text(vm.titleText)
                    .font(.custom("RussoOne-Regular", size: 34))
                    .foregroundStyle(Color.light1)
                    .padding(.top, 10)

                // Steps pill
                StepsPill(text: vm.goalStepsText)

                // Join code + copy
                JoinCodePill(code: vm.joinCodeText) {
                    vm.copyJoinCode()
                }

                Spacer(minLength: 10)

                // Center lobby
                LobbyCenter(players: vm.lobbyPlayers)

                Spacer()

                // Bottom area
                if vm.isHost {
                    Button {
                        Task { await vm.startChallenge() }
                    } label: {
                        Text(vm.isStarting ? "Starting..." : "Start!")
                            .font(.custom("RussoOne-Regular", size: 18))
                            .foregroundStyle(Color.light3)
                            .frame(width: 220, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.light1)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(vm.isStarting || !vm.canStart)
                    .opacity((vm.isStarting || !vm.canStart) ? 0.6 : 1)
                    .padding(.bottom, 18)

                } else {
                    Text(vm.footerTextForPlayer)
                        .font(.custom("RussoOne-Regular", size: 18))
                        .foregroundStyle(Color.light1)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 22)
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            vm.bind(session: session)
        }
        .onDisappear {
            vm.unbind()
        }
    }
}

// MARK: - UI Parts

private struct StepsPill: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.custom("RussoOne-Regular", size: 14))
                .foregroundStyle(.white)

            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.light2))
    }
}

private struct JoinCodePill: View {
    let code: String
    let onCopy: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(code)
                .font(.custom("RussoOne-Regular", size: 18))
                .foregroundStyle(Color.light1)

            Button(action: onCopy) {
                Image(systemName: "doc.on.doc.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.light1)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 180, height: 44)
        .background(Capsule().fill(Color.white.opacity(0.85)))
    }
}

private struct LobbyCenter: View {
    let players: [LobbyPlayer]

    var body: some View {
        ZStack {

            Image("Tent")
                .resizable()
                .scaledToFit()
                .frame(width: 210, height: 210)
                .opacity(0.55)

            let slots = slotPositions()

            ForEach(0..<min(players.count, 4), id: \.self) { i in
                let p = players[i]
                LobbyAvatar(
                    image: p.avatarAsset,
                    name: p.name + (p.isMe ? " (Me)" : "")
                )
                .position(slots[i])
            }
        }
        .frame(height: 360)
    }

    private func slotPositions() -> [CGPoint] {
        [
            CGPoint(x: 90,  y: 120),
            CGPoint(x: 270, y: 120),
            CGPoint(x: 90,  y: 280),
            CGPoint(x: 270, y: 280)
        ]
    }
}

private struct LobbyAvatar: View {
    let image: String
    let name: String

    var body: some View {
        VStack(spacing: 10) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .padding(16)
                .background(Circle().fill(Color.light4.opacity(0.7)))

            Text(name)
                .font(.custom("RussoOne-Regular", size: 18))
                .foregroundStyle(Color.light1)
        }
    }
}
