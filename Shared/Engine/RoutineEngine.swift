import Foundation
import SwiftData

actor RoutineEngine {
    nonisolated static let shared = RoutineEngine(
        store: SwiftDataDailyEntryStore(context: ModelContext(ModelContainerProvider.shared))
    )

    private let store: DailyEntryStore
    private let contentEngine: DailyContentEngine

    init(store: DailyEntryStore, contentEngine: DailyContentEngine = DailyContentEngine()) {
        self.store = store
        self.contentEngine = contentEngine
    }

    func entryForToday(routineKey: String = RoutineKey.daily) async throws -> TodaySnapshot {
        let entry = try await loadEntry(routineKey: routineKey)
        return TodaySnapshot.from(entry)
    }

    func startDay(routineKey: String = RoutineKey.daily) async throws -> TodaySnapshot {
        let entry = try await loadEntry(routineKey: routineKey)
        if entry.status == .empty {
            entry.status = .inProgress
            entry.touchUpdated()
            try store.save()
            await SystemUpdateCenter.refresh(snapshot: TodaySnapshot.from(entry))
        }
        return TodaySnapshot.from(entry)
    }

    func setIntent(_ text: String, routineKey: String = RoutineKey.daily) async throws {
        let entry = try await loadEntry(routineKey: routineKey)
        let normalized = normalize(text)
        guard !normalized.isEmpty else { return }
        entry.intent = normalized
        if entry.status == .empty {
            entry.status = .inProgress
        }
        entry.touchUpdated()
        try store.save()
        await SystemUpdateCenter.refresh(snapshot: TodaySnapshot.from(entry))
    }

    func addGratitude(_ text: String, routineKey: String = RoutineKey.daily) async throws {
        let entry = try await loadEntry(routineKey: routineKey)
        let normalized = normalize(text)
        guard !normalized.isEmpty else { return }
        entry.gratitudeItems = appendUnique(normalized, to: entry.gratitudeItems, limit: 3)
        if entry.status == .empty {
            entry.status = .inProgress
        }
        entry.touchUpdated()
        try store.save()
        await SystemUpdateCenter.refresh(snapshot: TodaySnapshot.from(entry))
    }

    func addPriority(_ text: String, routineKey: String = RoutineKey.daily) async throws {
        let entry = try await loadEntry(routineKey: routineKey)
        let normalized = normalize(text)
        guard !normalized.isEmpty else { return }
        entry.priorities = appendUnique(normalized, to: entry.priorities, limit: 3)
        if entry.status == .empty {
            entry.status = .inProgress
        }
        entry.touchUpdated()
        try store.save()
        await SystemUpdateCenter.refresh(snapshot: TodaySnapshot.from(entry))
    }

    func beginBreathwork(minutes: Int, routineKey: String = RoutineKey.daily) async throws {
        let entry = try await loadEntry(routineKey: routineKey)
        entry.mindfulnessMinutes += max(minutes, 0)
        if entry.status == .empty {
            entry.status = .inProgress
        }
        entry.touchUpdated()
        try store.save()
        await SystemUpdateCenter.refresh(snapshot: TodaySnapshot.from(entry))
        Task { await HealthKitManager.shared.logMindfulness(minutes: minutes) }
    }

    func complete(routineKey: String = RoutineKey.daily) async throws {
        let entry = try await loadEntry(routineKey: routineKey)
        guard entry.status != .completed else { return }
        entry.status = .completed
        entry.completedAt = Date()
        entry.touchUpdated()
        try store.save()
        await SystemUpdateCenter.refresh(snapshot: TodaySnapshot.from(entry))
    }

    func skipToday(routineKey: String = RoutineKey.daily) async throws {
        let entry = try await loadEntry(routineKey: routineKey)
        guard entry.status != .completed else { return }
        entry.status = .completed
        entry.completedAt = Date()
        entry.touchUpdated()
        try store.save()
        await SystemUpdateCenter.refresh(snapshot: TodaySnapshot.from(entry))
    }

    private func loadEntry(routineKey: String) async throws -> DailyEntry {
        let dayKey = DayKeying.today()
        if let entry = try store.entry(for: dayKey, routineKey: routineKey) {
            return entry
        }
        let content = contentEngine.content(for: dayKey)
        let entry = DailyEntry(
            dayKey: dayKey,
            routineKey: routineKey,
            intent: "",
            affirmation: content.affirmation,
            quoteText: content.quote.text,
            quoteAuthor: content.quote.author,
            status: .empty
        )
        try store.insert(entry)
        try store.save()
        await SystemUpdateCenter.refresh(snapshot: TodaySnapshot.from(entry))
        return entry
    }

    private func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func appendUnique(_ text: String, to items: [String], limit: Int) -> [String] {
        var items = items
        let normalized = text.lowercased()
        if items.map({ $0.lowercased() }).contains(normalized) { return items }
        items.append(text)
        if items.count > limit {
            items = Array(items.prefix(limit))
        }
        return items
    }
}
