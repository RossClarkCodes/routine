import WatchKit

enum WatchHapticPattern {
    case start
    case complete
    case error
}

@MainActor
enum WatchHapticsService {
    static func play(_ pattern: WatchHapticPattern) {
        let device = WKInterfaceDevice.current()
        switch pattern {
        case .start:
            device.play(.click)
        case .complete:
            device.play(.success)
        case .error:
            device.play(.failure)
        }
    }
}
