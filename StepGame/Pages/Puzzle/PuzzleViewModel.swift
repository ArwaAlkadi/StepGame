//
//  PuzzleWiringGame.swift
//  StepGame
//
//  Note: Wiring puzzle inspired by Among Us - with circular nodes
//

import Foundation
import SwiftUI
import Combine

// MARK: - PuzzleRequest

enum PuzzleRequest: Identifiable {
    case soloExtension
    case groupAttack
    case groupDefense

    var id: Int { hashValue }
}

// MARK: - PuzzleWiringView

struct PuzzleWiringView: View {

    let timeLimit: Double
    let onFinish: (_ success: Bool, _ timeSeconds: Double, _ didTimeout: Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: WiringGameViewModel

    init(
        timeLimit: Double = 8.0,
        onFinish: @escaping (_ success: Bool, _ timeSeconds: Double, _ didTimeout: Bool) -> Void
    ) {
        self.timeLimit = timeLimit
        self.onFinish = onFinish
        self._viewModel = StateObject(wrappedValue: WiringGameViewModel(timeLimit: timeLimit))
    }

    var body: some View {
        ZStack {
         
            Color.light3
                .ignoresSafeArea()

            VStack(spacing: 20) {
                header
                board
            }
        }
        .onChange(of: viewModel.isComplete) { completed in
            guard completed else { return }
            finish(success: true)
        }
        .onChange(of: viewModel.hasFailed) { failed in
            guard failed else { return }
            finish(success: false)
        }
    }

  

    private var header: some View {
      

            VStack(spacing: 8) {
                
                HStack {
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundColor(.light1)
                            
                           
                    }
                  
                }
                .padding(.horizontal)
              
                
                Text("Match the Wires!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.light1)

                HStack(spacing: 8) {
                    Image(systemName: "timer")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(viewModel.timeRemaining <= 3 ? .red : Color.light1)

                    Text(String(format: "%.1f", max(0, viewModel.timeRemaining)))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(viewModel.timeRemaining <= 3 ? .red : Color.light1)
                        .monospacedDigit()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.light4)
                .cornerRadius(10)
                
              
            }

          

           
       
    }

    // نفس اللوح عندك (رمادي + ظل) لكن داخله صار مثل لعبتك الثانية
    private var board: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.light3)
                .shadow(radius: 30)

            WiringBoardLikeYourGame(gameState: viewModel.gameState)
                .padding()
        }
        .padding(.horizontal, 18)
        .frame(height: 560)
    }

    private func finish(success: Bool) {
        let spent = max(0, timeLimit - viewModel.timeRemaining)
        let didTimeout = (!success && viewModel.timeRemaining <= 0.01)
        onFinish(success, spent, didTimeout)
        dismiss()
    }
}

// MARK: - Board (مثل لعبتك الثانية تمامًا)

struct WiringBoardLikeYourGame: View {
    @ObservedObject var gameState: WiringGameState

    var body: some View {
        GeometryReader { _ in
            ZStack {
                // الخطوط المكتملة
                ForEach(gameState.lines) { line in
                    WavyLinePath(start: line.startPoint, end: line.endPoint)
                        .stroke(line.color, lineWidth: 10)
                        .opacity(0.85)
                }

                // الخط الحالي أثناء الرسم
                if let currentLine = gameState.currentLine {
                    WavyLinePath(start: currentLine.startPoint, end: currentLine.endPoint)
                        .stroke(currentLine.color, lineWidth: 10)
                        .opacity(0.6)
                }

                // الدوائر
                ForEach(gameState.circles) { circle in
                    WireNodeCircle(color: circle.color, isActive: gameState.isCircleActive(circle))
                        .position(circle.position)
                }
            }
            // أهم شيء: السحب على اللوحة كلها (نفس لعبتك)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        gameState.handleDragChanged(location: value.location)
                    }
                    .onEnded { value in
                        gameState.handleDragEnded(location: value.location)
                    }
            )
        }
    }
}

// MARK: - WavyLinePath (نفس لعبتك)

struct WavyLinePath: Shape {
    let start: CGPoint
    let end: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let dx = end.x - start.x
        let dy = end.y - start.y
        let distance = sqrt(dx * dx + dy * dy)

        // نفس الإحساس
        let waveCount = max(1, Int(distance / 30))
        let amplitude: CGFloat = 30

        path.move(to: start)

        if distance > 0.001 {
            for i in 0...waveCount {
                let t = CGFloat(i) / CGFloat(waveCount)

                let straightX = start.x + dx * t
                let straightY = start.y + dy * t

                let perpX = -dy / distance
                let perpY = dx / distance

                let wave = sin(t * .pi * CGFloat(waveCount) * 2) * amplitude

                let controlPoint = CGPoint(
                    x: straightX + perpX * wave,
                    y: straightY + perpY * wave
                )

                if i == 0 {
                    path.move(to: start)
                } else if i == waveCount {
                    path.addQuadCurve(to: end, control: controlPoint)
                } else {
                    let nextT = CGFloat(i + 1) / CGFloat(waveCount)
                    let nextX = start.x + dx * nextT
                    let nextY = start.y + dy * nextT
                    let nextWave = sin(nextT * .pi * CGFloat(waveCount) * 2) * amplitude
                    let nextPoint = CGPoint(
                        x: nextX + perpX * nextWave,
                        y: nextY + perpY * nextWave
                    )
                    path.addQuadCurve(to: nextPoint, control: controlPoint)
                }
            }
        } else {
            path.addLine(to: end)
        }

        return path
    }
}

// MARK: - Node UI (نفس شكل دائرتك القديم)

struct WireNodeCircle: View {
    let color: Color
    let isActive: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 56, height: 56)

            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 70, height: 70)
                .blur(radius: 5)
            
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)

        }
      
    }
}

// MARK: - ViewModel (تايمر + ربط الفوز)

final class WiringGameViewModel: ObservableObject {
    @Published var isComplete = false
    @Published var hasFailed = false
    @Published var timeRemaining: Double = 8.0

    let gameState: WiringGameState

    private var timer: Timer?
    var timeLimit: Double = 8.0

    init(timeLimit: Double = 8.0) {
        self.timeLimit = timeLimit
        self.gameState = WiringGameState()
        startTimer()

        // مراقبة الفوز من GameState
        gameState.onWin = { [weak self] in
            self?.isComplete = true
            self?.stopTimer()
        }
    }

    deinit { stopTimer() }

    private func startTimer() {
        timeRemaining = timeLimit
        hasFailed = false
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }

            if self.timeRemaining > 0 && !self.isComplete {
                self.timeRemaining -= 0.1
            } else if self.timeRemaining <= 0 && !self.isComplete {
                self.hasFailed = true
                self.stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Game Logic (نفس لعبتك الثانية لكن بألواننا)

struct WiringCircle: Identifiable {
    let id = UUID()
    let color: Color
    let position: CGPoint
    let pairId: Int
}

struct WiringLine: Identifiable {
    let id = UUID()
    let color: Color
    let startPoint: CGPoint
    var endPoint: CGPoint
    let startCircleId: UUID
    var endCircleId: UUID?
    let pairId: Int
}

final class WiringGameState: ObservableObject {
    @Published var circles: [WiringCircle] = []
    @Published var lines: [WiringLine] = []
    @Published var currentLine: WiringLine?

    var onWin: (() -> Void)?

    private var dragStartCircle: WiringCircle?
    private let circleRadius: CGFloat = 25

    init() {
        setupGame()
    }

    func setupGame() {
        // نفس ألوانكم بالضبط (WireColor) + نحافظ على pairId بالترتيب
        let colors: [Color] = [
            WireColor.red.color,    // 0
            WireColor.green.color,  // 1
            WireColor.blue.color,   // 2
            WireColor.yellow.color, // 3
            WireColor.pink.color    // 4
        ]

        let ys: [CGFloat] = [80, 170, 260, 350, 440]

        // العمود الأيسر ثابت
        var left: [WiringCircle] = []
        for i in 0..<colors.count {
            left.append(
                WiringCircle(
                    color: colors[i],
                    position: CGPoint(x: 60, y: ys[i]),
                    pairId: i
                )
            )
        }

        // العمود الأيمن: نفس الألوان لكن ترتيب عشوائي (pairId يبقى صحيح)
        let rightOrder = Array(0..<colors.count).shuffled()

        var right: [WiringCircle] = []
        for row in 0..<rightOrder.count {
            let pairId = rightOrder[row]
            right.append(
                WiringCircle(
                    color: colors[pairId],
                    position: CGPoint(x:280, y: ys[row]),
                    pairId: pairId
                )
            )
        }

        circles = left + right
    }

    func isCircleActive(_ circle: WiringCircle) -> Bool {
        dragStartCircle?.id == circle.id
    }

    private func findCircleAt(location: CGPoint) -> WiringCircle? {
        circles.first { circle in
            let dx = circle.position.x - location.x
            let dy = circle.position.y - location.y
            return sqrt(dx*dx + dy*dy) <= circleRadius
        }
    }

    func handleDragChanged(location: CGPoint) {
        if dragStartCircle == nil {
            if let circle = findCircleAt(location: location) {
                dragStartCircle = circle

                // نفس لعبتك: حذف الخط القديم لنفس اللون
                lines.removeAll { $0.pairId == circle.pairId }

                currentLine = WiringLine(
                    color: circle.color,
                    startPoint: circle.position,
                    endPoint: location,
                    startCircleId: circle.id,
                    endCircleId: nil,
                    pairId: circle.pairId
                )
            }
        } else {
            if var line = currentLine {
                line.endPoint = location
                currentLine = line
            }
        }
    }

    func handleDragEnded(location: CGPoint) {
        guard let startCircle = dragStartCircle else { return }

        if let endCircle = findCircleAt(location: location) {
            if endCircle.pairId == startCircle.pairId && endCircle.id != startCircle.id {
                if var line = currentLine {
                    line.endPoint = endCircle.position
                    line.endCircleId = endCircle.id
                    lines.append(line)
                    checkWinCondition()
                }
            }
        }

        currentLine = nil
        dragStartCircle = nil
    }

    private func checkWinCondition() {
        let completedLines = lines.filter { $0.endCircleId != nil }
        if completedLines.count == 5 {
            onWin?()
        }
    }

    func resetGame() {
        lines.removeAll()
        currentLine = nil
        dragStartCircle = nil
        setupGame()
    }
}

// MARK: - WireColor (نفس كودك)

struct WireColor: Identifiable, Equatable {
    let id = UUID()
    let color: Color
    let name: String

    static let red = WireColor(color: .red, name: "red")
    static let blue = WireColor(color: .blue, name: "blue")
    static let yellow = WireColor(color: .yellow, name: "yellow")
    static let pink = WireColor(color: Color(red: 1.0, green: 0.0, blue: 1.0), name: "pink")
    static let green = WireColor(color: .green, name: "green")

    static func == (lhs: WireColor, rhs: WireColor) -> Bool {
        lhs.name == rhs.name
    }
}

// MARK: - Preview

#Preview("PuzzleWiringView") {
    PuzzleWiringView(timeLimit: 8) { success, timeSeconds, didTimeout in
        print("Finished:", success, timeSeconds, didTimeout)
    }
}
