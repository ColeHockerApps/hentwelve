import Foundation
import Combine

@MainActor
final class HenMergeResolver: ObservableObject {

    enum Move: CaseIterable {
        case up
        case down
        case left
        case right
    }

    struct Result: Equatable {
        var moved: Bool
        var scoreGained: Int
        var mergeCount: Int
        var grid: [Int]
    }

    @Published private(set) var lastResult: Result? = nil

    init() {}

    func reset() {
        lastResult = nil
    }

    func canMove(_ grid: [Int]) -> Bool {
        if grid.contains(0) { return true }
        return hasMergeOpportunity(grid)
    }

    func apply(move: Move, to grid: [Int], size: Int = 4) -> Result {
        let normalized = normalizeGrid(grid, size: size)
        var out = normalized
        var moved = false
        var score = 0
        var merges = 0

        switch move {
        case .left:
            for r in 0..<size {
                let line = readRow(out, row: r, size: size)
                let (newLine, didMove, gained, mergeCount) = compressAndMerge(line)
                if didMove { moved = true }
                score += gained
                merges += mergeCount
                writeRow(&out, row: r, size: size, values: newLine)
            }

        case .right:
            for r in 0..<size {
                let line = readRow(out, row: r, size: size).reversed()
                let (merged, didMove, gained, mergeCount) = compressAndMerge(Array(line))
                let newLine = merged.reversed()
                if didMove { moved = true }
                score += gained
                merges += mergeCount
                writeRow(&out, row: r, size: size, values: Array(newLine))
            }

        case .up:
            for c in 0..<size {
                let line = readCol(out, col: c, size: size)
                let (newLine, didMove, gained, mergeCount) = compressAndMerge(line)
                if didMove { moved = true }
                score += gained
                merges += mergeCount
                writeCol(&out, col: c, size: size, values: newLine)
            }

        case .down:
            for c in 0..<size {
                let line = readCol(out, col: c, size: size).reversed()
                let (merged, didMove, gained, mergeCount) = compressAndMerge(Array(line))
                let newLine = merged.reversed()
                if didMove { moved = true }
                score += gained
                merges += mergeCount
                writeCol(&out, col: c, size: size, values: Array(newLine))
            }
        }

        let res = Result(moved: moved, scoreGained: score, mergeCount: merges, grid: out)
        lastResult = res
        return res
    }

    private func compressAndMerge(_ line: [Int]) -> ([Int], Bool, Int, Int) {
        let original = line
        var compact: [Int] = original.filter { $0 != 0 }

        var score = 0
        var merges = 0

        var i = 0
        var merged: [Int] = []
        merged.reserveCapacity(original.count)

        while i < compact.count {
            let a = compact[i]
            if i + 1 < compact.count, compact[i + 1] == a {
                let v = a + a
                merged.append(v)
                score += v
                merges += 1
                i += 2
            } else {
                merged.append(a)
                i += 1
            }
        }

        while merged.count < original.count {
            merged.append(0)
        }

        let moved = merged != original
        return (merged, moved, score, merges)
    }

    private func hasMergeOpportunity(_ grid: [Int], size: Int = 4) -> Bool {
        let g = normalizeGrid(grid, size: size)
        for r in 0..<size {
            for c in 0..<size {
                let idx = r * size + c
                let v = g[idx]
                if v == 0 { continue }
                if c + 1 < size, g[idx + 1] == v { return true }
                if r + 1 < size, g[idx + size] == v { return true }
            }
        }
        return false
    }

    private func normalizeGrid(_ grid: [Int], size: Int) -> [Int] {
        let need = size * size
        if grid.count == need { return grid }
        if grid.count > need { return Array(grid.prefix(need)) }
        var g = grid
        g.append(contentsOf: Array(repeating: 0, count: need - g.count))
        return g
    }

    private func readRow(_ grid: [Int], row: Int, size: Int) -> [Int] {
        let start = row * size
        return Array(grid[start..<(start + size)])
    }

    private func writeRow(_ grid: inout [Int], row: Int, size: Int, values: [Int]) {
        let start = row * size
        for i in 0..<size {
            grid[start + i] = (i < values.count ? values[i] : 0)
        }
    }

    private func readCol(_ grid: [Int], col: Int, size: Int) -> [Int] {
        var out: [Int] = []
        out.reserveCapacity(size)
        for r in 0..<size {
            out.append(grid[r * size + col])
        }
        return out
    }

    private func writeCol(_ grid: inout [Int], col: Int, size: Int, values: [Int]) {
        for r in 0..<size {
            grid[r * size + col] = (r < values.count ? values[r] : 0)
        }
    }
}
