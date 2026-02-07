//
//  EnterNameViewModel.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class EnterNameViewModel: ObservableObject {

    @Published var name: String = ""

    let maxNameCount: Int = 20

    var isStartEnabled: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func enforceNameLimit(_ newValue: String) {
        if newValue.count > maxNameCount {
            name = String(newValue.prefix(maxNameCount))
        }
    }
}
