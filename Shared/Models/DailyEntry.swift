import Foundation
import SwiftData

@Model
final class DailyEntry {
    @Attribute(.unique) var compoundKey: String
    var id: UUID
    var dayKey: String
    var routineKey: String
    var intent: String
    var affirmation: String?
    var quoteText: String?
    var quoteAuthor: String?
    var gratitudeItems: [String]
    var priorities: [String]
    var journal: String?
    var mindfulnessMinutes: Int
    var statusRaw: String
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?

    var status: EntryStatus {
        get { EntryStatus(rawValue: statusRaw) ?? .empty }
        set { statusRaw = newValue.rawValue }
    }

    init(
        dayKey: String,
        routineKey: String = RoutineKey.daily,
        intent: String = "",
        affirmation: String? = nil,
        quoteText: String? = nil,
        quoteAuthor: String? = nil,
        gratitudeItems: [String] = [],
        priorities: [String] = [],
        journal: String? = nil,
        mindfulnessMinutes: Int = 0,
        status: EntryStatus = .empty,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = UUID()
        self.dayKey = dayKey
        self.routineKey = routineKey
        self.compoundKey = "\(dayKey)|\(routineKey)"
        self.intent = intent
        self.affirmation = affirmation
        self.quoteText = quoteText
        self.quoteAuthor = quoteAuthor
        self.gratitudeItems = gratitudeItems
        self.priorities = priorities
        self.journal = journal
        self.mindfulnessMinutes = mindfulnessMinutes
        self.statusRaw = status.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
    }

    func touchUpdated() {
        updatedAt = Date()
    }
}
