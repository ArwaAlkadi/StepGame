//
//  MapView.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import SwiftUI
import UIKit

struct MapView: View {

    @EnvironmentObject private var session: GameSession
    @EnvironmentObject private var health: HealthKitManager

    @StateObject private var vm = MapViewModel()

    // ✅ Sheet for Challenges
    @State private var showChallengesSheet = true
    @State private var selectedDetent: PresentationDetent = .height(120)
    
    var body: some View {
        ZStack {
            Color.light2.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                Image("Map")
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        GeometryReader { geo in
                            let size = geo.size

                            // Flags
                            ForEach(Array(vm.milestones.enumerated()), id: \.offset) { index, value in
                                FlagMarker(number: value, reached: vm.isFlagReached(value))
                                    .position(vm.flagPosition(index: index, mapSize: size))
                            }

                            // Player
                            PlayerWithBubble(
                                imageName: vm.characterImageName,
                                name: vm.playerName,
                                steps: vm.playerSteps
                            )
                            .position(vm.playerPosition(mapSize: size))
                            .animation(.easeInOut(duration: 0.35), value: vm.progress)
                        }
                    }
            }

            // HUD
            MapHUDLayer(
                title: vm.titleText,
                stepsLeftText: vm.stepsLeftText,
                daysLeftText: vm.daysLeftText
            )
        }
        // ✅ Present ChallengesSheet
        .sheet(isPresented: $showChallengesSheet) {
            ChallengesSheet()
                .environmentObject(session)
                .presentationDetents(
                    [.height(90), .medium, .large],
                    selection: $selectedDetent
                )
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled(true)
        }
        .onAppear {
            vm.bind(session: session)
            vm.startStepsSync(health: health)
        }
        .onDisappear {
            vm.stopStepsSync()
            vm.unbind()
        }
        .onChange(of: session.challenge?.id) { _, _ in
            vm.bind(session: session)
        }
    }
}

// MARK: - HUD Layer

private struct MapHUDLayer: View {
    var title: String
    var stepsLeftText: String
    var daysLeftText: String

    var body: some View {
        VStack(spacing: 0) {

            Rectangle()
                .frame(height: 170)
                .cornerRadius(20)
                .foregroundStyle(Color.light1.opacity(0.4))
                .overlay(
                    MapTopHUD(title: title)
                        .padding(.horizontal, 18)
                        .padding(.top, 50)
                )

            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    InfoPill(icon: "shoeprints.fill", text: stepsLeftText)
                    InfoPill(icon: "hourglass", text: daysLeftText)
                }
                Spacer()
            }
            .padding()

            Spacer()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Flag Marker

struct FlagMarker: View {
    let number: Int
    let reached: Bool

    var body: some View {
        ZStack {
            Image(reached ? "Flag1" : "Flag2")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)

            Text("\(number)")
                .font(.custom("RussoOne-Regular", size: 12))
                .foregroundStyle(.light1)
                .padding(.bottom, 18)
                .padding(.trailing, 8)
        }
    }
}

// MARK: - Player + Bubble

struct PlayerWithBubble: View {
    let imageName: String
    let name: String
    let steps: Int

    var body: some View {
        VStack(spacing: 0) {

            Image(systemName: "bubble.middle.bottom.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 90)
                .foregroundStyle(.white)
                .overlay(
                    VStack(spacing: 2) {
                        Text(name)
                            .font(.custom("RussoOne-Regular", size: 14))
                            .foregroundStyle(.light1)

                        Text("\(steps.formatted())")
                            .font(.custom("RussoOne-Regular", size: 12))
                            .foregroundStyle(.light2)
                    }
                )

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
    }
}

// MARK: - HUD Components

struct MapTopHUD: View {
    var title: String

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.custom("RussoOne-Regular", size: 28))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    PlayerAvatar(imageName: "character1_normal")
                    PlayerAvatar(imageName: "character2_normal")
                }
            }

            Spacer()

            PlayerAvatar(imageName: "character1_normal", size: 50)
        }
    }
}

struct PlayerAvatar: View {
    var imageName: String
    var size: CGFloat = 44

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .padding(6)
            .background(Circle().fill(Color.light4))
            .overlay(Circle().stroke(Color.light2, lineWidth: 3))
    }
}

struct InfoPill: View {
    var icon: String
    var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.light1)

            Text(text)
                .font(.custom("RussoOne-Regular", size: 14))
                .foregroundStyle(Color.light1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.light4))
    }
}
