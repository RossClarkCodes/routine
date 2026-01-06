import Foundation

#if canImport(HealthKit)
import HealthKit

@MainActor
final class HealthKitManager {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()
    private let requestedKey = "healthkit.requested"

    func requestAuthorization() async -> Bool {
        let shareTypes: Set = [HKObjectType.categoryType(forIdentifier: .mindfulSession)!]
        let readTypes: Set = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.workoutType()
        ]
        let success = (try? await store.requestAuthorization(toShare: shareTypes, read: readTypes)) != nil
        return success
    }

    func requestAuthorizationIfNeeded() async -> Bool {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: requestedKey) {
            return true
        }
        let granted = await requestAuthorization()
        defaults.set(true, forKey: requestedKey)
        return granted
    }

    func logMindfulness(minutes: Int) async {
        guard minutes > 0 else { return }
        let type = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        let start = Date()
        let end = start.addingTimeInterval(TimeInterval(minutes * 60))
        let sample = HKCategorySample(type: type, value: HKCategoryValue.notApplicable.rawValue, start: start, end: end)
        do {
            try await store.save(sample)
        } catch {
            return
        }
    }

    func sleepDurationToday() async -> TimeInterval? {
        let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                let total = (samples as? [HKCategorySample])?.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                continuation.resume(returning: total)
            }
            store.execute(query)
        }
    }

    func hasWorkoutToday() async -> Bool {
        let type = HKObjectType.workoutType()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: nil) { _, samples, _ in
                continuation.resume(returning: (samples?.isEmpty == false))
            }
            store.execute(query)
        }
    }
}
#else
@MainActor
final class HealthKitManager {
    static let shared = HealthKitManager()
    func requestAuthorization() async -> Bool { false }
    func requestAuthorizationIfNeeded() async -> Bool { false }
    func logMindfulness(minutes: Int) async { }
    func sleepDurationToday() async -> TimeInterval? { nil }
    func hasWorkoutToday() async -> Bool { false }
}
#endif
