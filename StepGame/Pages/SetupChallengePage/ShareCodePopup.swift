////
////  ShareCodePopup.swift
////  StepGame
////
//
//import SwiftUI
//import Combine
//import UIKit
//
//@MainActor
//final class ShareChallengeCodeViewModel: ObservableObject {
//    @Published var code: String
//    @Published var didCopy: Bool = false
//
//    init(code: String) {
//        self.code = code
//    }
//
//    func copyCode() {
//        UIPasteboard.general.string = code
//        didCopy = true
//
//        Task {
//            try? await Task.sleep(nanoseconds: 900_000_000)
//            didCopy = false
//        }
//    }
//}
//
//struct ShareChallengeCodePopup: View {
//
//    @Binding var isPresented: Bool
//    @StateObject var vm: ShareChallengeCodeViewModel
//
//    var onContinue: () -> Void = {}
//
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.35)
//                .ignoresSafeArea()
//                .onTapGesture { close() }
//
//            VStack(spacing: 14) {
//
//                HStack {
//                    Spacer()
//                    Button { close() } label: {
//                        Image(systemName: "xmark")
//                            .font(.system(size: 14, weight: .bold))
//                            .foregroundStyle(Color.light3)
//                            .frame(width: 30, height: 30)
//                            .background(Circle().fill(Color.light1.opacity(0.9)))
//                    }
//                    .buttonStyle(.plain)
//                }
//
//                Text("Invite Others to Your Challenge")
//                    .font(.custom("RussoOne-Regular", size: 18))
//                    .foregroundStyle(Color.light1)
//                    .multilineTextAlignment(.center)
//
//                HStack(spacing: 10) {
//
//                    Button {
//                        vm.copyCode()
//                    } label: {
//                        HStack(spacing: 10) {
//                            Image(systemName: "doc.on.doc.fill")
//                            Text(vm.code.uppercased())
//                                .font(.custom("RussoOne-Regular", size: 18))
//                        }
//                        .foregroundStyle(Color.light1)
//                        .padding(.horizontal, 14)
//                        .frame(height: 44)
//                        .background(Capsule().fill(Color.light4.opacity(0.8)))
//                    }
//                    .buttonStyle(.plain)
//
//                    Button {
//                        // Optional later: ShareLink / UIActivityViewController
//                    } label: {
//                        Image(systemName: "square.and.arrow.up")
//                            .font(.system(size: 18, weight: .bold))
//                            .foregroundStyle(Color.light1)
//                            .frame(width: 44, height: 44)
//                            .background(Circle().fill(Color.light4.opacity(0.8)))
//                    }
//                    .buttonStyle(.plain)
//                }
//
//                if vm.didCopy {
//                    Text("Copied!")
//                        .font(.custom("RussoOne-Regular", size: 12))
//                        .foregroundStyle(Color.light2)
//                }
//
//                Button {
//                    close()
//                    onContinue()
//                } label: {
//                    Text("Continue")
//                        .font(.custom("RussoOne-Regular", size: 18))
//                        .foregroundStyle(Color.light3)
//                        .frame(width: 170, height: 46)
//                        .background(RoundedRectangle(cornerRadius: 23).fill(Color.light1))
//                }
//                .buttonStyle(.plain)
//            }
//            .padding(18)
//            .frame(maxWidth: 340)
//            .background(RoundedRectangle(cornerRadius: 28).fill(Color.light3))
//            .padding(.horizontal, 24)
//        }
//    }
//
//    private func close() {
//        withAnimation(.easeInOut) { isPresented = false }
//    }
//}
