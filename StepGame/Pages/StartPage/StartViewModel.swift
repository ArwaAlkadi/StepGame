//
//  StartViewModel.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class StartViewModel: ObservableObject {

    @Published var showJoinPopup: Bool = false

    func greetingText(playerName: String?) -> String {
        let name = (playerName?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 } ?? "Player"
        return "Hi, \(name)!"
    }

    func subtitleText() -> String {
        "Let’s start your step challenge"
    }

    func avatarImageName(characterType: CharacterType?) -> String {
        // fallback avatar
        let type = characterType ?? .character1
        return type.imageKey(state: .normal)
    }

    func isInteractionEnabled(isLoading: Bool, isHealthAuthorized: Bool) -> Bool {
        !isLoading && isHealthAuthorized
    }
}
