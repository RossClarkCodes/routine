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
                    NotificationCenterCoordinator.shared.configure(delegate: notificationsDelegate)
                    BackgroundTasksManager.shared.register()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .background {
                        BackgroundTasksManager.shared.schedulePrewarm()
                    }
                }
        }
    }
}
