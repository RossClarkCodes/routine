import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
enum SystemUpdateCenter {
    @MainActor private static var lastWidgetReload: Date?

    @MainActor static func refresh(snapshot: TodaySnapshot) {
        SnapshotStore.save(snapshot)
        reloadWidgetsIfNeeded()
        LiveActivityManager.shared.sync(with: snapshot)
    }

    @MainActor private static func reloadWidgetsIfNeeded() {
        #if canImport(WidgetKit)
        let now = Date()
        if let last = lastWidgetReload, now.timeIntervalSince(last) < 5 {
            return
        }
        lastWidgetReload = now
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKinds.lockStatus)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKinds.lockRing)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKinds.homeSmall)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKinds.homeMedium)
        #endif
    }
}
