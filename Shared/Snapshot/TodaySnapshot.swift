import Foundation

enum TodayStatus: String, Codable {
    case ready
    case inProgress
    case completed
}

struct TodaySnapshot: Codable, Equatable {
    var dayKey: String
    var routineKey: String
    var status: TodayStatus
    var intentPreview: String
    var quotePreview: String?
    var completedAt: Date?
    var currentStep: RoutineStep

    static func empty(for dayKey: String, routineKey: String = RoutineKey.daily) -> TodaySnapshot {
        TodaySnapshot(
            dayKey: dayKey,
            routineKey: routineKey,
            status: .ready,
            intentPreview: "",
            quotePreview: nil,
            completedAt: nil,
            currentStep: .intent
        )
    }

    static func from(_ entry: DailyEntry) -> TodaySnapshot {
        let status: TodayStatus
        switch entry.status {
        case .empty:
            status = .ready
        case .inProgress:
            status = .inProgress
        case .completed:
            status = .completed
        }

        let step: RoutineStep
        if entry.status == .completed {
            step = .complete
        } else if entry.intent.isEmpty {
            step = .intent
        } else if entry.gratitudeItems.isEmpty {
            step = .gratitude
        } else if entry.priorities.isEmpty {
            step = .priorities
        } else {
            step = .complete
        }

        return TodaySnapshot(
            dayKey: entry.dayKey,
            routineKey: entry.routineKey,
            status: status,
            intentPreview: entry.intent,
            quotePreview: entry.quoteText,
            completedAt: entry.completedAt,
            currentStep: step
        )
    }
}
