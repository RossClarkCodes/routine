import CoreHaptics
import Foundation
import UIKit

enum HapticPattern {
    case routineStart
    case stepAdvance
    case complete
    case error
}

final class HapticsService {
    static let shared = HapticsService()
    private var engine: CHHapticEngine?

    private init() {
        prepareEngine()
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
        try? engine?.start()
    }

    func play(_ pattern: HapticPattern) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            fallback(pattern)
            return
        }
        do {
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity(for: pattern)),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness(for: pattern))
            ], relativeTime: 0)
            let hapticPattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: hapticPattern)
            try player?.start(atTime: 0)
        } catch {
            fallback(pattern)
        }
    }

    private func intensity(for pattern: HapticPattern) -> Float {
        switch pattern {
        case .routineStart: return 0.6
        case .stepAdvance: return 0.4
        case .complete: return 0.8
        case .error: return 0.3
        }
    }

    private func sharpness(for pattern: HapticPattern) -> Float {
        switch pattern {
        case .routineStart: return 0.5
        case .stepAdvance: return 0.4
        case .complete: return 0.7
        case .error: return 0.2
        }
    }

    private func fallback(_ pattern: HapticPattern) {
        let generator = UINotificationFeedbackGenerator()
        switch pattern {
        case .complete:
            generator.notificationOccurred(.success)
        case .error:
            generator.notificationOccurred(.error)
        default:
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
}
