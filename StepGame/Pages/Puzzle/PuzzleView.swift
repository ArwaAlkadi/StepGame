

import SwiftUI

struct SoloLatePopupView: View {
    var onClose: () -> Void
    var onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 14) {

            HStack {
                Spacer()
                Button { onClose() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.light1)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            VStack(spacing: 20) {
                Text("You’re falling behind")
                    .font(.custom("RussoOne-Regular", size: 24))
                    .foregroundStyle(Color.light1)
                    .multilineTextAlignment(.center)

                Text("Solve this puzzle to get +1 extra day")
                    .font(.custom("RussoOne-Regular", size: 16))
                    .foregroundStyle(Color.light1)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            Spacer()

            HStack(spacing: 12) {

                Button { onClose() } label: {
                    Text("No")
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundStyle(Color.light1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .overlay(
                                    Capsule().stroke(Color.light4.opacity(0.35), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)

                Button { onConfirm() } label: {
                    Text("Attack")
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundStyle(Color.light1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .overlay(
                                    Capsule().stroke(Color.light4.opacity(0.35), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical)
        }
        .padding(18)
        .frame(maxWidth: 350)
        .frame(height: 340)
        .background(
            RoundedRectangle(cornerRadius: 28).fill(Color.light3)
        )
        .padding(.horizontal, 24)
    }
}


struct GroupAttackPopupView: View {
    var onClose: () -> Void
    var onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 14) {

            HStack {
                Spacer()
                Button { onClose() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.light1)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            VStack(spacing: 20) {
                Text("Take Your Chance")
                    .font(.custom("RussoOne-Regular", size: 24))
                    .foregroundStyle(Color.light1)
                    .multilineTextAlignment(.center)

                Text("Win this puzzle to mess up your friend’s character for 3 hours.")
                    .font(.custom("RussoOne-Regular", size: 16))
                    .foregroundStyle(Color.light1)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            Spacer()

            HStack(spacing: 12) {

                Button { onClose() } label: {
                    Text("No")
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundStyle(Color.light1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .overlay(
                                    Capsule().stroke(Color.light4.opacity(0.35), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)

                Button { onConfirm() } label: {
                    Text("Attack")
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundStyle(Color.light1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .overlay(
                                    Capsule().stroke(Color.light4.opacity(0.35), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical)
        }
        .padding(18)
        .frame(maxWidth: 350)
        .frame(height: 340)
        .background(
            RoundedRectangle(cornerRadius: 28).fill(Color.light3)
        )
        .padding(.horizontal, 24)
    }
}






struct GroupDefensePopupView: View {
    var onClose: () -> Void
    var onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            
            HStack {
                Spacer()
                Button {  } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.light1)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        
            VStack (spacing: 20) {
                Text("Defend Your Progress!")
                    .font(.custom("RussoOne-Regular", size: 24))
                    .foregroundStyle(Color.light1)
                    .multilineTextAlignment(.center)
                    
                   

                Text("Solve the puzzle to protect your progress. Want to try?")
                    .font(.custom("RussoOne-Regular", size: 16))
                    .foregroundStyle(Color.light1)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
          
            Spacer()
            
            HStack(spacing: 12) {
                
                Button {
                    onClose()
                } label: {
                    HStack(spacing: 10) {
                       Text("Later")
                    }
                    .font(.custom("RussoOne-Regular", size: 14))
                    .foregroundStyle(Color.light1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        Capsule()
                            .fill( Color.white)
                            .overlay(
                                Capsule().stroke(Color.light4.opacity(0.35), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)

              
                Button {
                    onConfirm()
                } label: {
                    HStack(spacing: 10) {
                       Text("Defend")
                    }
                    .font(.custom("RussoOne-Regular", size: 14))
                    .foregroundStyle(Color.light1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .overlay(
                                Capsule().stroke(Color.light4.opacity(0.35), lineWidth: 1)
                            )
                    )
                }

                .buttonStyle(.plain)

            }
            .padding(.vertical)
        }
        .padding(18)
        .frame(maxWidth: 350)
        .frame(height: 340)
        .background(
            RoundedRectangle(cornerRadius: 28).fill(Color.light3)
        )
        .padding(.horizontal, 24)
    }
}







import Foundation

enum MapPopupType: Identifiable {
    case soloLate
    case groupAttacker
    case groupDefender

    var id: Int { hashValue }
}



#Preview {
    ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()

        GroupDefensePopupView(
            onClose: { print("Later tapped") },
            onConfirm: { print("Defend tapped") }
        )
        .padding()
    }
}
