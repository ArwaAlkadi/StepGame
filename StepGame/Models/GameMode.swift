//
//  GameMode.swift
//  StepGame
//
//  Created by Rana Alqubaly on 16/08/1447 AH.
//

import SwiftUI

// MARK: - Enums
enum GameMode {
    case solo
    case group
}

enum PlayerRole {
    case attacker
    case defender
}

enum GameResult {
    case success
    case failure
}

// MARK: - Models
struct WireColor: Identifiable, Equatable {
    let id = UUID()
    let color: Color
    let name: String
    
    static let red = WireColor(color: .red, name: "red")
    static let blue = WireColor(color: .blue, name: "blue")
    static let yellow = WireColor(color: .yellow, name: "yellow")
    static let pink = WireColor(color: .pink, name: "pink")
    static let green = WireColor(color: .green, name: "green")
    static let orange = WireColor(color: .orange, name: "orange")
    
    static func == (lhs: WireColor, rhs: WireColor) -> Bool {
        lhs.name == rhs.name
    }
}

struct WireConnection: Identifiable {
    let id = UUID()
    let leftIndex: Int
    let rightIndex: Int
    let color: WireColor
}

class WiringGameModel {
    let wireCount: Int
    var leftWires: [WireColor]
    var rightWires: [WireColor]
    var connections: [WireConnection]
    
    init(wireCount: Int = 6) {
        self.wireCount = wireCount
        let colors = [WireColor.red, WireColor.blue, WireColor.yellow, WireColor.pink, WireColor.green, WireColor.orange]
        self.leftWires = Array(colors.prefix(wireCount))
        self.rightWires = Array(colors.prefix(wireCount)).shuffled()
        self.connections = []
    }
    
    func reset() {
        let colors = [WireColor.red, WireColor.blue, WireColor.yellow, WireColor.pink, WireColor.green, WireColor.orange]
        leftWires = Array(colors.prefix(wireCount))
        rightWires = Array(colors.prefix(wireCount)).shuffled()
        connections = []
    }
    
    func connect(leftIndex: Int, rightIndex: Int) -> Bool {
        let leftColor = leftWires[leftIndex]
        let rightColor = rightWires[rightIndex]
        
        guard leftColor == rightColor else { return false }
        
        connections.removeAll { $0.leftIndex == leftIndex || $0.rightIndex == rightIndex }
        connections.append(WireConnection(leftIndex: leftIndex, rightIndex: rightIndex, color: leftColor))
        
        return true
    }
    
    func disconnect(leftIndex: Int) {
        connections.removeAll { $0.leftIndex == leftIndex }
    }
    
    func disconnectRight(rightIndex: Int) {
        connections.removeAll { $0.rightIndex == rightIndex }
    }
    
    func isComplete() -> Bool {
        connections.count == wireCount
    }
}
