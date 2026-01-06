import SwiftUI

struct SettingsView: View {
    @AppStorage("settings.notifications.enabled") private var notificationsEnabled = false
    @AppStorage("settings.notifications.hour") private var notificationHour = 8
    @AppStorage("settings.notifications.minute") private var notificationMinute = 0

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Daily reminder", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            Task { _ = await NotificationCenterCoordinator.requestProvisionalAuthorization() }
                            NotificationCenterCoordinator.scheduleDailyReminder(hour: notificationHour, minute: notificationMinute)
                        } else {
                            NotificationCenterCoordinator.cancelDailyReminder()
                        }
                    }
                DatePicker("Time", selection: bindingForTime, displayedComponents: .hourAndMinute)
            }

            Section("Health") {
                Button("Enable HealthKit") {
                    Task { _ = await HealthKitManager.shared.requestAuthorization() }
                }
            }
        }
        .navigationTitle("Settings")
    }

    private var bindingForTime: Binding<Date> {
        Binding<Date>(
            get: {
                var components = DateComponents()
                components.hour = notificationHour
                components.minute = notificationMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                notificationHour = components.hour ?? 8
                notificationMinute = components.minute ?? 0
                if notificationsEnabled {
                    NotificationCenterCoordinator.scheduleDailyReminder(hour: notificationHour, minute: notificationMinute)
                }
            }
        )
    }
}
