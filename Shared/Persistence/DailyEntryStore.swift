import Foundation

protocol DailyEntryStore {
    func entry(for dayKey: String, routineKey: String) throws -> DailyEntry?
    func insert(_ entry: DailyEntry) throws
    func save() throws
}
