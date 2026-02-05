//
//  DialogBaseView.swift
//  StepGame
//
//  Created by Rana Alqubaly on 17/08/1447 AH.
//

import SwiftUI


// MARK: - Dialog Base Component
struct DialogBaseView<Content: View>: View {
    let content: Content
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.onClose = onClose
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(red: 0.63, green: 0.32, blue: 0.18))
                        .clipShape(Circle())
                }
            }
            .padding(.top, 15)
            .padding(.trailing, 15)
            
            content
                .padding(.bottom, 40)
        }
        .frame(width: 350)
        .background(Color(red: 0.96, green: 0.87, blue: 0.70))
        .cornerRadius(30)
        .shadow(radius: 20)
    }
}
