//
//  ShareCodePopup.swift
//  StepGame
//
//  Created by Claude on 02/02/2026.
//

import SwiftUI

struct ShareCodePopup: View {
    @Binding var isPresented: Bool
    let joinCode: String
    
    var body: some View {
        ZStack {
            // Blurred Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Don't dismiss on background tap for this popup
                }
            
            // Modal Card - Centered
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color("Light1"))
                                .frame(width: 35, height: 35)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 15)
                    .padding(.top, 15)
                }
                
                // Title
                Text("Invite Others to Your Challenge")
                    .font(.custom("RussoOne-Regular", size: 22))
                    .foregroundColor(Color("Light1"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                
                // Join Code Display
                HStack(spacing: 15) {
                    // Code box
                    HStack(spacing: 8) {
                        Image(systemName: "square.fill.on.square.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color("Light1"))
                        
                        Text(joinCode)
                            .font(.custom("RussoOne-Regular", size: 20))
                            .foregroundColor(Color("Light1"))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(25)
                    
                    // Share button
                    Button(action: {
                        shareCode()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(Color("Light1"))
                            .frame(width: 45, height: 45)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 30)
                
                // Continue Button
                Button(action: {
                    isPresented = false
                    // TODO: Navigate to challenge/map view
                }) {
                    Text("Continue")
                        .font(.custom("RussoOne-Regular", size: 20))
                        .foregroundColor(.white)
                        .frame(width: 220, height: 55)
                        .background(Color("Light1"))
                        .cornerRadius(30)
                }
                .padding(.bottom, 30)
            }
            .background(Color("Light3"))
            .cornerRadius(30)
            .frame(width: 350)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
    
    private func shareCode() {
        let activityVC = UIActivityViewController(
            activityItems: ["Join my challenge with code: \(joinCode)"],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        ShareCodePopup(isPresented: .constant(true), joinCode: "QU123Z")
    }
}
