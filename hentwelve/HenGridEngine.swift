import Foundation
import Combine

@MainActor
final class HenGridEngine: ObservableObject {

    enum Direction: CaseIterable {
        case up, down, left, right
    }

    struct Tile: Identifiable, Equatable {
        let id: UUID
        var value: Int

        init(value: Int) {
            self.id = UUID()
            self.value = value
        }
    }

    struct Cell: Equatable {
        var tile: Tile?
    }

    @Published private(set) var size: Int = 4
    @Published private(set) var cells: [Cell] = []
    @Published private(set) var score: Int = 0
    @Published private(set) var bestScore: Int = 0
    @Published private(set) var isGameOver: Bool = false

    private let bestKey = "hen.grid.best"
    private var rng = SystemRandomNumberGenerator()

    init() {
        bestScore = UserDefaults.standard.integer(forKey: bestKey)
        newGame()
    }

    func newGame() {
        score = 0
        isGameOver = false
        cells = Array(repeating: Cell(tile: nil), count: size * size)
        spawnTile()
        spawnTile()
        evaluateGameOver()
    }

    func tile(atRow r: Int, col c: Int) -> Tile? {
        guard isInside(r, c) else { return nil }
        return cells[index(r, c)].tile
    }

    func setSize(_ value: Int) {
        let v = max(3, min(6, value))
        size = v
        newGame()
    }

    @discardableResult
    func move(_ dir: Direction) -> Bool {
        guard isGameOver == false else { return false }

        let before = snapshotValues()
        var gained = 0

        switch dir {
        case .left:
            for r in 0..<size { gained += compactRow(r, reversed: false) }
        case .right:
            for r in 0..<size { gained += compactRow(r, reversed: true) }
        case .up:
            for c in 0..<size { gained += compactCol(c, reversed: false) }
        case .down:
            for c in 0..<size { gained += compactCol(c, reversed: true) }
        }

        let after = snapshotValues()
        let changed = before != after

        if changed {
            score += gained
            if score > bestScore {
                bestScore = score
                UserDefaults.standard.set(bestScore, forKey: bestKey)
            }
            spawnTile()
        }

        evaluateGameOver()
        return changed
    }

    func canMove() -> Bool {
        if emptyIndices().isEmpty == false { return true }
        for r in 0..<size {
            for c in 0..<size {
                let v = cells[index(r, c)].tile?.value ?? 0
                if v == 0 { continue }
                if r + 1 < size, (cells[index(r + 1, c)].tile?.value ?? -1) == v { return true }
                if c + 1 < size, (cells[index(r, c + 1)].tile?.value ?? -1) == v { return true }
            }
        }
        return false
    }

    private func evaluateGameOver() {
        isGameOver = !canMove()
    }

    private func spawnTile() {
        let empties = emptyIndices()
        guard empties.isEmpty == false else { return }

        let pick = empties[Int.random(in: 0..<empties.count, using: &rng)]
        let value = Int.random(in: 0..<10, using: &rng) == 0 ? 4 : 2
        cells[pick].tile = Tile(value: value)
    }

    private func emptyIndices() -> [Int] {
        var out: [Int] = []
        out.reserveCapacity(size * size)
        for i in 0..<cells.count where cells[i].tile == nil {
            out.append(i)
        }
        return out
    }

    private func compactRow(_ r: Int, reversed: Bool) -> Int {
        var line: [Tile] = []
        line.reserveCapacity(size)

        let cols = reversed ? Array((0..<size).reversed()) : Array(0..<size)
        for c in cols {
            if let t = cells[index(r, c)].tile {
                line.append(t)
            }
        }

        let (merged, gained) = mergeLine(line)

        for (k, c) in cols.enumerated() {
            let idx = index(r, c)
            cells[idx].tile = (k < merged.count) ? merged[k] : nil
        }

        return gained
    }

    private func compactCol(_ c: Int, reversed: Bool) -> Int {
        var line: [Tile] = []
        line.reserveCapacity(size)

        let rows = reversed ? Array((0..<size).reversed()) : Array(0..<size)
        for r in rows {
            if let t = cells[index(r, c)].tile {
                line.append(t)
            }
        }

        let (merged, gained) = mergeLine(line)

        for (k, r) in rows.enumerated() {
            let idx = index(r, c)
            cells[idx].tile = (k < merged.count) ? merged[k] : nil
        }

        return gained
    }

    private func mergeLine(_ line: [Tile]) -> ([Tile], Int) {
        guard line.isEmpty == false else { return ([], 0) }

        var out: [Tile] = []
        out.reserveCapacity(size)

        var gained = 0
        var i = 0

        while i < line.count {
            if i + 1 < line.count, line[i].value == line[i + 1].value {
                let newValue = line[i].value * 2
                gained += newValue
                out.append(Tile(value: newValue))
                i += 2
            } else {
                out.append(line[i])
                i += 1
            }
        }

        return (out, gained)
    }

    private func snapshotValues() -> [Int] {
        cells.map { $0.tile?.value ?? 0 }
    }

    private func index(_ r: Int, _ c: Int) -> Int {
        r * size + c
    }

    private func isInside(_ r: Int, _ c: Int) -> Bool {
        r >= 0 && r < size && c >= 0 && c < size
    }
}
