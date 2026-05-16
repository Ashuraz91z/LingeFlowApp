//
//  AddRoutineSheet.swift
//  LingeFlowApp
//
//  Created by Lucas Fernandes on 14/05/2026.
//

import SwiftUI

struct AddRoutineView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (LaundryRoutine) -> Void

    @State private var name = ""
    @State private var selectedIcon = RoutineIconChoice.draps
    @State private var selectedFrequency = RoutineFrequencyChoice.fourteenDays
    @State private var customFrequencyDays = 10
    @State private var startDate = Date()
    @State private var reminderTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()

    private var frequencyDays: Int {
        selectedFrequency.days ?? customFrequencyDays
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 34) {
                    header

                    VStack(alignment: .leading, spacing: 14) {
                        sectionTitle("Nom de la tâche")

                        TextField("", text: $name, prompt: Text("Ex: Draps").foregroundStyle(Color.lingePlaceholder))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.lingeInk)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 16)
                            .frame(height: 54)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.lingeBorder, lineWidth: 1.2)
                            }
                    }

                    iconSection
                    frequencySection
                    startDateSection
                    reminderSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 120)
            }

            footerButton
        }
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        ZStack {
            Text("Nouvelle routine")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.lingeInk)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.lingeInk)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .frame(height: 44)
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Icône")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(RoutineIconChoice.allCases) { icon in
                        Button {
                            selectedIcon = icon
                        } label: {
                            RoutineChoiceIcon(icon: icon)
                                .padding(8)
                            .background(selectedIcon == icon ? Color.lingePurple.opacity(0.08) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(selectedIcon == icon ? Color.lingePurple : Color.lingeBorder, lineWidth: 1.2)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("Fréquence")

            VStack(spacing: 18) {
                ForEach(RoutineFrequencyChoice.allCases) { frequency in
                    Button {
                        selectedFrequency = frequency
                    } label: {
                        HStack(spacing: 16) {
                            RadioCircle(isSelected: selectedFrequency == frequency)

                            Image(systemName: frequency.systemImageName)
                                .font(.system(size: 25, weight: .regular))
                                .foregroundStyle(frequency.tint)
                                .frame(width: 30)

                            Text(frequency.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.lingeInk)

                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                if selectedFrequency == .custom {
                    CustomFrequencyControl(days: $customFrequencyDays)
                        .padding(.leading, 46)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.34, dampingFraction: 0.86), value: selectedFrequency)
        }
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Heure du rappel")

            StyledDatePickerRow(
                title: "Heure",
                value: DateFormatter.formRoutineHour.string(from: reminderTime),
                iconName: "clock",
                selection: $reminderTime,
                displayedComponents: [.hourAndMinute]
            )
        }
    }

    private var startDateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Début de la routine")

            StyledDatePickerRow(
                title: "À partir du",
                value: DateFormatter.formRoutineDate.string(from: startDate),
                iconName: "calendar",
                selection: $startDate,
                displayedComponents: [.date],
                minimumDate: Calendar.current.startOfDay(for: Date())
            )
        }
    }

    private var footerButton: some View {
        Button {
            saveRoutine()
        } label: {
            Text("Créer la routine")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(canSave ? Color.lingePurple : Color.lingeMuted.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color.lingePurple.opacity(canSave ? 0.28 : 0), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(!canSave)
        .padding(.horizontal, 16)
        .padding(.bottom, 22)
        .background(
            LinearGradient(
                colors: [.white.opacity(0), .white, .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 115)
            .ignoresSafeArea(edges: .bottom),
            alignment: .bottom
        )
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color.lingeInk)
    }

    private func saveRoutine() {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeStartDate = startDate.notEarlierThanToday()
        let nextReminderDate = safeStartDate.applyingTime(from: reminderTime)

        let routine = LaundryRoutine(
            name: cleanedName,
            icon: selectedIcon.assetName ?? selectedIcon.systemImageName,
            frequencyDays: frequencyDays,
            reminderTime: reminderTime,
            nextReminderDate: nextReminderDate
        )

        onSave(routine)
        dismiss()
    }
}

struct EditRoutineView: View {
    @Environment(\.dismiss) private var dismiss

    let routine: LaundryRoutine
    let onSave: (LaundryRoutine) -> Void

    @State private var name: String
    @State private var selectedIcon: RoutineIconChoice
    @State private var selectedFrequency: RoutineFrequencyChoice
    @State private var customFrequencyDays: Int
    @State private var nextReminderDate: Date
    @State private var reminderTime: Date

    private var frequencyDays: Int {
        selectedFrequency.days ?? customFrequencyDays
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(routine: LaundryRoutine, onSave: @escaping (LaundryRoutine) -> Void = { _ in }) {
        self.routine = routine
        self.onSave = onSave
        _name = State(initialValue: routine.name)
        _selectedIcon = State(initialValue: RoutineIconChoice.choice(for: routine.icon))
        _selectedFrequency = State(initialValue: RoutineFrequencyChoice.choice(for: routine.frequencyDays))
        _customFrequencyDays = State(initialValue: routine.frequencyDays)
        _nextReminderDate = State(initialValue: routine.nextReminderDate)
        _reminderTime = State(initialValue: routine.reminderTime)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 34) {
                    header
                    nameSection
                    iconSection
                    frequencySection
                    nextReminderSection
                    reminderSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 120)
            }

            footerButton
        }
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        ZStack {
            Text("Modifier la routine")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.lingeInk)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.lingeInk)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .frame(height: 44)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Nom de la tâche")

            TextField("", text: $name, prompt: Text("Ex: Draps").foregroundStyle(Color.lingePlaceholder))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.lingeInk)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.lingeBorder, lineWidth: 1.2)
                }
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Icône")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(RoutineIconChoice.allCases) { icon in
                        Button {
                            selectedIcon = icon
                        } label: {
                            RoutineChoiceIcon(icon: icon)
                                .padding(8)
                                .background(selectedIcon == icon ? Color.lingePurple.opacity(0.08) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(selectedIcon == icon ? Color.lingePurple : Color.lingeBorder, lineWidth: 1.2)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("Fréquence")

            VStack(spacing: 18) {
                ForEach(RoutineFrequencyChoice.allCases) { frequency in
                    Button {
                        selectedFrequency = frequency
                    } label: {
                        HStack(spacing: 16) {
                            RadioCircle(isSelected: selectedFrequency == frequency)

                            Image(systemName: frequency.systemImageName)
                                .font(.system(size: 25, weight: .regular))
                                .foregroundStyle(frequency.tint)
                                .frame(width: 30)

                            Text(frequency.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.lingeInk)

                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                if selectedFrequency == .custom {
                    CustomFrequencyControl(days: $customFrequencyDays)
                        .padding(.leading, 46)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.34, dampingFraction: 0.86), value: selectedFrequency)
        }
    }

    private var nextReminderSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Prochain rappel")

            StyledDatePickerRow(
                title: "Date",
                value: DateFormatter.formRoutineDate.string(from: nextReminderDate),
                iconName: "calendar",
                selection: $nextReminderDate,
                displayedComponents: [.date],
                minimumDate: Calendar.current.startOfDay(for: Date())
            )
        }
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Heure du rappel")

            StyledDatePickerRow(
                title: "Heure",
                value: DateFormatter.formRoutineHour.string(from: reminderTime),
                iconName: "clock",
                selection: $reminderTime,
                displayedComponents: [.hourAndMinute]
            )
        }
    }

    private var footerButton: some View {
        Button {
            saveChanges()
        } label: {
            Text("Enregistrer")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(canSave ? Color.lingePurple : Color.lingeMuted.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color.lingePurple.opacity(canSave ? 0.28 : 0), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(!canSave)
        .padding(.horizontal, 16)
        .padding(.bottom, 22)
        .background(
            LinearGradient(
                colors: [.white.opacity(0), .white, .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 115)
            .ignoresSafeArea(edges: .bottom),
            alignment: .bottom
        )
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color.lingeInk)
    }

    private func saveChanges() {
        let updatedNextReminderDate = nextReminderDate.notEarlierThanToday().applyingTime(from: reminderTime)
        let didChangeReminderDay = !Calendar.current.isDate(routine.nextReminderDate, inSameDayAs: updatedNextReminderDate)

        routine.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        routine.icon = selectedIcon.assetName ?? selectedIcon.systemImageName
        routine.frequencyDays = frequencyDays
        routine.reminderTime = reminderTime
        routine.nextReminderDate = updatedNextReminderDate

        if didChangeReminderDay {
            routine.lastCompletedDate = nil
        }

        onSave(routine)
        dismiss()
    }
}

private struct RoutineChoiceIcon: View {
    let icon: RoutineIconChoice

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(icon.tint.opacity(0.12))

            if let assetName = icon.assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: icon.systemImageName)
                    .font(.system(size: 27, weight: .regular))
                    .foregroundStyle(icon.tint)
            }
        }
        .frame(width: 52, height: 52)
    }
}

private struct RadioCircle: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? Color.lingePurple : Color.lingeBorder, lineWidth: 1.5)
                .frame(width: 20, height: 20)

            if isSelected {
                Circle()
                    .fill(Color.lingePurple)
                    .frame(width: 12, height: 12)
            }
        }
    }
}

private struct CustomFrequencyControl: View {
    @Binding var days: Int

    private let range = 1...60

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Répéter tous les")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.lingeMuted)

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(days)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.lingeInk)
                        .monospacedDigit()

                    Text(days == 1 ? "jour" : "jours")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.lingeInk)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                frequencyButton(systemName: "minus") {
                    days = max(range.lowerBound, days - 1)
                }
                .disabled(days == range.lowerBound)

                frequencyButton(systemName: "plus") {
                    days = min(range.upperBound, days + 1)
                }
                .disabled(days == range.upperBound)
            }
        }
        .padding(.leading, 18)
        .padding(.trailing, 12)
        .frame(height: 68)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.lingePurple.opacity(0.16), lineWidth: 1.2)
        }
        .shadow(color: Color.lingePurple.opacity(0.08), radius: 14, x: 0, y: 8)
    }

    private func frequencyButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.lingePurple)
                .frame(width: 38, height: 38)
                .background(Color.lingePurple.opacity(0.10))
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color.lingePurple.opacity(0.18), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

private struct StyledDatePickerRow: View {
    let title: String
    let value: String
    let iconName: String
    @Binding var selection: Date
    let displayedComponents: DatePickerComponents
    var minimumDate: Date?

    @State private var isExpanded = false

    private var pickerHeight: CGFloat {
        displayedComponents == [.date] ? 168 : 138
    }

    var body: some View {
        VStack(spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.lingeInk)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.lingeMuted)

                        Text(value)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.lingeInk)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.lingeMuted)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .frame(height: 58)
                .contentShape(Rectangle())
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.lingeBorder, lineWidth: 1.2)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 10) {
                    picker

                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                            isExpanded = false
                        }
                    } label: {
                        Text("OK")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.lingePurple)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.lingePurple.opacity(0.09))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.lingeControlBackground.opacity(0.68))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.lingeBorder.opacity(0.85), lineWidth: 1)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    @ViewBuilder
    private var picker: some View {
        if let minimumDate {
            DatePicker("", selection: $selection, in: minimumDate..., displayedComponents: displayedComponents)
                .labelsHidden()
                .datePickerStyle(.wheel)
                .environment(\.locale, Locale(identifier: "fr_FR"))
                .environment(\.colorScheme, .light)
                .tint(Color.lingePurple)
                .frame(maxWidth: .infinity)
                .frame(height: pickerHeight)
                .clipped()
        } else {
            DatePicker("", selection: $selection, displayedComponents: displayedComponents)
                .labelsHidden()
                .datePickerStyle(.wheel)
                .environment(\.locale, Locale(identifier: "fr_FR"))
                .environment(\.colorScheme, .light)
                .tint(Color.lingePurple)
                .frame(maxWidth: .infinity)
                .frame(height: pickerHeight)
                .clipped()
        }
    }
}

private enum RoutineIconChoice: String, CaseIterable, Identifiable {
    case draps
    case serviette
    case couleurs
    case blanc
    case rideaux
    case panier
    case machine

    var id: String { rawValue }

    static func choice(for icon: String) -> RoutineIconChoice {
        allCases.first { choice in
            choice.assetName == icon || choice.systemImageName == icon
        } ?? .draps
    }

    var title: String {
        switch self {
        case .draps:
            "Draps"
        case .serviette:
            "Serviettes"
        case .couleurs:
            "Couleurs"
        case .blanc:
            "Blanc"
        case .rideaux:
            "Rideaux"
        case .panier:
            "Panier"
        case .machine:
            "Machine"
        }
    }

    var assetName: String? {
        switch self {
        case .draps:
            "Draps"
        case .serviette:
            "Serviette"
        case .couleurs:
            "VetementNoir"
        case .blanc:
            "VetementBlanc"
        case .rideaux:
            "Rideaux"
        case .panier, .machine:
            nil
        }
    }

    var systemImageName: String {
        switch self {
        case .draps:
            "bed.double"
        case .serviette:
            "towel"
        case .couleurs, .blanc:
            "tshirt"
        case .rideaux:
            "curtains.closed"
        case .panier:
            "basket"
        case .machine:
            "washer"
        }
    }

    var tint: Color {
        switch self {
        case .draps, .rideaux:
            .lingePurple
        case .serviette:
            .lingeGreen
        case .couleurs:
            .lingeBlue
        case .blanc:
            .lingeOrange
        case .panier, .machine:
            .lingeInk
        }
    }
}

private enum RoutineFrequencyChoice: CaseIterable, Identifiable {
    case twoDays
    case sevenDays
    case fourteenDays
    case custom

    var id: String { title }

    static func choice(for days: Int) -> RoutineFrequencyChoice {
        allCases.first { $0.days == days } ?? .custom
    }

    var title: String {
        switch self {
        case .twoDays:
            "Tous les 2 jours"
        case .sevenDays:
            "Tous les 7 jours"
        case .fourteenDays:
            "Tous les 14 jours"
        case .custom:
            "Personnalisé"
        }
    }

    var days: Int? {
        switch self {
        case .twoDays:
            2
        case .sevenDays:
            7
        case .fourteenDays:
            14
        case .custom:
            nil
        }
    }

    var systemImageName: String {
        switch self {
        case .twoDays, .sevenDays, .fourteenDays:
            "calendar"
        case .custom:
            "calendar.badge.clock"
        }
    }

    var tint: Color {
        switch self {
        case .twoDays, .fourteenDays:
            .lingePurple
        case .sevenDays:
            .lingeGreen
        case .custom:
            .lingeOrange
        }
    }
}

private extension Date {
    func notEarlierThanToday() -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return max(self, today)
    }

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

private extension DateFormatter {
    static let formRoutineDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    static let formRoutineHour: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "HH'h'mm"
        return formatter
    }()
}

#Preview {
    NavigationStack {
        AddRoutineView { _ in }
    }
}
