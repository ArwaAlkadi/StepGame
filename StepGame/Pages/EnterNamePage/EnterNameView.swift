//
//  EnterNameView.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import SwiftUI
import UIKit

struct EnterNameView: View {

    @EnvironmentObject var session: GameSession
    @StateObject private var vm = EnterNameViewModel()

    var body: some View {
        ZStack {
            Image("Map")
                .resizable()
                .scaledToFill()
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height
                )
                .blur(radius: 5)
                .ignoresSafeArea()

            VStack {
                Spacer()

                ZStack {
                    Rectangle()
                        .foregroundStyle(.light2)
                        .frame(height: 360)
                        .cornerRadius(40)
                        .ignoresSafeArea(edges: .bottom)

                    VStack(spacing: 16) {
                        Text("Enter Your Name!")
                            .font(.custom("RussoOne-Regular", size: 30))
                            .foregroundStyle(.light3)
                            .padding(.top, 18)

                        VStack(alignment: .leading, spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28)
                                    .foregroundStyle(.light3.opacity(0.25))
                                    .frame(height: 56)

                                TextField("Name", text: $vm.name)
                                    .font(.custom("RussoOne-Regular", size: 20))
                                    .foregroundStyle(.light3)
                                    .padding(.horizontal, 20)
                                    .onChange(of: vm.name) { _, newValue in
                                        vm.enforceNameLimit(newValue)
                                    }
                            }

                            Text("\(vm.name.count)/\(vm.maxNameCount)")
                                .font(.custom("RussoOne-Regular", size: 14))
                                .foregroundStyle(.light3.opacity(0.9))
                                .padding(.horizontal, 8)
                        }
                        .padding(.horizontal, 24)

                        Button {
                            Task { await session.createPlayer(name: vm.name) }
                        } label: {
                            Text(session.isLoading ? "Saving..." : "Start")
                                .font(.custom("RussoOne-Regular", size: 26))
                                .foregroundStyle(.light3)
                                .frame(width: 200, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 36)
                                        .foregroundStyle(.light1)
                                )
                        }
                        .disabled(!vm.isStartEnabled || session.isLoading)
                        .opacity((!vm.isStartEnabled || session.isLoading) ? 0.5 : 1)

                        if let msg = session.errorMessage {
                            Text(msg)
                                .font(.custom("RussoOne-Regular", size: 12))
                                .foregroundStyle(.red)
                                .padding(.top, 6)
                        }

                        Spacer().frame(height: 24)
                    }
                }
            }
        }
    }
}
