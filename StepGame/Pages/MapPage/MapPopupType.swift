//
//  MapPopupType.swift
//  StepGame
//
//  Created by Rana Alqubaly on 21/08/1447 AH.
//


import Foundation

enum MapPopupType: Identifiable {
    case soloLate
    case groupAttacker
    case groupDefender

    var id: Int { hashValue }
}
