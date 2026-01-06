import Foundation

final class SnapshotStore {
    static let shared = SnapshotStore()
    private let storageKey = "routine.today.snapshot"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = UserDefaults(suiteName: AppGroup.identifier) ?? .standard) {
        self.defaults = defaults
    }

    func load() -> TodaySnapshot? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(TodaySnapshot.self, from: data)
    }

    func save(_ snapshot: TodaySnapshot) {
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: storageKey)
        }
    }

    func save(entry: DailyEntry) {
        save(TodaySnapshot.from(entry))
    }
}
