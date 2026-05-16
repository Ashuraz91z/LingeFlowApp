//
//  LaundryRoutine.swift
//  LingeFlowApp
//
//  Created by Lucas Fernandes on 14/05/2026.
//

import Foundation
import SwiftData

@Model
final class LaundryRoutine {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "bed.double"
    var isDueToday: Bool {
        Calendar.current.isDateInToday(nextReminderDate)
    }
    var isOverdue: Bool {
        nextReminderDate < Date()
    }
    var frequencyDays: Int = 7
    var reminderTime: Date = Date()
    var nextReminderDate: Date = Date()
    var lastCompletedDate: Date?
    var isNotificationEnabled: Bool = true
    var createdAt: Date = Date()

    init(
        name: String,
        icon: String,
        frequencyDays: Int,
        reminderTime: Date,
        nextReminderDate: Date,
        isNotificationEnabled: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.frequencyDays = frequencyDays
        self.reminderTime = reminderTime
        self.nextReminderDate = nextReminderDate
        self.lastCompletedDate = nil
        self.isNotificationEnabled = isNotificationEnabled
        self.createdAt = Date()
    }
}
