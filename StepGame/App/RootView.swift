import SwiftUI
import Combine

struct RootView: View {

    @EnvironmentObject private var session: GameSession

    var body: some View {
        NavigationStack {
            Group {
                if session.isLoading && session.uid == nil {
                    ProgressView("Loading...")
                } else if session.player == nil {
                    EnterNameView()
                } else if !session.hasAnyChallenges {
                    StartView()
                } else {
                    challengeRouter
                }
            }
        }
        .task {
            await session.bootstrap()
        }
    }

    @ViewBuilder
    private var challengeRouter: some View {

        if let ch = session.challenge {

            if ch.originalMode == .social && ch.status == .waiting {
                WaitingRoomView()
            } else {
                MapView()
            }

        } else {
            ProgressView("Loading...")
        }
    }
}

#Preview {
    RootView()
        .environmentObject(GameSession())
        .environmentObject(HealthKitManager())
}
