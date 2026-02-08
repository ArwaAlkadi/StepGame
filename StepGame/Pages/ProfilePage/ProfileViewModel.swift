//
//  ProfileViewModel.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject{
    enum Tab : String,CaseIterable{
        case history = "History"
        case achievements = "Achievements"
    }
    
    @Published var selectedTab: Tab = .history
    
    @Published var userName : String = "Sarah"
    @Published var avatarImageName: String = "character1"
    
    @Published var historyItems : [ChallengeRowUI]=[
        .init(title: "Let us woke!", stepsText: "25,000", statusText: "Active", playersText: "2"),
        .init(title: "Desert Walk", stepsText: "10,000", statusText: "Active", playersText: "2"),
        .init(title: "Morning Run", stepsText: "5,000", statusText: "Done", playersText: "1")
    ]
    
    
    @Published var achievementItems: [AchievementUI] = [
        .init(iconName: "crown.fill", title: "Won - 3"),
        .init(iconName: "crown", title: "Won - 2"),
        .init(iconName: "flame.fill", title: "Won - 1")
    ]
    
    func didTapEditName() {
        
        
    }
    
    func didTapDone() {
    }
    
    struct ChallengeRowUI: Identifiable {
        let id = UUID()
        let title: String
        let stepsText: String
        let statusText: String
        let playersText: String
    }
    
    struct AchievementUI: Identifiable {
        let id = UUID()
        let iconName: String
        let title: String
    }
}

