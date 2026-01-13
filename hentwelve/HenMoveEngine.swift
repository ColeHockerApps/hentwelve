import Foundation
import Combine

@MainActor
final class HenMoveEngine: ObservableObject {

    enum Move: CaseIterable {
        case up
        case down
        case left
        case right
    }

    struct StepResult: Equatable {
        var moved: Bool
        var scoreGained: Int
        var mergeCount: Int
        var didSpawn: Bool
        var spawnedIndex: Int?
        var spawnedValue: Int?
        var grid: [Int]
    }

    @Published private(set) var grid: [Int]
    @Published private(set) var score: Int = 0
    @Published private(set) var bestTile: Int = 0
    @Published private(set) var isGameOver: Bool = false

    private let size: Int
    private let spawner: HenTileSpawner
    private let resolver: HenMergeResolver

    init(size: Int = 4) {
        let s = max(2, size)
        self.size = s
        self.spawner = HenTileSpawner()
        self.resolver = HenMergeResolver()
        self.grid = Array(repeating: 0, count: s * s)

        reset()
    }

    func reset() {
        score = 0
        bestTile = 0
        isGameOver = false
        grid = Array(repeating: 0, count: size * size)
        resolver.reset()
        spawner.reset()
        seedIfNeeded()
        recalcStats()
        isGameOver = !resolver.canMove(grid)
    }

    func apply(_ move: Move) -> StepResult {
        if isGameOver {
            return StepResult(
                moved: false,
                scoreGained: 0,
                mergeCount: 0,
                didSpawn: false,
                spawnedIndex: nil,
                spawnedValue: nil,
                grid: grid
            )
        }

        let mapped = mapMove(move)
        let merge = resolver.apply(move: mapped, to: grid, size: size)

        var outGrid = merge.grid
        var didSpawn = false
        var spawnedIndex: Int? = nil
        var spawnedValue: Int? = nil

//        if merge.moved {
//            if let spawn = spawner.spawn(into: &outGrid, size: size) {
//                didSpawn = true
//                spawnedIndex = spawn.index
//                spawnedValue = spawn.value
//            }
//        }

        grid = outGrid
        score += merge.scoreGained
        recalcStats()
        isGameOver = !resolver.canMove(grid)

        return StepResult(
            moved: merge.moved,
            scoreGained: merge.scoreGained,
            mergeCount: merge.mergeCount,
            didSpawn: didSpawn,
            spawnedIndex: spawnedIndex,
            spawnedValue: spawnedValue,
            grid: outGrid
        )
    }

    func valueAt(row: Int, col: Int) -> Int {
        let r = max(0, min(size - 1, row))
        let c = max(0, min(size - 1, col))
        return grid[r * size + c]
    }

    func indexToRowCol(_ index: Int) -> (row: Int, col: Int) {
        let i = max(0, min(grid.count - 1, index))
        return (i / size, i % size)
    }

    private func seedIfNeeded() {
//        _ = spawner.spawn(into: &grid, size: size)
//        _ = spawner.spawn(into: &grid, size: size)
    }

    private func recalcStats() {
        var maxV = 0
        for v in grid {
            if v > maxV { maxV = v }
        }
        bestTile = maxV
    }

    private func mapMove(_ move: Move) -> HenMergeResolver.Move {
        switch move {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        }
    }
}
