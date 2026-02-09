import SwiftUI


struct SoloChallengeView: View {
    @ObservedObject var viewModel: GameCoordinatorViewModel
    
    var body: some View {
        DialogBaseView(onClose: { viewModel.reset() }) {
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
                    Button(action: {
                        viewModel.startAttackerGame()
                    }) {
                        Text("Yes")
                            .font(.custom("RussoOne-Regular", size: 18))
                            .foregroundColor(.white)
                            .frame(width: 120)
                            .padding(.vertical, 15)
                            .background(Color(red: 0.29, green: 0.15, blue: 0.07))
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        viewModel.reset()
                    }) {
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




// MARK: - Preview
struct SoloChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            
            SoloChallengeView(viewModel: GameCoordinatorViewModel())
        }
        .previewDisplayName("Solo Challenge - Need More Time")
    }
}
