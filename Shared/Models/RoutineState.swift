import Foundation

enum EntryStatus: String, Codable, CaseIterable {
    case empty
    case inProgress
    case completed
}

enum RoutineStep: String, Codable, CaseIterable {
    case intent
    case gratitude
    case priorities
    case complete
}

enum AppLaunchContext: Equatable {
    case today
    case addIntent
    case addGratitude
    case addPriority
    case breathwork
    case review(dayKey: String)
    case settings
}

enum RoutineFlowState: Equatable {
    case idle
    case inProgress(step: RoutineStep)
    case completed
}
