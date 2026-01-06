import AppIntents
import SwiftUI

struct WatchTodayView: View {
    @State private var snapshot = SnapshotStore.shared.load() ?? TodaySnapshot.empty(for: DayKeying.today())
    @State private var lastStatus: TodayStatus = .ready
    @State private var hasLoaded = false

    var body: some View {
        VStack(spacing: 8) {
            Text("Today")
                .font(.headline)

            Text(snapshot.intentPreview.isEmpty ? "Set your intent" : snapshot.intentPreview)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(statusText)
                .font(.caption2)
                .foregroundStyle(.secondary)

            primaryActionButton
        }
        .padding()
        .onAppear(perform: reloadSnapshot)
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            reloadSnapshot()
        }
    }

    private var statusText: String {
        switch snapshot.status {
        case .ready: return "Ready"
        case .inProgress: return "In progress"
        case .completed: return "Completed"
        }
    }

    private var primaryActionTitle: String {
        switch snapshot.status {
        case .completed: return "Done"
        case .ready: return "Start"
        case .inProgress: return "Complete"
        }
    }

    @ViewBuilder private var primaryActionButton: some View {
        switch snapshot.status {
        case .completed:
            Button(primaryActionTitle) { }
                .buttonStyle(.borderedProminent)
                .disabled(true)
        case .ready:
            Button(intent: StartMyDayIntent()) {
                Text(primaryActionTitle)
            }
            .buttonStyle(.borderedProminent)
        case .inProgress:
            Button(intent: CompleteRoutineIntent()) {
                Text(primaryActionTitle)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func reloadSnapshot() {
        let latest = SnapshotStore.shared.load() ?? TodaySnapshot.empty(for: DayKeying.today())
        if !hasLoaded {
            snapshot = latest
            lastStatus = latest.status
            hasLoaded = true
            return
        }
        if latest.status != lastStatus {
            switch latest.status {
            case .ready:
                WatchHapticsService.shared.play(.start)
            case .inProgress:
                WatchHapticsService.shared.play(.start)
            case .completed:
                WatchHapticsService.shared.play(.complete)
            }
        }
        snapshot = latest
        lastStatus = latest.status
    }
}
