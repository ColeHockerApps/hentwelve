import Foundation
import Combine
import CoreGraphics

@MainActor
final class HenParticleFX: ObservableObject {

    struct Spark: Identifiable, Hashable {
        let id: UUID
        var position: CGPoint
        var velocity: CGVector
        var life: Double
        var age: Double
        var size: CGFloat
        var kind: Kind

        enum Kind: Int, Hashable {
            case dust
            case pop
            case streak
        }

        init(
            id: UUID = UUID(),
            position: CGPoint,
            velocity: CGVector,
            life: Double,
            size: CGFloat,
            kind: Kind
        ) {
            self.id = id
            self.position = position
            self.velocity = velocity
            self.life = life
            self.age = 0
            self.size = size
            self.kind = kind
        }

        var t: Double {
            guard life > 0.0001 else { return 1 }
            return min(1, max(0, age / life))
        }

        var isAlive: Bool {
            age < life
        }
    }

    @Published private(set) var sparks: [Spark] = []

    private var lastUpdate: TimeInterval = 0
    private var carry: Double = 0

    init() {}

    func clear() {
        sparks.removeAll()
        lastUpdate = 0
        carry = 0
    }

    func spawnMerge(at point: CGPoint, strength: Int) {
        let n = max(10, min(42, 10 + strength * 6))
        for i in 0..<n {
            let a = (Double(i) / Double(n)) * Double.pi * 2
            let r = 0.6 + (Double(i % 7) / 7.0) * 0.9
            let sp = 120.0 + r * 220.0 + Double(strength) * 18.0
            let v = CGVector(dx: cos(a) * sp, dy: sin(a) * sp)
            let life = 0.32 + r * 0.36
            let size = CGFloat(2.2 + r * 2.8)
            sparks.append(
                Spark(position: point, velocity: v, life: life, size: size, kind: (i % 4 == 0 ? .pop : .dust))
            )
        }
    }

    func spawnBump(at point: CGPoint, direction: CGVector) {
        let dir = normalize(direction)
        let base = CGVector(dx: dir.dx * 160, dy: dir.dy * 160)
        let n = 14
        for i in 0..<n {
            let jitter = 0.55 + Double(i % 5) * 0.1
            let v = CGVector(
                dx: base.dx * jitter + CGFloat.random(in: -55...55),
                dy: base.dy * jitter + CGFloat.random(in: -55...55)
            )
            sparks.append(
                Spark(
                    position: point,
                    velocity: v,
                    life: Double.random(in: 0.22...0.42),
                    size: CGFloat.random(in: 1.8...3.4),
                    kind: .streak
                )
            )
        }
    }

    func tick(now: TimeInterval) {
        if lastUpdate == 0 {
            lastUpdate = now
            return
        }

        var dt = now - lastUpdate
        lastUpdate = now

        if dt <= 0 { return }
        dt = min(dt, 1.0 / 15.0)

        carry += dt
        let step = 1.0 / 60.0
        while carry >= step {
            integrate(dt: step)
            carry -= step
        }
    }

    private func integrate(dt: Double) {
        guard sparks.isEmpty == false else { return }

        let g: CGFloat = 520
        for i in sparks.indices {
            var s = sparks[i]
            s.age += dt

            let drag: CGFloat
            switch s.kind {
            case .dust: drag = 0.90
            case .pop: drag = 0.86
            case .streak: drag = 0.80
            }

            s.velocity.dx *= drag
            s.velocity.dy *= drag
            s.velocity.dy += g * CGFloat(dt)

            s.position.x += s.velocity.dx * CGFloat(dt)
            s.position.y += s.velocity.dy * CGFloat(dt)

            sparks[i] = s
        }

        sparks.removeAll(where: { $0.isAlive == false })
    }

    private func normalize(_ v: CGVector) -> CGVector {
        let len = sqrt(v.dx * v.dx + v.dy * v.dy)
        if len < 0.00001 { return .zero }
        return CGVector(dx: v.dx / len, dy: v.dy / len)
    }
}
