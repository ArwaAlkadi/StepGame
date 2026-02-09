//
//  LeftWiresColumn.swift
//  StepGame
//
//  Created by Rana Alqubaly on 21/08/1447 AH.
//
import SwiftUI

struct LeftWiresColumn: View {
    @ObservedObject var viewModel: WiringGameViewModel
    let geometry: GeometryProxy
    let rightPositions: [CGFloat]
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(Array(viewModel.leftWires.enumerated()), id: \.element.id) { index, wire in
                WireNodeView(
                    color: wire,
                    isSelected: viewModel.selectedLeft == index,
                    isDragging: viewModel.draggedLeftIndex == index,
                    isHovered: viewModel.hoveredLeftIndex == index
                )
                .onTapGesture {
                    viewModel.handleLeftTap(index: index)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            viewModel.startDraggingLeft(index: index)
                            viewModel.currentDragLocation = value.location
                        }
                        .onEnded { value in
                            let endLocation = value.location

                            if endLocation.x > geometry.size.width / 2 {
                                var closestIndex = 0
                                var minDistance = CGFloat.infinity
                                
                                for i in 0..<rightPositions.count {
                                    let distance = abs(endLocation.y - rightPositions[i])
                                    if distance < minDistance {
                                        minDistance = distance
                                        closestIndex = i
                                    }
                                }
                                
                                if minDistance < 50 {
                                    viewModel.dropOnRight(rightIndex: closestIndex)
                                } else {
                                    viewModel.cancelDrag()
                                }
                            } else {
                                viewModel.cancelDrag()
                            }
                        }
                )
            }
        }
        .padding(.leading, 30)
        .padding(.top, 30)
    }
}
