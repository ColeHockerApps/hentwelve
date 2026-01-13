import Foundation
import Combine

@MainActor
final class HenScoreTracker: ObservableObject {

    @Published private(set) var score: Int = 0
    @Published private(set) var bestScore: Int = 0
    @Published private(set) var bestTile: Int = 0

    @Published private(set) var lastGain: Int = 0
    @Published private(set) var lastMergeCount: Int = 0

    private let bestScoreKey = "hen.score.best"
    private let bestTileKey = "hen.tile.best"

    init() {
        let d = UserDefaults.standard
        bestScore = d.integer(forKey: bestScoreKey)
        bestTile = d.integer(forKey: bestTileKey)
    }

    func resetRun() {
        score = 0
        lastGain = 0
        lastMergeCount = 0
    }

    func applyTurn(gain: Int, mergeCount: Int, maxTileAfterTurn: Int) {
        lastGain = max(0, gain)
        lastMergeCount = max(0, mergeCount)

        score += lastGain
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: bestScoreKey)
        }

        if maxTileAfterTurn > bestTile {
            bestTile = maxTileAfterTurn
            UserDefaults.standard.set(bestTile, forKey: bestTileKey)
        }
    }

    func forceBest(score: Int, tile: Int) {
        bestScore = max(0, score)
        bestTile = max(0, tile)
        UserDefaults.standard.set(bestScore, forKey: bestScoreKey)
        UserDefaults.standard.set(bestTile, forKey: bestTileKey)
    }
}
