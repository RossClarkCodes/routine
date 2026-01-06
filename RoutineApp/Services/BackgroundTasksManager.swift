import BackgroundTasks
import Foundation

@MainActor
enum BackgroundTasksManager {
    private static let taskIdentifier = "com.rossclark.routine.prewarm"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handle(refreshTask)
        }
    }

    static func schedulePrewarm() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handle(_ task: BGAppRefreshTask) {
        schedulePrewarm()
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        Task {
            _ = try? await RoutineEngine.shared.entryForToday()
            task.setTaskCompleted(success: true)
        }
    }
}
