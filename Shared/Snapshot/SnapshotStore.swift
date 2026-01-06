import Foundation

enum SnapshotStore {
    private static let storageKey = "routine.today.snapshot"

    static func load() -> TodaySnapshot? {
        guard let data = defaults().data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(TodaySnapshot.self, from: data)
    }

    static func save(_ snapshot: TodaySnapshot) {
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults().set(data, forKey: storageKey)
        }
    }

    private static func defaults() -> UserDefaults {
        UserDefaults(suiteName: AppGroup.identifier) ?? .standard
    }
}
