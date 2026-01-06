import Foundation

#if canImport(ActivityKit)
import ActivityKit

struct RoutineActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var step: RoutineStep
        var status: TodayStatus
    }

    var dayKey: String
    var routineKey: String
}

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<RoutineActivityAttributes>?

    func sync(with snapshot: TodaySnapshot) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        switch snapshot.status {
        case .inProgress:
            let attributes = RoutineActivityAttributes(dayKey: snapshot.dayKey, routineKey: snapshot.routineKey)
            let state = RoutineActivityAttributes.ContentState(step: snapshot.currentStep, status: snapshot.status)
            if let activity = currentActivity {
                Task { await activity.update(using: state) }
            } else {
                currentActivity = try? Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
            }
        case .completed, .ready:
            if let activity = currentActivity {
                Task { await activity.end(nil, dismissalPolicy: .immediate) }
            }
            currentActivity = nil
        }
    }
}
#else
@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    func sync(with snapshot: TodaySnapshot) { }
}
#endif
