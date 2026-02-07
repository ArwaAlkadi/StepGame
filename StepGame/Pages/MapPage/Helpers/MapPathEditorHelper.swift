//
//  MapPathEditorHelper.swift
//  StepGame
//
//  Created by Arwa Alkadi on 05/02/2026.
//

import Foundation
import SwiftUI

struct MapPathEditorHelper: View {

    @State private var points: [CGPoint] = []

    var body: some View {
        ScrollView {
            Image("Map")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .overlay {
                    GeometryReader { geo in
                        let size = geo.size

                        // نقاط مرسومة
                        ForEach(points.indices, id: \.self) { i in
                            Circle()
                                .fill(.blue)
                                .frame(width: 14, height: 14)
                                .position(
                                    x: points[i].x * size.width,
                                    y: points[i].y * size.height
                                )
                        }

                        // ✅ tap يضيف نقطة ويطبع
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        let x = min(max(value.location.x / size.width, 0), 1)
                                        let y = min(max(value.location.y / size.height, 0), 1)

                                        points.append(.init(x: x, y: y))
                                        print("    .init(x: \(String(format: "%.3f", x)), y: \(String(format: "%.3f", y))),")
                                    }
                            )
                    }
                }
        }
    }
}

#Preview {
    MapPathEditorHelper()
}
