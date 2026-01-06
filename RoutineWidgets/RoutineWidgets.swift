import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct RoutineEntry: TimelineEntry {
    let date: Date
    let snapshot: TodaySnapshot
}

struct RoutineTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> RoutineEntry {
        RoutineEntry(date: Date(), snapshot: TodaySnapshot.empty(for: DayKeying.today()))
    }

    func getSnapshot(in context: Context, completion: @escaping (RoutineEntry) -> Void) {
        completion(RoutineEntry(date: Date(), snapshot: SnapshotStore.load() ?? TodaySnapshot.empty(for: DayKeying.today())))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RoutineEntry>) -> Void) {
        let snapshot = SnapshotStore.load() ?? TodaySnapshot.empty(for: DayKeying.today())
        let entry = RoutineEntry(date: Date(), snapshot: snapshot)
        let next = Calendar.current.startOfDay(for: Date().addingTimeInterval(60 * 60 * 24))
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

@main
struct RoutineWidgets: WidgetBundle {
    var body: some Widget {
        RoutineLockStatusWidget()
        RoutineLockRingWidget()
        RoutineHomeSmallWidget()
        RoutineHomeMediumWidget()
        RoutineLiveActivityWidget()
    }
}

struct RoutineLockStatusWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetKinds.lockStatus, provider: RoutineTimelineProvider()) { entry in
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 6) {
                    Text(statusText(for: entry.snapshot))
                        .font(.caption2)
                    Button(intent: StartMyDayIntent()) {
                        Text("Start")
                            .font(.caption2)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(6)
            }
        }
        .supportedFamilies([.accessoryRectangular])
        .configurationDisplayName("Routine Status")
        .description("Your daily status and a quick start.")
    }
}

struct RoutineLockRingWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetKinds.lockRing, provider: RoutineTimelineProvider()) { entry in
            ZStack {
                AccessoryWidgetBackground()
                Circle()
                    .stroke(lineWidth: 4)
                    .opacity(0.3)
                Circle()
                    .trim(from: 0, to: progress(for: entry.snapshot))
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: entry.snapshot.status == .completed ? "checkmark" : "sunrise")
                    .font(.caption)
            }
            .padding(6)
        }
        .supportedFamilies([.accessoryCircular])
        .configurationDisplayName("Routine Ring")
        .description("Completion ring for today.")
    }
}

struct RoutineHomeSmallWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetKinds.homeSmall, provider: RoutineTimelineProvider()) { entry in
            VStack(spacing: 8) {
                Text("Start My Day")
                    .font(.headline)
                Button(intent: StartMyDayIntent()) {
                    Text("Start")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Start My Day")
        .description("One tap to begin.")
    }
}

struct RoutineHomeMediumWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetKinds.homeMedium, provider: RoutineTimelineProvider()) { entry in
            VStack(alignment: .leading, spacing: 10) {
                Text("Today")
                    .font(.headline)
                Text(entry.snapshot.intentPreview.isEmpty ? "Set your daily intent." : entry.snapshot.intentPreview)
                    .font(.subheadline)
                    .lineLimit(2)
                HStack {
                    Button(intent: StartMyDayIntent()) { Text("Start") }
                    Button(intent: AddGratitudeIntent()) { Text("Add Gratitude") }
                    Button(intent: CompleteRoutineIntent()) { Text("Complete") }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Today")
        .description("Intent and quick actions.")
    }
}

struct RoutineLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RoutineActivityAttributes.self) { context in
            VStack(spacing: 6) {
                Text("Routine in progress")
                    .font(.caption)
                Text(stepLabel(for: context.state.step))
                    .font(.headline)
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Routine")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(stepLabel(for: context.state.step))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Stay with the moment")
                }
            } compactLeading: {
                Image(systemName: "sunrise")
            } compactTrailing: {
                Text(stepShort(for: context.state.step))
            } minimal: {
                Image(systemName: "sunrise")
            }
        }
    }
}

private func statusText(for snapshot: TodaySnapshot) -> String {
    switch snapshot.status {
    case .ready: return "Ready"
    case .inProgress: return "In Progress"
    case .completed: return "Completed"
    }
}

private func progress(for snapshot: TodaySnapshot) -> CGFloat {
    switch snapshot.status {
    case .ready: return 0.1
    case .inProgress: return 0.6
    case .completed: return 1.0
    }
}

private func stepLabel(for step: RoutineStep) -> String {
    switch step {
    case .intent: return "Intent"
    case .gratitude: return "Gratitude"
    case .priorities: return "Priorities"
    case .complete: return "Complete"
    }
}

private func stepShort(for step: RoutineStep) -> String {
    switch step {
    case .intent: return "I"
    case .gratitude: return "G"
    case .priorities: return "P"
    case .complete: return "✓"
    }
}
