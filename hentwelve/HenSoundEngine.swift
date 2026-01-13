import SwiftUI
import Combine
import AVFoundation

@MainActor
final class HenSoundEngine: ObservableObject {

    static let shared = HenSoundEngine()

    enum Sfx: String {
        case tap
        case soft
        case pop
        case success
        case fail
    }

    @Published var isEnabled: Bool = true

    private let keyEnabled = "hen.audio.enabled"
    private var players: [Sfx: AVAudioPlayer] = [:]
    private var sessionConfigured: Bool = false

    private init() {
        isEnabled = UserDefaults.standard.object(forKey: keyEnabled) as? Bool ?? true
    }

    func setEnabled(_ value: Bool) {
        isEnabled = value
        UserDefaults.standard.set(value, forKey: keyEnabled)
        if value {
            Task { @MainActor in
                self.configureSessionIfNeeded()
            }
        }
    }

    func warmUp() {
        configureSessionIfNeeded()
        loadIfNeeded(.tap)
        loadIfNeeded(.soft)
        loadIfNeeded(.pop)
        loadIfNeeded(.success)
        loadIfNeeded(.fail)
    }

    func play(_ sfx: Sfx, volume: Float = 0.9) {
        guard isEnabled else { return }
        configureSessionIfNeeded()

        let player = loadIfNeeded(sfx)
        player?.volume = max(0.0, min(1.0, volume))
        player?.currentTime = 0
        player?.play()
    }

    func stopAll() {
        for (_, p) in players {
            p.stop()
        }
    }

    private func configureSessionIfNeeded() {
        guard sessionConfigured == false else { return }
        sessionConfigured = true

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true, options: [])
        } catch {
            sessionConfigured = false
        }
    }

    @discardableResult
    private func loadIfNeeded(_ sfx: Sfx) -> AVAudioPlayer? {
        if let p = players[sfx] {
            return p
        }

        guard let url = Bundle.main.url(forResource: sfx.rawValue, withExtension: "wav")
            ?? Bundle.main.url(forResource: sfx.rawValue, withExtension: "mp3")
            ?? Bundle.main.url(forResource: sfx.rawValue, withExtension: "m4a")
        else {
            return nil
        }

        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = 0
            p.prepareToPlay()
            players[sfx] = p
            return p
        } catch {
            return nil
        }
    }
}
