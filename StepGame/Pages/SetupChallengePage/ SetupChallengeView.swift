//
//   SetupChallengeView.swift
//  StepGame
//

import SwiftUI
import Combine

struct SetupChallengeView: View {

    @Binding var isPresented: Bool
    @EnvironmentObject var session: GameSession

    @StateObject private var vm = SetupChallengeViewModel()

    @State private var showSharePopup = false
    @StateObject private var shareVM = ShareChallengeCodeViewModel(code: "")

    var body: some View {
        ZStack {
            Color.black.opacity(0.15).ignoresSafeArea()

            VStack(spacing: 18) {

                // Header
                HStack {
                    Text("Create a New Challenge")
                        .font(.custom("RussoOne-Regular", size: 22))
                        .foregroundStyle(Color.light1)

                    Spacer()

                    Button { isPresented = false } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.light3)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.light1.opacity(0.9)))
                    }
                    .buttonStyle(.plain)
                }

                // Name
                VStack(alignment: .leading, spacing: 6) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.light4.opacity(0.55))
                            .frame(height: 46)

                        TextField("Challenge Name", text: $vm.challengeName)
                            .font(.custom("RussoOne-Regular", size: 16))
                            .foregroundStyle(Color.light1)
                            .padding(.horizontal, 14)
                            .onChange(of: vm.challengeName) { _, _ in
                                vm.clampName()
                            }
                    }

                    HStack {
                        Text("\(vm.challengeName.count)/\(vm.maxNameCount)")
                        Spacer()
                        if let err = vm.errorMessage {
                            Text(err).foregroundStyle(.red)
                        }
                    }
                    .font(.custom("RussoOne-Regular", size: 12))
                    .foregroundStyle(Color.light2)
                    .padding(.leading, 6)
                }

                // Period
                VStack(alignment: .leading, spacing: 10) {
                    Text("Period")
                        .font(.custom("RussoOne-Regular", size: 18))
                        .foregroundStyle(Color.light1)

                    HStack(spacing: 12) {
                        ForEach(PeriodOption.allCases, id: \.title) { option in
                            PeriodChip(
                                title: option.title,
                                isSelected: vm.selectedPeriod == option
                            ) { vm.selectedPeriod = option }
                        }
                    }
                }

                // Steps
                VStack(alignment: .leading, spacing: 10) {
                    Text("Steps")
                        .font(.custom("RussoOne-Regular", size: 18))
                        .foregroundStyle(Color.light1)

                    Slider(value: $vm.steps, in: 1000...500_000, step: 500)
                        .tint(Color.light1)

                    HStack {
                        Text("1000")
                        Spacer()
                        Text("500,000")
                    }
                    .font(.custom("RussoOne-Regular", size: 12))
                    .foregroundStyle(Color.light2)

                    Text("\(Int(vm.steps).formatted()) steps")
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundStyle(Color.light1.opacity(0.9))
                }

                // Mode
                HStack(spacing: 14) {
                    ModeChip(
                        title: "Solo",
                        systemIcon: "person.fill",
                        isSelected: vm.mode == .solo
                    ) {
                        vm.mode = .solo
                    }

                    ModeChip(
                        title: "Group",
                        systemIcon: "person.2.fill",
                        isSelected: vm.mode == .group
                    ) {
                        vm.mode = .group
                    }
                }

                Spacer(minLength: 6)

                // Create
                Button {
                    Task {
                        let outcome = await vm.createChallenge(session: session)

                        switch outcome {
                        case .soloCreated:
                            isPresented = false

                        case .groupCreated(let joinCode):
                            shareVM.code = joinCode
                            showSharePopup = true

                        case .failed:
                            break
                        }
                    }
                } label: {
                    Text(session.isLoading ? "Creating..." : "Create")
                        .font(.custom("RussoOne-Regular", size: 18))
                        .foregroundStyle(Color.light3)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 26).fill(Color.light1)
                        )
                }
                .buttonStyle(.plain)
                .disabled(session.isLoading)
                .opacity(session.isLoading ? 0.6 : 1.0)
                .padding(.top, 8)
            }
            .padding(18)
            .frame(maxWidth: 380)
            .frame(height: 520)
            .background(RoundedRectangle(cornerRadius: 28).fill(Color.light3))
            .padding(.horizontal, 20)
        }
        .overlay {
            if showSharePopup {
                ShareChallengeCodePopup(
                    isPresented: $showSharePopup,
                    vm: shareVM,
                    onContinue: {
                        isPresented = false
                    }
                )
            }
        }
    }
}

// MARK: - Components

private struct PeriodChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("RussoOne-Regular", size: 14))
                .foregroundStyle(Color.light1)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color.light3)
                        .overlay(
                            Capsule()
                                .stroke(Color.light4.opacity(0.35), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

private struct ModeChip: View {
    let title: String
    let systemIcon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemIcon)
                Text(title)
            }
            .font(.custom("RussoOne-Regular", size: 14))
            .foregroundStyle(Color.light1)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white : Color.light3)
                    .overlay(
                        Capsule().stroke(Color.light4.opacity(0.35), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
