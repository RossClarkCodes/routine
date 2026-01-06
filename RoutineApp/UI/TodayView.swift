import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [DailyEntry]

    @State private var showingIntentSheet = false
    @State private var showingGratitudeSheet = false
    @State private var showingPrioritySheet = false
    @State private var showingBreathwork = false

    private var entry: DailyEntry? {
        entries.first { $0.dayKey == DayKeying.today() && $0.routineKey == RoutineKey.daily }
    }

    init() {
        _entries = Query(sort: [SortDescriptor(\DailyEntry.createdAt, order: .reverse)])
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 24) {
                Text("Today")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))

                GlassPanel {
                    VStack(spacing: 18) {
                        intentSection
                        quoteSection
                        divider
                        gratitudeRow
                        prioritiesRow
                        divider
                        primaryAction
                    }
                }

                quickActions
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)
        }
        .onAppear {
            ensureEntry()
            appState.updateFlow(for: entry)
        }
        .onChange(of: entry?.statusRaw) { _, _ in
            appState.updateFlow(for: entry)
        }
        .sheet(isPresented: $showingIntentSheet) {
            AddTextSheet(title: "Today’s Intent", placeholder: "How will you show up today?") { text in
                Task { try? await RoutineEngine.shared.setIntent(text) }
            }
        }
        .sheet(isPresented: $showingGratitudeSheet) {
            AddTextSheet(title: "Add Gratitude", placeholder: "I’m grateful for...") { text in
                Task { try? await RoutineEngine.shared.addGratitude(text) }
            }
        }
        .sheet(isPresented: $showingPrioritySheet) {
            AddTextSheet(title: "Add Priority", placeholder: "Add a top priority...") { text in
                Task { try? await RoutineEngine.shared.addPriority(text) }
            }
        }
        .sheet(isPresented: $showingBreathwork) {
            BreathworkSheet { minutes in
                Task { try? await RoutineEngine.shared.beginBreathwork(minutes: minutes) }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [Color(red: 0.5, green: 0.7, blue: 0.95), Color(red: 0.92, green: 0.78, blue: 0.6), Color(red: 0.22, green: 0.32, blue: 0.45)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var intentSection: some View {
        VStack(spacing: 12) {
            Text(entry?.intent.isEmpty == false ? entry?.intent ?? "" : "Today, I act with focus and decisiveness.")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Button("Edit Intent") {
                showingIntentSheet = true
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
        }
    }

    private var quoteSection: some View {
        VStack(spacing: 6) {
            Text(entry?.quoteText ?? "Success is the sum of small efforts, repeated day in and day out.")
                .font(.system(size: 14, weight: .regular, design: .serif))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let author = entry?.quoteAuthor {
                Text("— \(author)")
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var gratitudeRow: some View {
        ActionRow(icon: "heart.fill", title: "Gratitude", subtitle: subtitle(from: entry?.gratitudeItems, fallback: "I’m grateful for...")) {
            showingGratitudeSheet = true
        }
    }

    private var prioritiesRow: some View {
        ActionRow(icon: "flag.fill", title: "Top Priorities", subtitle: subtitle(from: entry?.priorities, fallback: "Add a top priority...") ) {
            showingPrioritySheet = true
        }
    }

    private var primaryAction: some View {
        Button(action: primaryActionTapped) {
            Text(primaryActionTitle)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Capsule().fill(primaryActionEnabled ? Color.blue.opacity(0.85) : Color.gray.opacity(0.4))
                )
        }
        .disabled(!primaryActionEnabled)
    }

    private var quickActions: some View {
        HStack(spacing: 16) {
            SmallActionButton(title: "1 min Breathing", systemImage: "wind") {
                showingBreathwork = true
            }
            SmallActionButton(title: "Stretch & Move", systemImage: "figure.walk") {
                showingPrioritySheet = true
            }
        }
        .foregroundStyle(.white)
    }

    private var divider: some View {
        Capsule()
            .fill(Color.white.opacity(0.2))
            .frame(height: 1)
    }

    private var primaryActionTitle: String {
        guard let entry else { return "Start My Day" }
        switch entry.status {
        case .completed:
            return "Completed"
        case .empty:
            return "Start My Day"
        case .inProgress:
            return "Complete"
        }
    }

    private var primaryActionEnabled: Bool {
        entry?.status != .completed
    }

    private func primaryActionTapped() {
        guard let entry else { return }
        switch entry.status {
        case .empty:
            Task { try? await RoutineEngine.shared.startDay() }
            HapticsService.play(.routineStart)
        case .inProgress:
            Task { try? await RoutineEngine.shared.complete() }
            HapticsService.play(.complete)
        case .completed:
            break
        }
    }

    private func ensureEntry() {
        if entry == nil {
            Task { _ = try? await RoutineEngine.shared.entryForToday() }
        }
    }

    private func subtitle(from items: [String]?, fallback: String) -> String {
        guard let items, !items.isEmpty else { return fallback }
        return items.joined(separator: ", ")
    }
}

private struct ActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.white.opacity(0.8))
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.white.opacity(0.2)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: action) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.6)))
            }
        }
        .padding(.vertical, 6)
    }
}

private struct SmallActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Capsule().fill(Color.black.opacity(0.35)))
        }
    }
}

private struct AddTextSheet: View {
    let title: String
    let placeholder: String
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField(placeholder, text: $text, axis: .vertical)
                    .textFieldStyle(.roundedBorder)

                Button("Save") {
                    onSave(text)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding(20)
            .navigationTitle(title)
        }
    }
}

private struct BreathworkSheet: View {
    let onComplete: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var minutes: Int = 1
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Breathwork")
                .font(.system(size: 22, weight: .semibold, design: .rounded))

            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 160, height: 160)
                .scaleEffect(reduceMotion ? 1.0 : (pulse ? 1.1 : 0.9))
                .animation(reduceMotion ? nil : .easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulse)
                .onAppear { pulse = true }

            Picker("Minutes", selection: $minutes) {
                Text("1").tag(1)
                Text("2").tag(2)
                Text("5").tag(5)
            }
            .pickerStyle(.segmented)

            Button("Log Session") {
                onComplete(minutes)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .task {
            _ = await HealthKitManager.shared.requestAuthorizationIfNeeded()
        }
    }
}
