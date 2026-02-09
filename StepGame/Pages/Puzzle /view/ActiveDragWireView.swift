//
//  ActiveDragWireView.swift
//  StepGame
//
//  Created by Rana Alqubaly on 21/08/1447 AH.
//

import SwiftUI


struct ActiveDragWireView: View {
    let dragLocation: CGPoint
    let draggedLeftIndex: Int?
    let draggedRightIndex: Int?
    let leftPositions: [CGFloat]
    let rightPositions: [CGFloat]
    let leftWires: [WireColor]
    let rightWires: [WireColor]
    let width: CGFloat
    
    var body: some View {
        ZStack {
            // FROM LEFT
            if let leftIndex = draggedLeftIndex,
               leftIndex < leftPositions.count {
                
                let startY = leftPositions[leftIndex]
                let color = leftWires[leftIndex].color
                
                Path { path in
                    path.move(to: CGPoint(x: 60, y: startY))
                    path.addCurve(
                        to: dragLocation,
                        control1: CGPoint(x: width / 2, y: startY),
                        control2: CGPoint(x: width / 2, y: dragLocation.y)
                    )
                }
                .stroke(color, style: StrokeStyle(lineWidth: 6, dash: [10]))
                .shadow(color: color.opacity(0.6), radius: 8)
            }
            
            // FROM RIGHT
            if let rightIndex = draggedRightIndex,
               rightIndex < rightPositions.count {
                
                let startY = rightPositions[rightIndex]
                let color = rightWires[rightIndex].color
                
                Path { path in
                    path.move(to: CGPoint(x: width - 60, y: startY))
                    path.addCurve(
                        to: dragLocation,
                        control1: CGPoint(x: width / 2, y: startY),
                        control2: CGPoint(x: width / 2, y: dragLocation.y)
                    )
                }
                .stroke(color, style: StrokeStyle(lineWidth: 6, dash: [10]))
                .shadow(color: color.opacity(0.6), radius: 8)
            }
        }
    }
}
