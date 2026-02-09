//
//  RightWiresColumn.swift
//  StepGame
//
//  Created by Rana Alqubaly on 21/08/1447 AH.
//
import SwiftUI

struct RightWiresColumn: View {
    @ObservedObject var viewModel: WiringGameViewModel
    let geometry: GeometryProxy
    let leftPositions: [CGFloat]
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(Array(viewModel.rightWires.enumerated()), id: \.element.id) { index, wire in
                WireNodeView(
                    color: wire,
                    isSelected: viewModel.selectedRight == index,
                    isDragging: viewModel.draggedRightIndex == index,
                    isHovered: viewModel.hoveredRightIndex == index
                )
                .onTapGesture {
                    viewModel.handleRightTap(index: index)
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            viewModel.startDraggingRight(index: index)
                            viewModel.currentDragLocation = value.location
                        }
                        .onEnded { value in
                            let endLocation = value.location
                            
                            if endLocation.x < geometry.size.width / 2 {
                                var closestIndex = 0
                                var minDistance = CGFloat.infinity
                                
                                for i in 0..<leftPositions.count {
                                    let distance = abs(endLocation.y - leftPositions[i])
                                    if distance < minDistance {
                                        minDistance = distance
                                        closestIndex = i
                                    }
                                }
                                
                                if minDistance < 50 {
                                    viewModel.dropOnLeft(leftIndex: closestIndex)
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
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 30)
        .padding(.top, 30)
    }
}
