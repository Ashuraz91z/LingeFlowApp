import SwiftUI

struct RoutineCompletionUndo: Identifiable {
    let id = UUID()
    let routine: LaundryRoutine
    let routineName: String
    let previousNextReminderDate: Date
    let previousLastCompletedDate: Date?
}

struct RoutineDisplay: Identifiable {
    let id: UUID
    let name: String
    let assetName: String
    let systemImageName: String
    let tint: Color
    let frequencyDays: Int
    let nextReminderDate: Date
    let isDueToday: Bool
    let isCompletedToday: Bool
    let source: LaundryRoutine?

    var nextReminderText: String { nextReminderDate.routineReminderText }

    init(routine: LaundryRoutine) {
        let style = RoutineStyle.style(for: routine.icon)
        id = routine.id
        name = routine.name
        assetName = style.assetName
        systemImageName = style.systemImageName
        tint = style.tint
        frequencyDays = routine.frequencyDays
        nextReminderDate = routine.nextReminderDate
        isDueToday = routine.isDueToday || routine.isOverdue
        isCompletedToday = routine.lastCompletedDate.map(Calendar.current.isDateInToday) ?? false
        source = routine
    }
}

private struct RoutineStyle {
    let assetName: String
    let systemImageName: String
    let tint: Color

    static func style(for icon: String) -> RoutineStyle {
        switch icon {
        case "Draps", "bed.double": RoutineStyle(assetName: "Draps", systemImageName: "bed.double", tint: .lingePurple)
        case "Serviette", "towel": RoutineStyle(assetName: "Serviette", systemImageName: "towel", tint: .lingeGreen)
        case "VetementNoir", "Couleurs", "tshirt": RoutineStyle(assetName: "VetementNoir", systemImageName: "tshirt", tint: .lingeBlue)
        case "VetementBlanc", "Blanc": RoutineStyle(assetName: "VetementBlanc", systemImageName: "tshirt", tint: .lingeOrange)
        case "Rideaux", "curtains.closed": RoutineStyle(assetName: "Rideaux", systemImageName: "curtains.closed", tint: .lingePurple)
        default: RoutineStyle(assetName: "", systemImageName: icon, tint: .lingePurple)
        }
    }
}

extension Date {
    var routineReminderText: String {
        if Calendar.current.isDateInTomorrow(self) {
            return "Demain à \(DateFormatter.routineHour.string(from: self))"
        }
        let weekday = DateFormatter.routineWeekday.string(from: self).replacingOccurrences(of: ".", with: "").capitalized
        return "\(weekday). \(DateFormatter.routineDayMonth.string(from: self)) à \(DateFormatter.routineHour.string(from: self))"
    }
}

extension DateFormatter {
    static let routineWeekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "E"
        return formatter
    }()

    static let routineDayMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    static let routineHour: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "HH'h'"
        return formatter
    }()
}
