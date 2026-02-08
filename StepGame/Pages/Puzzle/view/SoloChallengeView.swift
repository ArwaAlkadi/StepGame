import SwiftUI


struct SoloChallengeView: View {
    @ObservedObject var viewModel: GameCoordinatorViewModel
    
    var body: some View {
        DialogBaseView(onClose: { viewModel.reset() }) {
            VStack(spacing: 20) {
                Text("Need More Time?")
                    .font(.custom("RussoOne-Regular", size: 28))
                
                Text("Complete this puzzle to earn a secret reward.")
                    .font(.custom("RussoOne-Regular", size: 18))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack(spacing: 15) {
                    
                    Button(action: {
                        viewModel.startSoloGame()   // ✅ OPEN PUZZLE
                    }) {
                        Text("Yes")
                            .font(.custom("RussoOne-Regular", size: 18))
                            .foregroundColor(.white)
                            .frame(width: 120)
                            .padding(.vertical, 12)
                            .background(Color.brown)
                            .cornerRadius(20)
                    }
                    
                    Button(action: {
                        viewModel.reset()
                    }) {
                        Text("No")
                            .font(.custom("RussoOne-Regular", size: 18))
                            .foregroundColor(.brown)
                            .frame(width: 120)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.91, green: 0.79, blue: 0.64))
                            .cornerRadius(20)
                    }
                }
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
