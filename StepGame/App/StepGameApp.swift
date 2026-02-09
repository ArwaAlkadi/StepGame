//
//  StepGameApp.swift
//  StepGame
//
//

import SwiftUI
import FirebaseCore

@main
struct StepGameApp: App {

    // MARK: - State Objects
    @StateObject private var session = GameSession()
    @StateObject private var health = HealthKitManager()

    // MARK: - Init
    init() {
        FirebaseApp.configure()
    }

    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(health)
        }
    }
}
