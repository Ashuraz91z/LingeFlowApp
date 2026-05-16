import UserNotifications

enum NotificationAuthorizationState {
    case notDetermined
    case authorized
    case denied
}

final class NotificationService {
    private let center = UNUserNotificationCenter.current()

    func authorizationState() async -> NotificationAuthorizationState {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleReminder(for routine: LaundryRoutine) async {
        cancelReminder(for: routine)

        guard routine.isNotificationEnabled, routine.nextReminderDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Rappel linge"
        content.body = "Il est temps de faire \(routine.name)"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: routine.nextReminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: routine),
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            // The next app launch or edit will try to schedule again.
        }
    }

    func scheduleReminders(for routines: [LaundryRoutine]) async {
        for routine in routines {
            await scheduleReminder(for: routine)
        }
    }

    func cancelReminder(for routine: LaundryRoutine) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier(for: routine)])
    }

    func cancelAllReminders() {
        center.removeAllPendingNotificationRequests()
    }

    private func notificationIdentifier(for routine: LaundryRoutine) -> String {
        "routine-reminder-\(routine.id.uuidString)"
    }
}
