//
//  MapView.swift
//  StepGame
//

import SwiftUI
import UIKit
import Combine

struct MapView: View {

    @EnvironmentObject private var session: GameSession
    @EnvironmentObject private var health: HealthKitManager
    @EnvironmentObject private var connectivity: ConnectivityMonitor

    @StateObject private var vm = MapViewModel()

    @State private var selectedDetent: PresentationDetent = .height(90)

    @State private var showJoinPopup = false
    @State private var showSetupPage = false
    @State private var showProfile = false
    @State private var showOfflineBanner = true

    @State private var puzzleResult: PuzzleResult? = nil
    @State private var activeMapPopup: MapPopupType? = nil
    @State private var activePuzzle: PuzzleRequest? = nil

    private enum ActiveSheet: Identifiable {
        case challenges
        var id: Int { 1 }
    }

    @State private var activeSheet: ActiveSheet? = .challenges
    @State private var now = Date()
    private let uiTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var isPresentingCover: Bool {
        showJoinPopup || showSetupPage || showProfile || (activePuzzle != nil)
    }

    var body: some View {
        ZStack {
            Color.light2.ignoresSafeArea()

            mapContent
            hudLayer
            resultPopup
            mapPopupLayer
            puzzleResultOverlay

            if !connectivity.isOnline {
                OfflineBanner(isVisible: $showOfflineBanner)
            }
        }
        .sheet(item: $activeSheet) { _ in
            makeChallengesSheet()
        }
        .fullScreenCover(isPresented: $showJoinPopup, onDismiss: showChallengesSheet) {
            makeJoinPopup()
        }
        .fullScreenCover(isPresented: $showSetupPage, onDismiss: showChallengesSheet) {
            makeSetupView()
        }
        .fullScreenCover(isPresented: $showProfile, onDismiss: showChallengesSheet) {
            makeProfileView()
        }
        .fullScreenCover(item: $activePuzzle, onDismiss: showChallengesSheet) { req in
            PuzzleWiringView(
                timeLimit: 8,
                onCancel: {
                    activePuzzle = nil
                },
                onFinish: { success, time, didTimeout in
                    Task { await handlePuzzleFinish(req: req, success: success, time: time, didTimeout: didTimeout) }
                }
            )
        }
        .onAppear {
            selectedDetent = .height(90)
            showChallengesSheet()
            vm.bind(session: session)
            vm.startStepsSync(health: health)
        }
        .onReceive(uiTimer) { t in
            now = t
        }
        .onDisappear {
            if isPresentingCover { return }
            vm.stopStepsSync()
            vm.unbind()
        }
        .onChange(of: session.challenge?.id) { _, _ in
            vm.bind(session: session)
            vm.startStepsSync(health: health)
        }
        .onChange(of: session.player?.name) { _, _ in
            vm.bind(session: session)
        }
        .onChange(of: session.player?.characterType) { _, _ in
            vm.bind(session: session)
        }
        .onChange(of: vm.pendingMapPopup) { popup in
            activeMapPopup = popup
        }
    }

    // MARK: - Helpers

    private func showChallengesSheet() {
        selectedDetent = .height(90)
        activeSheet = .challenges
    }

    private func dismissSheetAndPopups() {
        activeSheet = nil
        activeMapPopup = nil
    }

    // MARK: - Puzzle

    private func startSoloGameSafely() {
        dismissSheetAndPopups()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            activePuzzle = .soloExtension
        }
    }

    private func startAttackerGameSafely() {
        dismissSheetAndPopups()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            activePuzzle = .groupAttack
        }
    }

    private func startDefenderGameSafely() {
        dismissSheetAndPopups()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            activePuzzle = .groupDefense
        }
    }

    private func handlePuzzleFinish(
        req: PuzzleRequest,
        success: Bool,
        time: Double,
        didTimeout: Bool
    ) async {

        guard let chId = session.challenge?.id else { return }
        guard let myId = session.uid else { return }

        switch req {

        case .soloExtension:
            if success {
                do {
                    try await FirebaseService.shared.addOneDayExtension(challengeId: chId)
                } catch {
                    print("addOneDayExtension failed:", error.localizedDescription)
                }

                puzzleResult = PuzzleResult(
                    context: .solo,
                    success: true,
                    myTime: time,
                    opponentTime: nil,
                    reason: .solved,
                    title: "Awesome!",
                    message: "+1 day extension added!"
                )
            } else {
                do {
                    try await FirebaseService.shared.markSoloPuzzleFailed(challengeId: chId, uid: myId)
                } catch {
                    print("markSoloPuzzleFailed failed:", error.localizedDescription)
                }

                puzzleResult = PuzzleResult(
                    context: .solo,
                    success: false,
                    myTime: time,
                    opponentTime: nil,
                    reason: didTimeout ? .timeOut : .notSolved,
                    title: "Oops!",
                    message: didTimeout ? "Time is up" : "You didn’t solve the wiring"
                )
            }

        case .groupAttack:
            guard let targetId = vm.leadingPlayerId, targetId != myId else {
                puzzleResult = PuzzleResult(
                    context: .groupAttack,
                    success: false,
                    myTime: time,
                    opponentTime: nil,
                    reason: .notSolved,
                    title: "Attack Failed",
                    message: "Couldn’t find a valid target"
                )
                return
            }

            if success {
                do {
                    try await FirebaseService.shared.applyGroupAttack(
                        challengeId: chId,
                        targetId: targetId,
                        attackerId: myId,
                        attackTimeSeconds: time
                    )
                    try await FirebaseService.shared.markGroupAttackSucceeded(challengeId: chId, uid: myId)
                } catch {
                    print("applyGroupAttack failed:", error.localizedDescription)
                }

                puzzleResult = PuzzleResult(
                    context: .groupAttack,
                    success: true,
                    myTime: time,
                    opponentTime: nil,
                    reason: .solved,
                    title: "Attack Succeeded!",
                    message: "You sabotaged your friend for 3 hours"
                )
            } else {
                do {
                    try await FirebaseService.shared.markGroupAttackPuzzleFailed(challengeId: chId, uid: myId)
                } catch {
                    print("markGroupAttackPuzzleFailed failed:", error.localizedDescription)
                }

                puzzleResult = PuzzleResult(
                    context: .groupAttack,
                    success: false,
                    myTime: time,
                    opponentTime: nil,
                    reason: didTimeout ? .timeOut : .notSolved,
                    title: "Oops!",
                    message: didTimeout ? "Time is up.." : "You didn’t solve the wiring.."
                )
            }

        case .groupDefense:
            let oppTime = vm.myParticipant?.sabotageAttackTimeSeconds
            let attackerId = vm.myParticipant?.sabotageByPlayerId

            if attackerId == nil {
                puzzleResult = PuzzleResult(
                    context: .groupDefense,
                    success: success,
                    myTime: time,
                    opponentTime: nil,
                    reason: success ? .solved : (didTimeout ? .timeOut : .notSolved),
                    title: success ? "Defended" : "Defense Failed",
                    message: success ? "No active attack to defend." : (didTimeout ? "Time is up." : "You didn’t solve the wiring..")
                )
                return
            }

            if !success {
                puzzleResult = PuzzleResult(
                    context: .groupDefense,
                    success: false,
                    myTime: time,
                    opponentTime: oppTime,
                    reason: didTimeout ? .timeOut : .notSolved,
                    title: "Defense Failed",
                    message: didTimeout ? "You ran out of time.." : "You didn’t solve the wiring.."
                )
                return
            }

            if let opp = oppTime {
                if time <= opp {
                    do {
                        try await FirebaseService.shared.cancelGroupAttack(challengeId: chId, targetId: myId)
                    } catch {
                        print("cancelGroupAttack failed:", error.localizedDescription)
                    }

                    puzzleResult = PuzzleResult(
                        context: .groupDefense,
                        success: true,
                        myTime: time,
                        opponentTime: opp,
                        reason: .solved,
                        title: "Awesome!",
                        message: "You were faster than the attacker. Sabotage removed!"
                    )
                } else {
                    puzzleResult = PuzzleResult(
                        context: .groupDefense,
                        success: false,
                        myTime: time,
                        opponentTime: opp,
                        reason: .slowerThanOpponent(myTime: time, opponentTime: opp),
                        title: "Oops!",
                        message: "You solved it, but the attacker was faster.."
                    )
                }
            } else {
                do {
                    try await FirebaseService.shared.cancelGroupAttack(challengeId: chId, targetId: myId)
                } catch {
                    print("cancelGroupAttack failed:", error.localizedDescription)
                }

                puzzleResult = PuzzleResult(
                    context: .groupDefense,
                    success: true,
                    myTime: time,
                    opponentTime: nil,
                    reason: .solved,
                    title: "Awesome!",
                    message: "Sabotage removed!"
                )
            }
        }
    }

    // MARK: - Content

    private var mapContent: some View {
        ScrollView(showsIndicators: false) {
            Image("Map")
                .resizable()
                .scaledToFit()
                .overlay {
                    GeometryReader { geo in
                        ZStack {
                            mapOverlay(size: geo.size)
                            WindTumbleweedView(mapSize: geo.size)
                        }
                    }
                }
        }
        .contentMargins(0, for: .scrollContent)
        .ignoresSafeArea()
    }

    private func mapOverlay(size: CGSize) -> some View {
        ZStack {
            ForEach(Array(vm.milestones.enumerated()), id: \.offset) { index, value in
                FlagMarker(number: value, reached: vm.isFlagReached(value))
                    .position(vm.flagPosition(index: index, mapSize: size))
            }

            ForEach(vm.mapPlayers) { p in
                MapPlayerMarker(
                    mapSprite: p.mapSprite,
                    name: p.name,
                    steps: p.steps,
                    isMe: p.isMe,
                    isGroup: vm.isGroupChallenge,
                    place: p.place,
                    attackedByName: p.attackedByName,
                    isUnderSabotage: p.isUnderSabotage,
                    sabotageExpiresAt: p.sabotageExpiresAt
                )
                .position(vm.positionForPlayer(p, mapSize: size))
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
            isChallengeEnded: vm.isChallengeEnded,
            onTapMyAvatar: {
                activeSheet = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    showProfile = true
                }
            }
        )
    }

    // MARK: - Result Popup

    @ViewBuilder
    private var puzzleResultOverlay: some View {
        if let res = puzzleResult {
            PuzzleResultPopup(
                result: res,
                onClose: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        puzzleResult = nil
                    }
                    showChallengesSheet()
                }
            )
            .environmentObject(session)
            .transition(.opacity)
            .zIndex(5000)
        }
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
                            showChallengesSheet()
                        }
                    }
                ),
                vm: popupVM
            )
            .transition(.opacity)
            .zIndex(1000)
        }
    }

    // MARK: - Map Popups

    @ViewBuilder
    private var mapPopupLayer: some View {
        if let popup = activeMapPopup {
            ZStack {
                Color.black.opacity(0.45).ignoresSafeArea()

                switch popup {
                case .soloLate:
                    SoloLatePopupView(
                        onClose: {
                            activeMapPopup = nil
                            showChallengesSheet()
                        },
                        onConfirm: startSoloGameSafely
                    )

                case .groupAttacker:
                    GroupAttackPopupView(
                        onClose: {
                            activeMapPopup = nil
                            showChallengesSheet()
                        },
                        onConfirm: startAttackerGameSafely
                    )

                case .groupDefender:
                    GroupDefensePopupView(
                        onClose: {
                            activeMapPopup = nil
                            showChallengesSheet()
                        },
                        onConfirm: startDefenderGameSafely
                    )
                }
            }
            .zIndex(3000)
        }
    }

    // MARK: - Sheets

    private func makeChallengesSheet() -> some View {
        ChallengesSheet(
            onTapCreate: {
                activeSheet = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    showSetupPage = true
                }
            },
            onTapJoin: {
                activeSheet = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    showJoinPopup = true
                }
            },
            onTapChallenge: { ch in
                session.selectChallenge(ch)
                selectedDetent = .height(90)
                activeSheet = .challenges
            }
        )
        .environmentObject(session)
        .presentationDetents([.height(90), .medium, .large], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled(true)
    }

    private func makeJoinPopup() -> some View {
        JoinCodePopup(
            isPresented: $showJoinPopup,
            onJoin: { code in
                await session.joinWithCode(code)
                if let msg = session.errorMessage, !msg.isEmpty { return msg }
                return nil
            }
        )
    }

    private func makeSetupView() -> some View {
        SetupChallengeView(
            isPresented: $showSetupPage,
            onDismissWithoutCreating: {
                showChallengesSheet()
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
}

// MARK: - HUD Layer

private struct MapHUDLayer: View {
    var title: String
    var isGroup: Bool
    var avatars: [String]
    var myAvatar: String
    var stepsLeftText: String
    var daysLeftText: String
    var isChallengeEnded: Bool
    var onTapMyAvatar: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 155)
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
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 50)
                )

            if !isChallengeEnded {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        InfoPill(icon: "shoeprints.fill", text: stepsLeftText)
                        InfoPill(icon: "hourglass", text: daysLeftText)
                    }
                    Spacer()
                }
                .padding()
            }

            Spacer()
        }
        .ignoresSafeArea()
    }
}

// MARK: - Player Marker

private struct MapPlayerMarker: View {
    let mapSprite: String
    let name: String
    let steps: Int
    let isMe: Bool
    let isGroup: Bool
    let place: Int?
    let attackedByName: String?
    let isUnderSabotage: Bool
    let sabotageExpiresAt: Date?

    @State private var showSabotageInfo = false
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: 6) {

            Image(systemName: "bubble.middle.bottom.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .foregroundStyle(.white)
                .overlay(alignment: .center) {
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Text(isMe ? "Me" : name)
                                .font(.custom("RussoOne-Regular", size: 10))
                                .foregroundStyle(.light1)

                            if isGroup, let place, (1...3).contains(place) {
                                Image(placeAssetName(place))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                            }
                        }

                        Text("\(steps.formatted()) Steps")
                            .font(.custom("RussoOne-Regular", size: 10))
                            .foregroundStyle(.light2)

                        if isUnderSabotage, let expires = sabotageExpiresAt {
                            HStack(spacing: 2) {
                                Text(timeRemainingString(until: expires))
                                    .font(.custom("RussoOne-Regular", size: 8))
                                    .foregroundStyle(.red)

                                Button {
                                    withAnimation(.spring()) { showSabotageInfo.toggle() }
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundStyle(.red)
                                        .font(.system(size: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .multilineTextAlignment(.center)
                    .offset(y: -6)
                }

            Image(mapSprite)
                .resizable()
                .scaledToFit()
                .frame(width: 85, height: 85)
        }
        .overlay(alignment: .top) {
            if showSabotageInfo {
                sabotageTooltip
                    .offset(y: -90)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(999)
            }
        }
        .offset(dragOffset)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: dragOffset)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
        )
        .onChange(of: showSabotageInfo) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation { showSabotageInfo = false }
                }
            }
        }
    }

    private var sabotageTooltip: some View {
        VStack(spacing: 6) {
            if let attackedByName {
                Text("Under Attack")
                    .font(.custom("RussoOne-Regular", size: 14))
                    .foregroundStyle(.light1)

                Text("Attacked by \(attackedByName)")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.light1)

                Text("Your character is in lazy mode for 3 hours.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.light2)
            }
        }
        .font(.custom("RussoOne-Regular", size: 10))
        .padding()
        .frame(width: 220)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }

    private func timeRemainingString(until date: Date) -> String {
        let remaining = Int(date.timeIntervalSince(Date()))
        if remaining <= 0 { return "0m" }
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    private func placeAssetName(_ place: Int) -> String {
        switch place {
        case 1: return "Place1"
        case 2: return "Place2"
        case 3: return "Place3"
        default: return "Place1"
        }
    }
}

// MARK: - Flag Marker

struct FlagMarker: View {
    let number: Int
    let reached: Bool

    var body: some View {
        ZStack {
            Image(reached ? "Flag2" : "Flag1")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            Text("\(number)")
                .font(.custom("RussoOne-Regular", size: 10))
                .foregroundStyle(.light1)
                .strikethrough(reached, color: .light1)
                .padding(.bottom, 25)
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
            .overlay(Circle().stroke(Color.light1, lineWidth: 3))
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
                .overlay(Circle().stroke(Color.light1, lineWidth: 3))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("MapPlayerMarker - Sabotage") {
    ZStack {
        Image("Map")
        MapPlayerMarker(
            mapSprite: "character1_normal",
            name: "Arwa",
            steps: 1234,
            isMe: true,
            isGroup: true,
            place: 2,
            attackedByName: "Noura",
            isUnderSabotage: true,
            sabotageExpiresAt: Date().addingTimeInterval(60 * 180)
        )
        .padding()
    }
}
