import AppIntents

struct RoutineShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(intent: StartMyDayIntent(), phrases: ["Start My Day", "Begin Routine"], shortTitle: "Start", systemImageName: "sunrise"),
            AppShortcut(intent: AddGratitudeIntent(text: ""), phrases: ["Add Gratitude"], shortTitle: "Gratitude", systemImageName: "heart"),
            AppShortcut(intent: CompleteRoutineIntent(), phrases: ["Complete Routine"], shortTitle: "Complete", systemImageName: "checkmark"),
            AppShortcut(intent: ShowTodayIntent(), phrases: ["Show Today"], shortTitle: "Today", systemImageName: "calendar")
        ]
    }
}
