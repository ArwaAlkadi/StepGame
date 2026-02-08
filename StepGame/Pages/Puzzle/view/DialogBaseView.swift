//
//  DialogBaseView.swift
//  StepGame
//
//  Created by Rana Alqubaly on 17/08/1447 AH.
//

import SwiftUI


import SwiftUI

struct DialogBaseView<Content: View>: View {
    let onClose: () -> Void
    let content: () -> Content
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.brown)
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                content()
                    .padding(.bottom, 25)
            }
            .frame(width: 340)
            .background(Color(red: 0.96, green: 0.87, blue: 0.70))
            .cornerRadius(25)
            .shadow(radius: 20)
        }
    }
}
