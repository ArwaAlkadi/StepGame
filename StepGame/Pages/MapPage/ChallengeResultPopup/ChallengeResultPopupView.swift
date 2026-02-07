//
//  ChallengeResultPopupView.swift
//  StepGame
//
//  Created by Arwa Alkadi on 07/02/2026.
//

import SwiftUI
import Combine

struct ChallengeResultPopup: View {

    @Binding var isPresented: Bool
    @StateObject var vm: ChallengeResultPopupViewModel

    var body: some View {
        ZStack {

            Color.black.opacity(0.35)
                .ignoresSafeArea()

            // Card
            VStack {

                // Close
                HStack {
                    Spacer()
                    Button { close() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.light2)
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                }

                // Title
                Text(vm.titleText)
                    .font(.custom("RussoOne-Regular", size: 30))
                    .foregroundStyle(Color.light1)

                // Content
                Group {
                    switch vm.mode {
                    case .group:
                        groupContent
                    case .solo:
                        soloContent
                    }
                }

                // Footer
                Text(vm.footerText)
                    .font(.custom("RussoOne-Regular", size: 16))
                    .foregroundStyle(Color.light1)
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer(minLength: 0)
            }
            .padding(18)
            .frame(maxWidth: 350)
            .frame(height: 320)
            .background(
                RoundedRectangle(cornerRadius: 28).fill(Color.light3)
            )
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Group content

    private var groupContent: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.light4.opacity(0.75))

                ScrollView(showsIndicators: true) {
                    VStack(spacing: 10) {
                        ForEach(vm.rows) { p in
                            GroupPlayerRow(p: p, showPlaces: vm.showPlaces)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 12)
                    .padding(.trailing, 8)
                }
            }
            .frame(height: 130)
        }
    }

    // MARK: - Solo content

    private var soloContent: some View {
        VStack(spacing: 10) {
            Image(vm.soloAvatar)
                .resizable()
                .scaledToFit()
                .frame(width: 300)
        }
        .frame(maxWidth: .infinity)
    }

    private func close() {
        withAnimation(.easeInOut) { isPresented = false }
    }
}

// MARK: - Row

private struct GroupPlayerRow: View {
    let p: ChallengeResultPopupViewModel.Row
    let showPlaces: Bool

    var body: some View {
        HStack(spacing: 10) {

            Image(p.avatarImage)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color.light2.opacity(0.3)))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {

                    if showPlaces, let place = p.place {
                        Image(placeAssetName(place))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .padding(.bottom, 3)
                    }

                    Text(p.name + (p.isMe ? " (Me)" : ""))
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundStyle(Color.light1)
                }

                Text(p.stepsText)
                    .font(.custom("RussoOne-Regular", size: 11))
                    .foregroundStyle(Color.light1.opacity(0.75))
            }

            Spacer()
        }
        .padding(.horizontal, 6)
    }

    private func placeAssetName(_ place: ChallengeResultPopupViewModel.PlayerPlace) -> String {
        switch place {
        case .first:  return "Place1"
        case .second: return "Place2"
        case .third:  return "Place3"
        }
    }
}
