//
//  ChallengesSheet.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import SwiftUI
import Combine

struct ChallengesSheet: View {

    @EnvironmentObject private var session: GameSession

    @State private var showJoinPopup = false
    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            
            ZStack {
                
                Color.light3.ignoresSafeArea(edges: .all)
                
                VStack(spacing: 16) {
                    
                    header
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            
                            let activeChallenges = session.activeChallenges
                            
                            if !activeChallenges.isEmpty {
                                ForEach(activeChallenges) { ch in
                                    Button {
                                        session.selectChallenge(ch)   // ✅ بدل session.challenge = ch
                                    } label: {
                                        ChallengesCard(
                                            challenge: ch,
                                            badgeText: badgeForChallenge(ch),
                                            showMenu: true
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            } else {
                                emptyState
                                    .padding(.top, 40)
                            }
                            
                            let endedChallenges = session.endedChallenges
                            
                            if !endedChallenges.isEmpty {
                                Text("Ended")
                                    .font(.custom("RussoOne-Regular", size: 20))
                                    .foregroundStyle(.light1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top)
                                
                                Divider()
                                
                                ForEach(endedChallenges) { ch in
                                    ChallengesCard(
                                        challenge: ch,
                                        badgeText: badgeForChallenge(ch),
                                        showMenu: false
                                    )
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                .padding()
            }
        }
        .overlay {
            if showJoinPopup {
                JoinCodePopup(
                    isPresented: $showJoinPopup,
                    isLoading: session.isLoading,
                    onJoin: { code in
                        Task { await session.joinWithCode(code) }
                    }
                )
            }
        }
        .sheet(isPresented: $showCreate) {
            SetupChallengeView(isPresented: $showCreate)
                .environmentObject(session)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Challenges")
                .font(.custom("RussoOne-Regular", size: 35))
                .bold()
                .foregroundStyle(.light1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Menu {
                Button {
                    showCreate = true
                } label: {
                    Text("Add a New Challenge")
                }

                Button {
                    showJoinPopup = true
                } label: {
                    Text("Join With Code")
                }

            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.light1)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "flag.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No active challenges")
                .font(.custom("RussoOne-Regular", size: 16))
                .foregroundColor(.gray)
        }
    }

    // MARK: - Badge

    private func badgeForChallenge(_ ch: Challenge) -> String? {
        if ch.originalMode == .solo { return "Solo" }
        if ch.status == .waiting { return "Waiting" }
        if ch.status == .active { return "Active" }
        return nil
    }
}

// MARK: - Card

struct ChallengesCard: View {

    let challenge: Challenge
    var badgeText: String? = nil
    var showMenu: Bool = true

    var body: some View {
        HStack {

            VStack(alignment: .leading, spacing: 10) {

                HStack(spacing: 8) {
                    Text(challenge.name)
                        .font(.custom("RussoOne-Regular", size: 20))
                        .foregroundStyle(.light1)

                    if let badgeText {
                        Text(badgeText)
                            .font(.custom("RussoOne-Regular", size: 12))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.light2))
                    }
                }

                HStack(spacing: 10) {

                    HStack(spacing: 4) {
                        Image("Target")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .padding(.horizontal, 3)

                        Text("\(challenge.goalSteps.formatted())")
                            .font(.custom("RussoOne-Regular", size: 14))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.light2))

                    Text(statusTitle(challenge.status))
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(statusColor(challenge.status)))

                    Spacer()
                }
            }
            .padding()

            VStack {

                if showMenu {
                    Menu {
                        Button(role: .destructive) {
                            // Later: Delete action
                        } label: {
                            Text("Delete")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .bold()
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(.light1)
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("\(challenge.playerIds.count)")
                        .font(.custom("RussoOne-Regular", size: 14))
                    Image(systemName: "person.2.fill")
                }
                .foregroundStyle(.light1)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .frame(height: 110)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.light4)
        )
        .contentShape(RoundedRectangle(cornerRadius: 22))
    }

    // MARK: - Status UI

    private func statusTitle(_ s: ChallengeStatus) -> String {
        switch s {
        case .waiting: return "Waiting"
        case .active:  return "Active"
        case .ended:   return "Ended"
        }
    }

    private func statusColor(_ s: ChallengeStatus) -> Color {
        switch s {
        case .waiting: return .orange
        case .active:  return .green
        case .ended:   return .red
        }
    }
}
