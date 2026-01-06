import SwiftUI
import WidgetKit

struct RoutineComplicationEntry: TimelineEntry {
    let date: Date
    let snapshot: TodaySnapshot
}

struct RoutineComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> RoutineComplicationEntry {
        RoutineComplicationEntry(date: Date(), snapshot: TodaySnapshot.empty(for: DayKeying.today()))
    }

    func getSnapshot(in context: Context, completion: @escaping (RoutineComplicationEntry) -> Void) {
        completion(RoutineComplicationEntry(date: Date(), snapshot: SnapshotStore.load() ?? TodaySnapshot.empty(for: DayKeying.today())))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RoutineComplicationEntry>) -> Void) {
        let snapshot = SnapshotStore.load() ?? TodaySnapshot.empty(for: DayKeying.today())
        let entry = RoutineComplicationEntry(date: Date(), snapshot: snapshot)
        let next = Calendar.current.startOfDay(for: Date().addingTimeInterval(60 * 60 * 24))
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct RoutineComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RoutineComplication", provider: RoutineComplicationProvider()) { entry in
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: entry.snapshot.status == .completed ? "checkmark" : "sunrise")
            }
        }
        .supportedFamilies([.accessoryCircular, .accessoryInline])
        .configurationDisplayName("Routine")
        .description("Daily status at a glance.")
    }
}

@main
struct RoutineWatchWidgets: WidgetBundle {
    var body: some Widget {
        RoutineComplication()
    }
}
