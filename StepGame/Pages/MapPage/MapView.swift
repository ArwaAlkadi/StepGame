//
//  MapView.swift
//  StepGame
//

import SwiftUI
import UIKit

struct MapView: View {

    @EnvironmentObject private var session: GameSession
    @EnvironmentObject private var health: HealthKitManager

    @StateObject private var vm = MapViewModel()

    @State private var selectedDetent: PresentationDetent = .height(90)

    @State private var showJoinPopup = false
    @State private var reopenChallengesSheetAfterJoinDismiss = false

    @State private var showSetupPage = false

    @State private var showProfile = false
    @State private var reopenChallengesSheetAfterProfileDismiss = false

    // MARK: - Sheet Router
    private enum ActiveSheet: Identifiable {
        case challenges
        case resultSummary

        var id: Int {
            switch self {
            case .challenges: return 1
            case .resultSummary: return 2
            }
        }
    }

    @State private var activeSheet: ActiveSheet? = .challenges

    var body: some View {
        ZStack {
            Color.light2.ignoresSafeArea()

            mapContent

            hudLayer

            resultPopup
        }
        .sheet(item: $activeSheet) { sheet in
            makeSheet(for: sheet)
        }
        .fullScreenCover(isPresented: $showJoinPopup, onDismiss: onJoinDismiss) {
            makeJoinPopup()
        }
        .fullScreenCover(isPresented: $showSetupPage) {
            makeSetupView()
        }
        .fullScreenCover(isPresented: $showProfile, onDismiss: onProfileDismiss) {
            makeProfileView()
        }
        .onAppear {
            selectedDetent = .height(90)
            activeSheet = .challenges
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
        .onChange(of: session.player?.name) { _, _ in
            vm.bind(session: session)
        }
        .onChange(of: session.player?.characterType) { _, _ in
            vm.bind(session: session)
        }
    }

    // MARK: - Subviews

    private var mapContent: some View {
        ScrollView(showsIndicators: false) {
            Image("Map")
                .resizable()
                .scaledToFit()
                .overlay {
                    GeometryReader { geo in
                        mapOverlay(size: geo.size)
                    }
                }
        }
    }

    private func mapOverlay(size: CGSize) -> some View {
        Group {
            ForEach(Array(vm.milestones.enumerated()), id: \.offset) { index, value in
                FlagMarker(
                    number: value,
                    reached: vm.isFlagReached(value)
                )
                .position(
                    vm.flagPosition(index: index, mapSize: size)
                )
            }

            ForEach(vm.mapPlayers) { p in
                MapPlayerMarker(
                    mapSprite: p.mapSprite,
                    name: p.name,
                    steps: p.steps,
                    isMe: p.isMe
                )
                .position(
                    vm.positionForPlayer(p, mapSize: size)
                )
                .animation(.easeInOut(duration: 0.35), value: p.progress)
            }
        }
    }

    private var hudLayer: some View {
        MapHUDLayer(
            title: vm.titleText,
            isGroup: vm.isGroupChallenge,
            avatars: vm.hudAvatars,
            myAvatar: vm.myHudAvatar,
            stepsLeftText: vm.stepsLeftText,
            daysLeftText: vm.daysLeftText,
            startDate: vm.challenge?.startedAt ?? vm.challenge?.startDate,
            endDate: vm.challenge?.effectiveEndDate,
            onTapMyAvatar: {
                reopenChallengesSheetAfterProfileDismiss = true
                selectedDetent = .height(90)
                activeSheet = nil

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    showProfile = true
                }
            }
        )
    }

    @ViewBuilder
    private var resultPopup: some View {
        if vm.isShowingResultPopup, let popupVM = vm.resultPopupVM {
            ChallengeResultPopup(
                isPresented: Binding(
                    get: { vm.isShowingResultPopup },
                    set: { newValue in
                        if !newValue {
                            vm.dismissResultPopup()
                        }
                    }
                ),
                vm: popupVM
            )
            .transition(.opacity)
            .zIndex(1000)
        }
    }

    // MARK: - Sheet Builders

    @ViewBuilder
    private func makeSheet(for sheet: ActiveSheet) -> some View {
        switch sheet {
        case .challenges:
            makeChallengesSheet()
        case .resultSummary:
            makeResultSummarySheet()
        }
    }

    private func makeChallengesSheet() -> some View {
        ChallengesSheet(
            onTapCreate: {
                activeSheet = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    showSetupPage = true
                }
            },
            onTapJoin: {
                reopenChallengesSheetAfterJoinDismiss = true
                activeSheet = nil

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    showJoinPopup = true
                }
            },
            onTapChallenge: { ch in
                session.selectChallenge(ch)

                if session.isChallengeInResultState(ch) {
                    activeSheet = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        activeSheet = .resultSummary
                    }
                }
            }
        )
        .environmentObject(session)
        .presentationDetents([.height(90), .medium, .large], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled(true)
    }

    private func makeResultSummarySheet() -> some View {
        NavigationStack {
            if let challenge = vm.challenge {
                ResultSummaryView(
                    challenge: challenge,
                    participants: vm.participants,
                    playersById: vm.playersById
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") {
                            selectedDetent = .height(90)
                            activeSheet = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                activeSheet = .challenges
                            }
                        }
                        .font(.custom("RussoOne-Regular", size: 16))
                        .foregroundStyle(.light1)
                    }
                }
            } else {
                Text("No challenge selected")
                    .foregroundStyle(.light1)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled(true)
    }

    private func makeJoinPopup() -> some View {
        JoinCodePopup(
            isPresented: $showJoinPopup,
            onJoin: { code in
                await session.joinWithCode(code)

                if let msg = session.errorMessage, !msg.isEmpty {
                    return msg
                }

                reopenChallengesSheetAfterJoinDismiss = false
                return nil
            }
        )
    }

    private func makeSetupView() -> some View {
        SetupChallengeView(
            isPresented: $showSetupPage,
            onDismissWithoutCreating: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    selectedDetent = .height(90)
                    activeSheet = .challenges
                }
            }
        )
        .environmentObject(session)
    }

    private func makeProfileView() -> some View {
        NavigationStack {
            ProfileView()
                .environmentObject(session)
        }
    }

    // MARK: - Handlers

    private func onJoinDismiss() {
        if reopenChallengesSheetAfterJoinDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                selectedDetent = .height(90)
                activeSheet = .challenges
            }
        }
        reopenChallengesSheetAfterJoinDismiss = false
    }

    private func onProfileDismiss() {
        selectedDetent = .height(90)

        if reopenChallengesSheetAfterProfileDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                activeSheet = .challenges
            }
        }
        reopenChallengesSheetAfterProfileDismiss = false
    }
}

// MARK: - HUD Layer

private struct MapHUDLayer: View {
    var title: String
    var isGroup: Bool
    var avatars: [String]
    var myAvatar: String
    var stepsLeftText: String
    var daysLeftText: String

    var startDate: Date?
    var endDate: Date?

    var onTapMyAvatar: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            Rectangle()
                .frame(height: 140)
                .cornerRadius(20)
                .foregroundStyle(Color.light1.opacity(0.3))
                .overlay(
                    VStack(alignment: .leading, spacing: 6) {
                        MapTopHUD(
                            title: title,
                            isGroup: isGroup,
                            avatars: avatars,
                            myAvatar: myAvatar,
                            onTapMyAvatar: onTapMyAvatar
                        )

                        if let start = startDate, let end = endDate {
                            Text("\(formatted(start)) - \(formatted(end))")
                                .font(.custom("RussoOne-Regular", size: 14))
                                .foregroundStyle(.white.opacity(0.85))
                                .padding()
                        }
                    }
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

    // \\ Date formatting for HUD
    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Player Marker (On Map)

private struct MapPlayerMarker: View {
    let mapSprite: String
    let name: String
    let steps: Int
    let isMe: Bool

    var body: some View {
        VStack(spacing: 6) {

            Image(systemName: "bubble.middle.bottom.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 90)
                .foregroundStyle(.white)
                .overlay(
                    VStack(spacing: 2) {
                        Text(isMe ? "Me" : name)
                            .font(.custom("RussoOne-Regular", size: 14))
                            .foregroundStyle(.light1)

                        Text("\(steps.formatted())")
                            .font(.custom("RussoOne-Regular", size: 12))
                            .foregroundStyle(.light2)
                    }
                )

            Image(mapSprite)
                .resizable()
                .scaledToFit()
                .frame(width: isMe ? 120 : 90, height: isMe ? 120 : 90)
        }
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

// MARK: - HUD Components

struct MapTopHUD: View {
    var title: String
    var isGroup: Bool
    var avatars: [String]
    var myAvatar: String

    var onTapMyAvatar: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.custom("RussoOne-Regular", size: 28))
                    .foregroundStyle(.white)

                if isGroup {
                    HStack(spacing: -10) {
                        ForEach(Array(avatars.prefix(6).enumerated()), id: \.offset) { _, a in
                            PlayerAvatar(imageName: a)
                        }
                    }
                }
            }

            Spacer()

            ProfileAvatarButton(
                imageName: myAvatar,
                size: 54,
                onTap: onTapMyAvatar
            )
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

struct ProfileAvatarButton: View {
    var imageName: String
    var size: CGFloat = 54
    var onTap: () -> Void

    var body: some View {
        Button { onTap() } label: {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .background(Circle().fill(Color.light4))
                .overlay(Circle().stroke(Color.light2, lineWidth: 3))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
