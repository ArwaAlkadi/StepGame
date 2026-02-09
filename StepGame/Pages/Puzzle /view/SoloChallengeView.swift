import SwiftUI


struct SoloChallengeView: View {
    @ObservedObject var viewModel: GameCoordinatorViewModel
    let onClose: () -> Void
    let onConfirm: () -> Void

    
    var body: some View {
        DialogBaseView(onClose: onClose) {      // ← important: pass onClose directly
            VStack(spacing: 20) {
                Text("Need More Time?")
                    .font(.custom("RussoOne-Regular", size: 28))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                
                Text("Solve this puzzle to get 1 extra day")
                    .font(.custom("RussoOne-Regular", size: 18))
                    .foregroundColor(Color(red: 0.17, green: 0.09, blue: 0.06))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 15) {
                    Button {
                        onConfirm()
                    } label: {
                        Text("Yes")
                            .font(.custom("RussoOne-Regular", size: 18))
                            .foregroundColor(.white)
                            .frame(width: 120)
                            .padding(.vertical, 15)
                            .background(Color(red: 0.29, green: 0.15, blue: 0.07))
                            .cornerRadius(25)
                    }
                    
                    Button {
                        viewModel.reset()
                        onClose()
                    } label: {
                        Text("No")
                            .font(.custom("RussoOne-Regular", size: 18))
                            .foregroundColor(Color(red: 0.29, green: 0.15, blue: 0.07))
                            .frame(width: 120)
                            .padding(.vertical, 15)
                            .background(Color(red: 0.91, green: 0.79, blue: 0.64))
                            .cornerRadius(25)
                    }
                }
                .padding(.top, 10)
            }
        }
    }

    }





