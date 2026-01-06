import SwiftUI
import SwiftData

@main
struct RoutineApp: App {
    @State private var appState = AppState()
    private let notificationsDelegate = NotificationsDelegate()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .modelContainer(ModelContainerProvider.shared)
                .onAppear {
                    NotificationCenterCoordinator.configure(delegate: notificationsDelegate)
                    BackgroundTasksManager.register()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .background {
                        BackgroundTasksManager.schedulePrewarm()
                    }
                }
        }
    }
}
