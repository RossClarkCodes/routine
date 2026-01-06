import Foundation
import UserNotifications

enum NotificationIdentifiers {
    static let dailyReminder = "routine.daily.reminder"
    static let dailyCategory = "routine.daily.category"
    static let actionStart = "routine.action.start"
    static let actionAddGratitude = "routine.action.addGratitude"
    static let actionComplete = "routine.action.complete"
    static let actionSkip = "routine.action.skip"
}

@MainActor
enum NotificationCenterCoordinator {
    static func configure(delegate: UNUserNotificationCenterDelegate) {
        let center = UNUserNotificationCenter.current()
        center.delegate = delegate
        configureCategories()
    }

    static func requestProvisionalAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound, .provisional])
        } catch {
            return false
        }
    }

    static func scheduleDailyReminder(hour: Int, minute: Int) {
        cancelDailyReminder()
        let content = UNMutableNotificationContent()
        content.title = "Your intention is ready"
        content.body = "Start your daily moment when you’re ready."
        content.categoryIdentifier = NotificationIdentifiers.dailyCategory
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: NotificationIdentifiers.dailyReminder, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NotificationIdentifiers.dailyReminder])
    }

    private static func configureCategories() {
        let start = UNNotificationAction(identifier: NotificationIdentifiers.actionStart, title: "Start My Day")
        let addGratitude = UNTextInputNotificationAction(identifier: NotificationIdentifiers.actionAddGratitude, title: "Add Gratitude", options: [], textInputButtonTitle: "Save", textInputPlaceholder: "I’m grateful for...")
        let complete = UNNotificationAction(identifier: NotificationIdentifiers.actionComplete, title: "Complete")
        let skip = UNNotificationAction(identifier: NotificationIdentifiers.actionSkip, title: "Skip", options: [.destructive])

        let category = UNNotificationCategory(identifier: NotificationIdentifiers.dailyCategory, actions: [start, addGratitude, complete, skip], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

final class NotificationsDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        switch response.actionIdentifier {
        case NotificationIdentifiers.actionStart:
            _ = try? await RoutineEngine.shared.startDay()
        case NotificationIdentifiers.actionComplete:
            try? await RoutineEngine.shared.complete()
        case NotificationIdentifiers.actionSkip:
            try? await RoutineEngine.shared.skipToday()
        case NotificationIdentifiers.actionAddGratitude:
            if let textResponse = response as? UNTextInputNotificationResponse {
                let text = textResponse.userText
                try? await RoutineEngine.shared.addGratitude(text)
            }
        default:
            break
        }
    }
}
