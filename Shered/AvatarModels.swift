//
//  AvatarModels.swift
//  StepGame
//
//  Created by Aryam on 06/02/2026.
//
enum AvatarType: String {
    case ray
    case luna
    case rosy
}

enum AvatarState: String {
    case fat
    case normal
    case strong
}

enum ChallengeDuration {
    case threeDays
    case week
    case month

    var days: Int {
        switch self {
        case .threeDays: return 3
        case .week: return 7
        case .month: return 30
        }
    }
}
