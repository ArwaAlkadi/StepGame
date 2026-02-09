import SwiftUI
import Combine
import UIKit

struct RootView: View {

    @EnvironmentObject private var session: GameSession
    @EnvironmentObject private var health: HealthKitManager

    @Environment(\.scenePhase) private var scenePhase

    @State private var didFinishBootstrap = false

    // MARK: - Onboarding (Shown Once)
    @AppStorage("didShowOnboarding") private var didShowOnboarding: Bool = false
    @State private var showOnboardingNow: Bool = false

    // MARK: - Router Identity Key
    /// Forces NavigationStack to rebuild when critical session/health state changes
    private var routerKey: String {
        let id = session.challenge?.id ?? "no_ch"
        let status = session.challenge?.status.rawValue ?? "none"
        let player = session.player?.id ?? "no_player"
        let healthState = health.isAuthorized ? "hk_ok" : "hk_off"
        let onboard = didShowOnboarding ? "ob_done" : "ob_no"
        return "\(player)_\(id)_\(status)_\(healthState)_\(onboard)"
    }

    var body: some View {
        NavigationStack {
            Group {

                // MARK: - Splash (Initial Bootstrap Loading)
                if !didFinishBootstrap {
                    SplashView()
                }

                // MARK: - Onboarding Flow
                else if showOnboardingNow && !didShowOnboarding {
                    OnboardingView(onFinish: {
                        didShowOnboarding = true
                        showOnboardingNow = false
                    })
                }

                // MARK: - Require Player Name
                else if session.player == nil {
                    EnterNameView()
                }

                // MARK: - HealthKit Not Authorized
                else if !health.isAuthorized {
                    StartView()
                }

                // MARK: - No Active or Available Challenges
                else if session.challenge == nil && session.challenges.isEmpty {
                    StartView()
                }

                // MARK: - Challenge Routing
                else {
                    challengeRouter
                }
            }
        }
        .id(routerKey)
        .task {

            // MARK: - App Bootstrap
            if !didFinishBootstrap {
                await session.bootstrap()
                await health.refreshAuthorizationState()

                didFinishBootstrap = true

                if !didShowOnboarding {
                    showOnboardingNow = true
                }
            }
        }

        // MARK: - Refresh Health Authorization On App Active
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task { await health.refreshAuthorizationState() }
        }
    }

    // MARK: - Challenge Router
    @ViewBuilder
    private var challengeRouter: some View {
        if let ch = session.challenge {
            if ch.originalMode == .social && ch.status == .waiting {
                WaitingRoomView()
            } else {
                MapView()
            }
        } else {
            SplashView()
        }
    }
}
