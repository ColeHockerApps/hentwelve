import Foundation
import Combine

@MainActor
final class HenTileSpawner: ObservableObject {

    struct Spawn: Equatable, Hashable, Identifiable {
        let id: UUID
        let index: Int
        let value: Int

        init(index: Int, value: Int) {
            self.id = UUID()
            self.index = index
            self.value = value
        }
    }

    @Published private(set) var lastSpawn: Spawn? = nil

    private var seed: UInt64 = 0xC0FFEE
    private var useSystemRandom: Bool = true

    init() {}

    func configureDeterministic(seed: UInt64) {
        self.seed = seed == 0 ? 1 : seed
        self.useSystemRandom = false
    }

    func configureSystemRandom() {
        self.useSystemRandom = true
    }

    func reset() {
        lastSpawn = nil
    }

    func spawnIndex(empty: [Int], preferCorners: Bool = false) -> Int? {
        guard empty.isEmpty == false else { return nil }

        if preferCorners {
            let corners = [0, 3, 12, 15]
            let availableCorners = corners.filter { empty.contains($0) }
            if availableCorners.isEmpty == false {
                return pick(from: availableCorners)
            }
        }

        return pick(from: empty)
    }

    func spawnValue(twoChance: Double = 0.90) -> Int {
        let p = clamp01(twoChance)
        let r = nextUnit()
        return r < p ? 2 : 4
    }

    func spawn(empty: [Int], twoChance: Double = 0.90, preferCorners: Bool = false) -> Spawn? {
        guard let idx = spawnIndex(empty: empty, preferCorners: preferCorners) else { return nil }
        let val = spawnValue(twoChance: twoChance)
        let s = Spawn(index: idx, value: val)
        lastSpawn = s
        return s
    }

    func clearLast() {
        lastSpawn = nil
    }

    private func pick(from list: [Int]) -> Int {
        if list.count == 1 { return list[0] }
        let r = nextInt(upperBound: list.count)
        return list[r]
    }

    private func nextUnit() -> Double {
        if useSystemRandom {
            return Double.random(in: 0..<1)
        }
        let x = nextUInt32Deterministic()
        return Double(x) / Double(UInt32.max)
    }

    private func nextInt(upperBound: Int) -> Int {
        if upperBound <= 1 { return 0 }
        if useSystemRandom {
            return Int.random(in: 0..<upperBound)
        }
        let x = nextUInt32Deterministic()
        return Int(x % UInt32(upperBound))
    }

    private func nextUInt32Deterministic() -> UInt32 {
        seed = 2862933555777941757 &* seed &+ 3037000493
        let x = UInt32(truncatingIfNeeded: (seed >> 16) ^ seed)
        return x
    }

    private func clamp01(_ v: Double) -> Double {
        if v < 0 { return 0 }
        if v > 1 { return 1 }
        return v
    }
}
