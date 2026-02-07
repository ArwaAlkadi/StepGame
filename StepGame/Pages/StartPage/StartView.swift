//
//  StartView.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import SwiftUI
import UIKit
import Combine

struct StartView: View {

    @EnvironmentObject var session: GameSession
    @EnvironmentObject var health: HealthKitManager
    @StateObject private var vm = StartViewModel()

    @State private var showSetup = false   // ✅ NEW

    var body: some View {
        ZStack {

            Image("Map")
                .resizable()
                .scaledToFill()
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height
                )
                .blur(radius: 3)
                .clipped()
                .ignoresSafeArea()

            VStack(spacing: 22) {
                HStack {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color.light3.opacity(0.30))
                            .frame(width: 84, height: 84)

                        Image(vm.avatarImageName(characterType: session.player?.characterType))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                    }
                    .padding(20)
                }

                Spacer()

                VStack(spacing: 10) {
                    Text(vm.greetingText(playerName: session.player?.name))
                        .font(.custom("RussoOne-Regular", size: 36))
                        .foregroundStyle(Color.light1)

                    Text(vm.subtitleText())
                        .font(.custom("RussoOne-Regular", size: 24))
                        .foregroundStyle(Color.light1)
                }
                .multilineTextAlignment(.center)

                Spacer()

                VStack(spacing: 14) {

                    // ✅ Start => يفتح SetupChallenge فقط
                    Button {
                        showSetup = true
                    } label: {
                        BigButtonLabel(title: "Start new challenge")
                    }
                    .disabled(!vm.isInteractionEnabled(isLoading: session.isLoading, isHealthAuthorized: health.isAuthorized))
                    .opacity(vm.isInteractionEnabled(isLoading: session.isLoading, isHealthAuthorized: health.isAuthorized) ? 1 : 0.5)

                    Button {
                        withAnimation(.easeInOut) { vm.showJoinPopup = true }
                    } label: {
                        BigButtonLabel(title: "Join with code")
                    }
                    .disabled(!vm.isInteractionEnabled(isLoading: session.isLoading, isHealthAuthorized: health.isAuthorized))
                    .opacity(vm.isInteractionEnabled(isLoading: session.isLoading, isHealthAuthorized: health.isAuthorized) ? 1 : 0.5)
                }
                .padding(.bottom, 24)

                if let msg = session.errorMessage {
                    Text(msg)
                        .font(.custom("RussoOne-Regular", size: 12))
                        .foregroundStyle(.red)
                        .padding(.bottom, 8)
                }

                if !health.isAuthorized {
                    HealthPermissionGate(
                        onAllow: {
                            health.requestAuthorization()
                        },
                        onOpenSettings: {
                            health.openAppSettings()
                        }
                    )
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                }
            }

            if vm.showJoinPopup {
                JoinCodePopup(
                    isPresented: $vm.showJoinPopup,
                    isLoading: session.isLoading,
                    onJoin: { code in
                        Task { await session.joinWithCode(code) }
                    }
                )
                .transition(.opacity)
            }
        }
        // ✅ SHEET لصفحة Setup
        .sheet(isPresented: $showSetup) {
            SetupChallengeView(isPresented: $showSetup)
                .environmentObject(session)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await health.refreshAuthorizationState()
                if !health.isAuthorized {
                    await health.requestAuthorization()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.willEnterForegroundNotification
        )) { _ in
            Task {
                await health.refreshAuthorizationState()
            }
        }
    }
}
// MARK: - UI Helpers

private struct BigButtonLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.custom("RussoOne-Regular", size: 20))
            .foregroundStyle(Color.light3)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 30).fill(Color.light1)
            )
            .padding(.horizontal, 26)
    }
}

private struct HealthPermissionGate: View {
    let onAllow: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Text("Steps Access Required")
                .font(.custom("RussoOne-Regular", size: 16))
                .foregroundStyle(Color.light1)

            Text("To play, please allow access to your step count.")
                .font(.custom("RussoOne-Regular", size: 12))
                .foregroundStyle(Color.light2)
                .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                Button(action: onAllow) {
                    Text("Allow Steps")
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundStyle(Color.light3)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(RoundedRectangle(cornerRadius: 21).fill(Color.light1))
                }
                .buttonStyle(.plain)

                Button(action: onOpenSettings) {
                    Text("Open Settings")
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundStyle(Color.light1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(RoundedRectangle(cornerRadius: 21).fill(Color.light4))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 22).fill(Color.light3.opacity(0.92)))
    }
}
