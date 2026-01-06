import Foundation
import SwiftData

final class SwiftDataDailyEntryStore: DailyEntryStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func entry(for dayKey: String, routineKey: String) throws -> DailyEntry? {
        let compoundKey = "\(dayKey)|\(routineKey)"
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate { $0.compoundKey == compoundKey },
            sortBy: []
        )
        return try context.fetch(descriptor).first
    }

    func insert(_ entry: DailyEntry) throws {
        context.insert(entry)
    }

    func save() throws {
        try context.save()
    }
}

enum ModelContainerProvider {
    static let shared: ModelContainer = {
        let url = AppGroup.containerURL.appendingPathComponent("Routine.store")
        let configuration = ModelConfiguration(url: url)
        return try! ModelContainer(for: DailyEntry.self, configurations: configuration)
    }()
}
