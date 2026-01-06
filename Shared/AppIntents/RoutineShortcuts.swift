import AppIntents

struct RoutineShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartMyDayIntent(),
            phrases: ["Start My Day", "Begin Routine"],
            shortTitle: "Start",
            systemImageName: "sunrise"
        )
        AppShortcut(
            intent: AddGratitudeIntent(),
            phrases: ["Add Gratitude", "Add Gratitude \(\.$text)"],
            shortTitle: "Gratitude",
            systemImageName: "heart"
        )
        AppShortcut(
            intent: CompleteRoutineIntent(),
            phrases: ["Complete Routine", "Finish Routine"],
            shortTitle: "Complete",
            systemImageName: "checkmark"
        )
        AppShortcut(
            intent: ShowTodayIntent(),
            phrases: ["Show Today", "Open Routine"],
            shortTitle: "Today",
            systemImageName: "calendar"
        )
    }
}
