//
//  ProfileView.swift
//  StepGame
//
//

import SwiftUI
import Combine

// MARK: - Profile View
struct ProfileView: View {

    @EnvironmentObject private var session: GameSession
    @StateObject private var vm = ProfileViewModel()

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.light3.ignoresSafeArea()

            VStack(spacing: 28) {
                topBar

                Spacer(minLength: 10)

                if vm.isEditing {
                    editingContent
                } else {
                    viewContent
                }

                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
        }
        .onAppear {
            vm.loadFromSession(session.player)
        }
        .onChange(of: session.player?.id) { _, _ in
            vm.loadFromSession(session.player)
        }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "Something went wrong.")
        }
    }
        

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            if vm.isEditing {
                Button {
                    Task { await doneTapped() }
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.custom("RussoOne-Regular", size: 18))
                        .foregroundStyle(Color.light1)
                }
                .disabled(vm.isSaving)
                .opacity(vm.isSaving ? 0.6 : 1)

            } else {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color.light1)
                }
            }

            Spacer()
        }
        .padding(.top, 6)
    }

    // MARK: - View Mode Content

    private var viewContent: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                AvatarCircle(
                    imageName: vm.selectedCharacter.normalKey(),
                    size: 290
                )

                Button {
                    vm.enterEdit()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundStyle(Color.light1)
                }
                .offset(x: -25, y: -20)
            }

            Text(vm.displayName)
                .font(.custom("RussoOne-Regular", size: 34))
                .foregroundStyle(Color.light1)
        }
    }

    // MARK: - Editing Content

    private var editingContent: some View {
        VStack(spacing: 20) {
            CharacterCarousel(
                selection: $vm.selectedCharacter,
                all: vm.allCharacters
            )

            CapsuleIndicator(currentIndex: vm.selectedIndex, total: vm.allCharacters.count)

            nameEditor

            if vm.isSaving {
                Text("Saving...")
                    .font(.custom("RussoOne-Regular", size: 14))
                    .foregroundStyle(Color.light2)
            }
        }
    }

    private var nameEditor: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text("Name")
                .font(.custom("RussoOne-Regular", size: 14))
                .foregroundStyle(Color.light1)
                .padding(.horizontal)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.light4.opacity(0.7))
                    .stroke(Color.light1, lineWidth: 2)
                    .frame(height: 54)

                TextField("Name", text: $vm.draftName)
                    .font(.custom("RussoOne-Regular", size: 22))
                    .foregroundStyle(Color.light1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 14)
            }
        }
        .frame(maxWidth: 320)
    }

    // MARK: - Actions

    private func doneTapped() async {
        guard let sessionPlayer = session.player else { return }

        let ok = vm.validateDraft()
        guard ok else { return }

        await vm.save(session: session, currentPlayer: sessionPlayer)
        if !vm.showError {
            vm.exitEdit()
        }
    }
}

// MARK: - Avatar Circle

private struct AvatarCircle: View {
    let imageName: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.light4.opacity(0.6))
                .frame(width: size, height: size)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.82, height: size * 0.82)
        }
    }
}

// MARK: - Character Carousel

private struct CharacterCarousel: View {

    @Binding var selection: CharacterType
    let all: [CharacterType]

    var body: some View {
        TabView(selection: $selection) {
            ForEach(all, id: \.rawValue) { type in
                AvatarCircle(imageName: type.normalKey(), size: 290)
                    .tag(type)
                    .padding(.horizontal, 30)
            }
        }
        .frame(height: 300)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

// MARK: - Capsule Indicator

private struct CapsuleIndicator: View {
    let currentIndex: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i == currentIndex ? Color.light1 : Color.light1.opacity(0.25))
                    .frame(width: i == currentIndex ? 26 : 8, height: 6)
            }
        }
    }
}

// MARK: - Preview Host

#Preview("ProfileView (View Mode)") {
    ProfilePreviewHost(startEditing: false)
}

#Preview("ProfileView (Editing Mode)") {
    ProfilePreviewHost(startEditing: true)
}

private struct ProfilePreviewHost: View {

    let startEditing: Bool

    @StateObject private var session = GameSession()
    @StateObject private var health = HealthKitManager()

    var body: some View {
        NavigationStack {
            ProfileView()
                .environmentObject(session)
                .environmentObject(health)
        }
        .onAppear {
            session.player = Player(
                id: "preview_uid",
                name: "Sarah",
                totalChallenges: 3,
                completedChallenges: 1,
                totalSteps: 12000,
                characterType: .character1,
                lastUpdated: Date(),
                createdAt: Date()
            )
            session.playerName = "Sarah"

            if startEditing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    session.player?.name = "Sarah"
                }
            }
        }
    }
}
