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
    
    @State private var showBackToMe = false
    @State private var scrollOffset: CGFloat = 0
    @State private var myMarkerY: CGFloat = .nan
    
    // MARK: - Single Sheet (Challenges only)
    private enum ActiveSheet: Identifiable {
        case challenges
        var id: Int { 1 }
    }

    @State private var activeSheet: ActiveSheet? = .challenges

    var body: some View {
        ZStack {
            Color.light2.ignoresSafeArea()

            mapContent
            hudLayer
            resultPopup
        }
        .sheet(item: $activeSheet) { _ in
            makeChallengesSheet()
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

    private struct ScrollOffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    private struct MyMarkerYKey: PreferenceKey {
        static var defaultValue: CGFloat = .nan
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
    
    private func updateBackToMe(viewportHeight: CGFloat) {
        guard !myMarkerY.isNaN else {
            showBackToMe = false
            return
        }

        // مكان اللاعب على الشاشة = مكانه داخل الصورة - scrollOffset
        let yOnScreen = myMarkerY - scrollOffset

        let margin: CGFloat = 80 // متى نعتبره "بعيد"
        let isOffscreen = (yOnScreen < -margin) || (yOnScreen > viewportHeight + margin)

        withAnimation(.easeInOut(duration: 0.2)) {
            showBackToMe = isOffscreen
        }
    }
    
    private var mapContent: some View {
        GeometryReader { viewport in
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {

                    // ✅ نقرأ Scroll Offset من أعلى المحتوى
                    Color.clear
                        .frame(height: 0)
                        .background(
                            GeometryReader { g in
                                Color.clear.preference(
                                    key: ScrollOffsetKey.self,
                                    value: -g.frame(in: .named("MAP_SCROLL")).minY
                                )
                            }
                        )

                    Image("Map")
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            GeometryReader { geo in
                                ZStack {
                                    mapOverlay(size: geo.size)

                                    // ✅ نقطة مخفية عند "Me" نستخدمها للـ scrollTo + قياس Y
                                    if let me = vm.mapPlayers.first(where: { $0.isMe }) {
                                        let mePos = vm.positionForPlayer(me, mapSize: geo.size)

                                        Color.clear
                                            .frame(width: 1, height: 1)
                                            .position(mePos)
                                            .id("ME_ANCHOR")
                                            .preference(key: MyMarkerYKey.self, value: mePos.y)
                                    }

                                    // ✅ الرياح (اختياري) إذا تبيها هنا
                                    WindTumbleweedView(mapSize: geo.size)
                                }
                            }
                        }
                }
                .coordinateSpace(name: "MAP_SCROLL")
                .overlay(alignment: .bottomTrailing) {
                    if showBackToMe {
                        Button {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                proxy.scrollTo("ME_ANCHOR", anchor: .center)
                            }
                        } label: {
                            Text("Back to Me")
                                .font(.custom("RussoOne-Regular", size: 16))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color.light4.opacity(0.95)))
                                .foregroundStyle(Color.light1)
                                .overlay(Capsule().stroke(Color.light1, lineWidth: 2))
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 18)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .onPreferenceChange(ScrollOffsetKey.self) { v in
                    scrollOffset = v
                    updateBackToMe(viewportHeight: viewport.size.height)
                }
                .onPreferenceChange(MyMarkerYKey.self) { v in
                    myMarkerY = v
                    updateBackToMe(viewportHeight: viewport.size.height)
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
                .position(vm.flagPosition(index: index, mapSize: size))
            }

            ForEach(vm.mapPlayers) { p in
                MapPlayerMarker(
                    mapSprite: p.mapSprite,
                    name: p.name,
                    steps: p.steps,
                    isMe: p.isMe
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
                        if !newValue { vm.dismissResultPopup() }
                    }
                ),
                vm: popupVM
            )
            .transition(.opacity)
            .zIndex(1000)
        }
    }

    // MARK: - Challenges Sheet

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

    // MARK: - Other Views

    private func makeJoinPopup() -> some View {
        JoinCodePopup(
            isPresented: $showJoinPopup,
            onJoin: { code in
                await session.joinWithCode(code)
                if let msg = session.errorMessage, !msg.isEmpty { return msg }
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
                .frame(width: 70)
                .foregroundStyle(.white)
                .overlay(alignment: .center) {
                    VStack(spacing: 2) {
                        Text(isMe ? "Me" : name)
                            .font(.custom("RussoOne-Regular", size: 10))
                            .foregroundStyle(.light1)

                        Text("\(steps.formatted()) Steps")
                            .font(.custom("RussoOne-Regular", size: 10))
                            .foregroundStyle(.light2)
                    }
                    .multilineTextAlignment(.center)
                    .offset(y: -6)
                }
           

            Image(mapSprite)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
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
                .padding(.bottom, 30)
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
