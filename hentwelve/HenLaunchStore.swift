import Foundation
import Combine
import UIKit

@MainActor
final class HenLaunchStore: ObservableObject {

    @Published var playPoint: URL
    @Published var privacyPoint: URL

    private let playKey = "hen.play"
    private let privacyKey = "hen.privacy"
    private let resumeKey = "hen.resume"
    private let marksKey = "hen.marks"

    private var didStoreResume = false

    init() {
        let defaults = UserDefaults.standard

        let defaultPlay = "https://yaramazapps.github.io/gettwelve/"
        let defaultPrivacy = "https://yaramazapps.github.io/terms-games"

        if let saved = defaults.string(forKey: playKey),
           let v = URL(string: saved) {
            playPoint = v
        } else {
            playPoint = URL(string: defaultPlay)!
        }

        if let saved = defaults.string(forKey: privacyKey),
           let v = URL(string: saved) {
            privacyPoint = v
        } else {
            privacyPoint = URL(string: defaultPrivacy)!
        }
    }

    func updatePlay(_ value: String) {
        guard let v = URL(string: value) else { return }
        playPoint = v
        UserDefaults.standard.set(value, forKey: playKey)
    }

    func updatePrivacy(_ value: String) {
        guard let v = URL(string: value) else { return }
        privacyPoint = v
        UserDefaults.standard.set(value, forKey: privacyKey)
    }

    func storeResumeIfNeeded(_ point: URL) {
        guard didStoreResume == false else { return }
        didStoreResume = true

        let defaults = UserDefaults.standard
        if defaults.string(forKey: resumeKey) != nil { return }
        defaults.set(point.absoluteString, forKey: resumeKey)
    }

    func restoreResume() -> URL? {
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: resumeKey),
           let v = URL(string: saved) {
            return v
        }
        return nil
    }

    func saveMarks(_ items: [[String: Any]]) {
        UserDefaults.standard.set(items, forKey: marksKey)
    }

    func loadMarks() -> [[String: Any]]? {
        UserDefaults.standard.array(forKey: marksKey) as? [[String: Any]]
    }

    func resetAll() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: playKey)
        defaults.removeObject(forKey: privacyKey)
        defaults.removeObject(forKey: resumeKey)
        defaults.removeObject(forKey: marksKey)
        didStoreResume = false

        playPoint = URL(string: "https://yaramazapps.github.io/gettwelve/")!
        privacyPoint = URL(string: "https://yaramazapps.github.io/terms-games")!
    }
}
