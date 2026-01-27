import SwiftUI
import SpriteKit

// MARK: - App Entry
@main
struct StepGameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - SwiftUI View
struct ContentView: View {
    private var scene: SKScene {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

// MARK: - SpriteKit Scene
final class GameScene: SKScene {

    private var player: SKShapeNode!
    private var checkpoints: [CGPoint] = []
    private var currentIndex = 0

    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupCheckpoints()
        drawPath()
        drawCheckpoints()
        setupPlayer()
    }

    // MARK: Setup

    private func setupCheckpoints() {
        let midX = size.width / 2
        let midY = size.height / 2

        checkpoints = [
            CGPoint(x: midX - 120, y: midY - 200),
            CGPoint(x: midX + 100, y: midY - 120),
            CGPoint(x: midX - 80,  y: midY),
            CGPoint(x: midX + 120, y: midY + 140),
            CGPoint(x: midX - 40,  y: midY + 240)
        ]
    }

    private func setupPlayer() {
        player = SKShapeNode(circleOfRadius: 18)
        player.fillColor = .systemBlue
        player.strokeColor = .clear
        player.position = checkpoints.first ?? .zero
        addChild(player)
    }

    // MARK: Drawing

    private func drawCheckpoints() {
        for point in checkpoints {
            let node = SKShapeNode(circleOfRadius: 10)
            node.position = point
            node.fillColor = .lightGray
            node.strokeColor = .clear
            addChild(node)
        }
    }

    private func drawPath() {
        guard checkpoints.count > 1 else { return }

        let path = CGMutablePath()
        path.move(to: checkpoints[0])
        for p in checkpoints.dropFirst() {
            path.addLine(to: p)
        }

        let line = SKShapeNode(path: path)
        line.strokeColor = .gray
        line.lineWidth = 6
        line.alpha = 0.35
        addChild(line)
    }

    // MARK: Interaction

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveToNextCheckpoint()
    }

    private func moveToNextCheckpoint() {
        guard currentIndex < checkpoints.count - 1 else { return }

        currentIndex += 1
        let target = checkpoints[currentIndex]

        let move = SKAction.move(to: target, duration: 0.35)
        move.timingMode = .easeInEaseOut

        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.12),
            SKAction.scale(to: 1.0, duration: 0.12)
        ])

        player.run(SKAction.group([move, bounce]))
    }
}

#Preview {
    ContentView()
}
