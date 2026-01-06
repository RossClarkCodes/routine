import Observation

@Observable
final class AppState {
    var launchContext: AppLaunchContext = .today
    var flowState: RoutineFlowState = .idle

    func updateFlow(for entry: DailyEntry?) {
        guard let entry else {
            flowState = .idle
            return
        }
        switch entry.status {
        case .completed:
            flowState = .completed
        case .inProgress, .empty:
            let step = TodaySnapshot.from(entry).currentStep
            flowState = .inProgress(step: step)
        }
    }
}
