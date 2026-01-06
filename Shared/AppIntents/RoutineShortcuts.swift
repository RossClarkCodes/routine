import AppIntents

struct RoutineShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartMyDayIntent(),
            phrases: ["\(.applicationName) Start My Day", "\(.applicationName) Begin Routine"],
            shortTitle: "Start",
            systemImageName: "sunrise"
        )
        AppShortcut(
            intent: AddGratitudeIntent(),
            phrases: ["\(.applicationName) Add Gratitude", "\(.applicationName) Gratitude"],
            shortTitle: "Gratitude",
            systemImageName: "heart"
        )
        AppShortcut(
            intent: CompleteRoutineIntent(),
            phrases: ["\(.applicationName) Complete Routine", "\(.applicationName) Finish Routine"],
            shortTitle: "Complete",
            systemImageName: "checkmark"
        )
        AppShortcut(
            intent: ShowTodayIntent(),
            phrases: ["\(.applicationName) Show Today", "\(.applicationName) Open Routine"],
            shortTitle: "Today",
            systemImageName: "calendar"
        )
    }
}
