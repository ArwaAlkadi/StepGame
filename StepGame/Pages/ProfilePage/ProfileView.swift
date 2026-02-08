//
//  ProfileView.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//


import SwiftUI

struct ProfileView: View {
    @StateObject var vm: ProfileViewModel
    @State private var isEditing = false
    @State private var draftName = ""
    @State private var selectedAvatarIndex = 1

    private let avatars = ["character1", "character2", "character3"]

    var body: some View {
        ZStack {
            Color("Light3").ignoresSafeArea()

            VStack(spacing: 14) {
                topBar

                if isEditing {
                    editContent
                } else {
                    profileHeader
                    segmentedTabs
                    tabContent
                    Spacer(minLength: 10)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
        }
    }
}

extension ProfileView {

    private var topBar: some View {
        HStack {
            Button {
                if isEditing {
                    vm.userName = draftName
                    vm.avatarImageName = avatars[selectedAvatarIndex]
                    isEditing = false
                } else {
                    vm.didTapDone()
                }
            } label: {
                Text(isEditing ? "Done" : "Save")
                    .font(.custom("RussoOne-Regular", size: 15))
                    .foregroundColor(Color("Light1"))
            }

            Spacer()

            HStack {
                ZStack(alignment: .leading) {

                    Capsule()
                        .fill(Color("Light6"))

                    Capsule()
                        .fill(Color("Light1"))
                        .frame(width: 44)

                    HStack(spacing: 0) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 32)

                        Image(systemName: "moon.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("Light1"))
                            .frame(width: 44, height: 32)
                    }
                }
                .frame(width: 88, height: 32)
            }
            .padding(.top, 6)
        }
    }

    private var editContent: some View {
        VStack(spacing: 22) {

            Spacer().frame(height: 120)

            // Avatar swipe
            TabView(selection: $selectedAvatarIndex) {
                ForEach(avatars.indices, id: \.self) { i in
                    ZStack {
                        Circle()
                            .fill(Color("Light6").opacity(0.35))
                            .frame(width: 190, height: 190)

                        Image(avatars[i])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                    }
                    .tag(i)
                }
            }
            .frame(height: 220)
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 8) {
                Capsule().fill(Color("Light6")).frame(width: 22, height: 4)
                Capsule().fill(Color("Light1")).frame(width: 30, height: 4)
                Capsule().fill(Color("Light6")).frame(width: 22, height: 4)
            }

            TextField("", text: $draftName)
                .font(.custom("RussoOne-Regular", size: 28))
                .foregroundColor(Color("Light1"))
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .padding(.horizontal, 22)
                .background(Color("Light6").opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .frame(maxWidth: 240)

            Spacer()
        }
    }

    private func avatarBubble(index: Int, small: Bool) -> some View {
        let circleSize: CGFloat = small ? 90 : 160
        let imgSize: CGFloat = small ? 62 : 120

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedAvatarIndex = index
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color("Light6").opacity(0.35))
                    .frame(width: circleSize, height: circleSize)

                Image(avatars[index])
                    .resizable()
                    .scaledToFit()
                    .frame(width: imgSize, height: imgSize)
            }
        }
        .buttonStyle(.plain)
    }

    private var profileHeader: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color("Light6").opacity(0.35))
                    .frame(width: 225, height: 225)

                Image(vm.avatarImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)

                Button {
                    draftName = vm.userName
                    selectedAvatarIndex = max(0, avatars.firstIndex(of: vm.avatarImageName) ?? 0)
                    isEditing = true
                } label: {
                    Image("Edit")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(8)
                }
                .offset(x: 100, y: 60)
                .buttonStyle(.plain)
                .zIndex(10)
            }

            HStack(spacing: 8) {
                Text(vm.userName)
                    .font(.custom("RussoOne-Regular", size: 30))
                    .foregroundColor(Color("Light1"))
            }
        }
        .padding(.top, -10)
    }

    private var segmentedTabs: some View {
        HStack(spacing: 0) {
            tabPill(title: ProfileViewModel.Tab.history.rawValue, tab: .history)
            tabPill(title: ProfileViewModel.Tab.achievements.rawValue, tab: .achievements)
        }
        .padding(4)
        .background(Color("Light1"))
        .clipShape(Capsule())
    }

    private func tabPill(title: String, tab: ProfileViewModel.Tab) -> some View {
        let isSelected = vm.selectedTab == tab

        return Text(title)
            .font(.custom("RussoOne-Regular", size: 12))
            .foregroundColor(isSelected ? Color("Light3") : Color.white.opacity(0.85))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        Capsule().fill(Color("Light2"))
                    } else {
                        Capsule().fill(Color.clear)
                    }
                }
            )
            .onTapGesture { vm.selectedTab = tab }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch vm.selectedTab {
        case .history:
            historyList
        case .achievements:
            achievementsGrid
        }
    }

    private var historyList: some View {
        VStack(spacing: 12) {
            if vm.historyItems.isEmpty {
                Text("No History yet")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Light4"))
                    .padding(.top, 30)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(vm.historyItems) { item in
                            // ChallengeRowCard(item: item)
                            Text(item.title)
                                .foregroundColor(Color("Light2"))
                        }
                    }
                    .padding(.top, 6)
                }
            }
        }
    }

    private var achievementsGrid: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Ranks")
                    .font(.custom("RussoOne-Regular", size: 14))
                    .foregroundColor(Color("Light2"))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(vm.achievementItems) { a in
                        // AchievementCard(item: a)
                        Text(a.title)
                            .foregroundColor(Color("Light2"))
                    }
                }
                .padding(.top, 6)
            }
        }
    }
}



//private struct ChallengeRowCard: View {
//    let item: ProfileViewModel.ChallengeRowUI
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 6) {
//                Text(item.title)
//                    .font(.custom("RussoOne-Regular", size: 14))
//                    .foregroundColor(Color("Light2"))
//
//                HStack(spacing: 8) {
//                    chip(text: item.stepsText, icon: "figure.walk")
//                    chip(text: item.statusText, icon: "bolt.fill")
//                }
//            }
//
//            Spacer()
//
//            HStack(spacing: 6) {
//                Image(systemName: "person.2.fill")
//                    .font(.system(size: 12, weight: .bold))
//                    .foregroundColor(Color("Light2").opacity(0.8))
//                Text(item.playersText)
//                    .font(.system(size: 12, weight: .bold))
//                    .foregroundColor(Color("Light2").opacity(0.8))
//            }
//        }
//        .padding(.vertical, 12)
//        .padding(.horizontal, 12)
//        .background(Color.white.opacity(0.55))
//        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
//    }
//
//    private func chip(text: String, icon: String) -> some View {
//        HStack(spacing: 4) {
//            Image(systemName: icon)
//                .font(.system(size: 10, weight: .bold))
//            Text(text)
//                .font(.system(size: 10, weight: .bold))
//        }
//        .foregroundColor(Color("Light2"))
//        .padding(.horizontal, 8)
//        .padding(.vertical, 4)
//        .background(Color("Light3").opacity(0.6))
//        .clipShape(Capsule())
//    }
//}

//private struct AchievementCard: View {
//    let item: ProfileViewModel.AchievementUI
//
//    var body: some View {
//        VStack(spacing: 10) {
//            Circle()
//                .fill(Color.white.opacity(0.55))
//                .frame(width: 70, height: 70)
//                .overlay(
//                    Image(systemName: item.iconName)
//                        .font(.system(size: 26, weight: .bold))
//                        .foregroundColor(Color("Light2"))
//                )
//
//            Text(item.title)
//                .font(.custom("RussoOne-Regular", size: 12))
//                .foregroundColor(Color("Light2"))
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 14)
//        .background(Color.white.opacity(0.25))
//        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//    }
//}


// MARK: - Preview
#Preview {
    ProfileView(vm: ProfileViewModel())
}
