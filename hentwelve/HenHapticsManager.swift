import SwiftUI
import Combine
import UIKit

@MainActor
final class HenHapticsManager: ObservableObject {

    static let shared = HenHapticsManager()

    @Published var isEnabled: Bool = true

    private let keyEnabled = "hen.haptics.enabled"

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notify = UINotificationFeedbackGenerator()

    private init() {
        isEnabled = UserDefaults.standard.object(forKey: keyEnabled) as? Bool ?? true
        prepareAll()
    }

    func setEnabled(_ value: Bool) {
        isEnabled = value
        UserDefaults.standard.set(value, forKey: keyEnabled)
        if value { prepareAll() }
    }

    func prepareAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selection.prepare()
        notify.prepare()
    }

    func tapLight() {
        guard isEnabled else { return }
        impactLight.impactOccurred(intensity: 0.75)
        impactLight.prepare()
    }

    func tapMedium() {
        guard isEnabled else { return }
        impactMedium.impactOccurred(intensity: 0.85)
        impactMedium.prepare()
    }

    func tapHeavy() {
        guard isEnabled else { return }
        impactHeavy.impactOccurred(intensity: 0.95)
        impactHeavy.prepare()
    }

    func select() {
        guard isEnabled else { return }
        selection.selectionChanged()
        selection.prepare()
    }

    func success() {
        guard isEnabled else { return }
        notify.notificationOccurred(.success)
        notify.prepare()
    }

    func warning() {
        guard isEnabled else { return }
        notify.notificationOccurred(.warning)
        notify.prepare()
    }

    func error() {
        guard isEnabled else { return }
        notify.notificationOccurred(.error)
        notify.prepare()
    }
}
