import AppIntents
import Foundation

struct StartMyDayIntent: AppIntent {
    static var title: LocalizedStringResource = "Start My Day"
    static var description = IntentDescription("Begin the daily routine.")

    func perform() async throws -> some IntentResult {
        _ = try await RoutineEngine.shared.startDay()
        return .result()
    }
}

struct ShowTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Today"
    static var description = IntentDescription("Open the Today screen.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct SetTodaysIntentIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Today’s Intent"
    static var description = IntentDescription("Save your daily intent.")

    @Parameter(title: "Intent")
    var text: String

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.setIntent(text)
        return .result()
    }
}

struct AddGratitudeIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Gratitude"
    static var description = IntentDescription("Add a gratitude item.")
    static var openAppWhenRun = true

    @Parameter(title: "Gratitude")
    var text: String

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.addGratitude(text)
        return .result()
    }
}

struct AddPriorityIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Priority"
    static var description = IntentDescription("Add a top priority.")
    static var openAppWhenRun = true

    @Parameter(title: "Priority")
    var text: String

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.addPriority(text)
        return .result()
    }
}

struct BeginBreathworkIntent: AppIntent {
    static var title: LocalizedStringResource = "Begin Breathwork"
    static var description = IntentDescription("Log a brief breathwork session.")

    @Parameter(title: "Minutes", default: 1)
    var durationMinutes: Int

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.beginBreathwork(minutes: durationMinutes)
        return .result()
    }
}

struct CompleteRoutineIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Routine"
    static var description = IntentDescription("Complete today’s routine.")

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.complete()
        return .result()
    }
}

struct SkipTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Skip Today"
    static var description = IntentDescription("Skip today’s routine.")

    func perform() async throws -> some IntentResult {
        try await RoutineEngine.shared.skipToday()
        return .result()
    }
}
