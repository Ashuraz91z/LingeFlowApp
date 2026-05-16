//
//  RoutineService.swift
//  LingeFlowApp
//
//  Created by Lucas Fernandes on 14/05/2026.
//

import Foundation

final class RoutineService {

    func completeRoutine(_ routine: LaundryRoutine) {
        let now = Date()
        let nextDate = Calendar.current.date(
            byAdding: .day,
            value: routine.frequencyDays,
            to: now
        ) ?? now

        routine.lastCompletedDate = now
        routine.nextReminderDate = nextDate.applyingTime(from: routine.reminderTime)
    }
}

private extension Date {
    func applyingTime(from time: Date) -> Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        return calendar.date(
            bySettingHour: timeComponents.hour ?? 18,
            minute: timeComponents.minute ?? 0,
            second: 0,
            of: self
        ) ?? self
    }
}
