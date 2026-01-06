import AppIntents
import Foundation

struct StartMyDayIntent: AppIntent {
    @MainActor static var title: LocalizedStringResource { "Start My Day" }
    @MainActor static var description: IntentDescription { IntentDescription("Begin the daily routine.") }

    func perform() async throws -> some IntentResult {
        _ = try await RoutineEngine.shared.startDay()
        return .result()
    }
}

struct ShowTodayIntent: AppIntent {
    @MainActor static var title: LocalizedStringResource { "Show Today" }
    @MainActor static var description: IntentDescription { IntentDescription("Open the Today screen.") }
    @MainActor static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct SetTodaysIntentIntent: AppIntent {
    @MainActor static var title: LocalizedStringResource { "Set Today’s Intent" }
    @MainActor static var description: IntentDescription { IntentDescription("Save your daily intent.") }

    @Parameter(title: "Intent")
    var text: String

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.setIntent(text)
        return .result()
    }
}

struct AddGratitudeIntent: AppIntent {
    @MainActor static var title: LocalizedStringResource { "Add Gratitude" }
    @MainActor static var description: IntentDescription { IntentDescription("Add a gratitude item.") }
    @MainActor static var openAppWhenRun: Bool { true }

    @Parameter(title: "Gratitude")
    var text: String

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.addGratitude(text)
        return .result()
    }
}

struct AddPriorityIntent: AppIntent {
    @MainActor static var title: LocalizedStringResource { "Add Priority" }
    @MainActor static var description: IntentDescription { IntentDescription("Add a top priority.") }
    @MainActor static var openAppWhenRun: Bool { true }

    @Parameter(title: "Priority")
    var text: String

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.addPriority(text)
        return .result()
    }
}

struct BeginBreathworkIntent: AppIntent {
    @MainActor static var title: LocalizedStringResource { "Begin Breathwork" }
    @MainActor static var description: IntentDescription { IntentDescription("Log a brief breathwork session.") }

    @Parameter(title: "Minutes", default: 1)
    var durationMinutes: Int

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.beginBreathwork(minutes: durationMinutes)
        return .result()
    }
}

struct CompleteRoutineIntent: AppIntent {
    @MainActor static var title: LocalizedStringResource { "Complete Routine" }
    @MainActor static var description: IntentDescription { IntentDescription("Complete today’s routine.") }

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.complete()
        return .result()
    }
}

struct SkipTodayIntent: AppIntent {
    @MainActor static var title: LocalizedStringResource { "Skip Today" }
    @MainActor static var description: IntentDescription { IntentDescription("Skip today’s routine.") }

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.skipToday()
        return .result()
    }
}
