import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \LaundryRoutine.nextReminderDate) private var routines: [LaundryRoutine]
    @State private var isShowingAddRoutine = false
    @State private var selectedRoutineForEdit: LaundryRoutine?
    @State private var selectedTab = MainTab.home
    @State private var routineSearchText = ""
    @State private var undoCompletion: RoutineCompletionUndo?
    @State private var earlyCompletionRoutine: RoutineDisplay?
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var notificationAuthorizationState = NotificationAuthorizationState.notDetermined
    @Namespace private var routineMoveNamespace

    private let routineService = RoutineService()
    private let notificationService = NotificationService()
    @MainActor
    private var displayedRoutines: [RoutineDisplay] { routines.map(RoutineDisplay.init(routine:)) }

    @MainActor
    private var partitionedRoutines: (dueToday: [RoutineDisplay], upcoming: [RoutineDisplay]) {
        displayedRoutines.reduce(into: (dueToday: [RoutineDisplay](), upcoming: [RoutineDisplay]())) { result, routine in
            if routine.isDueToday {
                result.dueToday.append(routine)
            } else {
                result.upcoming.append(routine)
            }
        }
    }
    private var appVersion: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-" }
    private var notificationsBinding: Binding<Bool> {
        Binding(get: { notificationsEnabled && notificationAuthorizationState == .authorized }, set: { value in
            if value {
                Task { await enableNotifications() }
            } else {
                disableNotifications()
            }
        })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.lingeBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    selectedContent.frame(maxWidth: .infinity, maxHeight: .infinity).id(selectedTab)
                    MainTabBar(selectedTab: $selectedTab)
                }
                .opacity(hasCompletedOnboarding ? 1 : 0)
                if let undoCompletion {
                    CompletionUndoBanner(routineName: undoCompletion.routineName, onUndo: undoRoutineCompletion)
                        .padding(.horizontal, 20).padding(.bottom, 86).frame(maxHeight: .infinity, alignment: .bottom)
                }
                if let earlyCompletionRoutine {
                    EarlyCompletionConfirmationDialog(
                        routineName: earlyCompletionRoutine.name,
                        onCancel: { self.earlyCompletionRoutine = nil },
                        onConfirm: { self.earlyCompletionRoutine = nil; completeRoutine(earlyCompletionRoutine) }
                    )
                }
                if !hasCompletedOnboarding {
                    OnboardingView { hasCompletedOnboarding = true }
                }
            }
            .navigationDestination(isPresented: $isShowingAddRoutine) {
                AddRoutineView { routine in
                    routine.isNotificationEnabled = notificationsEnabled
                    modelContext.insert(routine)
                    scheduleReminderIfNeeded(for: routine)
                }
            }
            .navigationDestination(item: $selectedRoutineForEdit) { routine in
                EditRoutineView(routine: routine) { updatedRoutine in
                    scheduleReminderIfNeeded(for: updatedRoutine)
                }
            }
        }
        .tint(Color.lingePurple)
        .task {
            await refreshNotificationAuthorization()
            await scheduleAllRemindersIfPossible()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task {
                await refreshNotificationAuthorization()
                await scheduleAllRemindersIfPossible()
            }
        }
    }

    @ViewBuilder private var selectedContent: some View {
        switch selectedTab {
        case .home:
            let routineGroups = partitionedRoutines
            HomeView(routines: routines, dueTodayRoutines: routineGroups.dueToday, upcomingRoutines: routineGroups.upcoming, routineMoveNamespace: routineMoveNamespace, onAddRoutine: { isShowingAddRoutine = true }, onComplete: completeRoutine, onEarlyCompletion: showEarlyCompletionConfirmation)
        case .routines:
            RoutinesView(displayedRoutines: displayedRoutines, searchText: $routineSearchText, onAddRoutine: { isShowingAddRoutine = true }, onEdit: { selectedRoutineForEdit = $0.source }, onDelete: deleteRoutine)
        case .settings:
            SettingsView(
                routineCount: routines.count,
                notificationsEnabled: notificationsBinding,
                notificationAuthorizationState: notificationAuthorizationState,
                appVersion: appVersion,
                onDeleteAllRoutines: deleteAllRoutines
            )
        }
    }

    private func completeRoutine(_ routine: RoutineDisplay) {
        guard let laundryRoutine = routine.source else { return }
        let undo = RoutineCompletionUndo(routine: laundryRoutine, routineName: laundryRoutine.name, previousNextReminderDate: laundryRoutine.nextReminderDate, previousLastCompletedDate: laundryRoutine.lastCompletedDate)
        withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
            routineService.completeRoutine(laundryRoutine)
            undoCompletion = undo
        }
        scheduleReminderIfNeeded(for: laundryRoutine)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(5))
            if undoCompletion?.id == undo.id { undoCompletion = nil }
        }
    }
    private func showEarlyCompletionConfirmation(for routine: RoutineDisplay) { earlyCompletionRoutine = routine }
    private func undoRoutineCompletion() {
        guard let undoCompletion else { return }
        undoCompletion.routine.nextReminderDate = undoCompletion.previousNextReminderDate
        undoCompletion.routine.lastCompletedDate = undoCompletion.previousLastCompletedDate
        scheduleReminderIfNeeded(for: undoCompletion.routine)
        self.undoCompletion = nil
    }
    private func deleteRoutine(_ routine: RoutineDisplay) {
        if let source = routine.source {
            notificationService.cancelReminder(for: source)
            modelContext.delete(source)
        }
    }
    private func deleteAllRoutines() {
        notificationService.cancelAllReminders()
        routines.forEach(modelContext.delete)
    }

    @MainActor
    private func enableNotifications() async {
        let isAuthorized = await notificationService.requestAuthorization()
        await refreshNotificationAuthorization()

        guard isAuthorized else {
            notificationsEnabled = false
            routines.forEach { $0.isNotificationEnabled = false }
            return
        }

        notificationsEnabled = true
        routines.forEach { $0.isNotificationEnabled = true }
        await notificationService.scheduleReminders(for: routines)
    }

    private func disableNotifications() {
        notificationsEnabled = false
        routines.forEach { $0.isNotificationEnabled = false }
        notificationService.cancelAllReminders()
    }

    @MainActor
    private func refreshNotificationAuthorization() async {
        notificationAuthorizationState = await notificationService.authorizationState()

        if notificationAuthorizationState != .authorized {
            notificationsEnabled = false
            routines.forEach { $0.isNotificationEnabled = false }
            notificationService.cancelAllReminders()
        }
    }

    private func scheduleReminderIfNeeded(for routine: LaundryRoutine) {
        guard notificationsEnabled, notificationAuthorizationState == .authorized else {
            notificationService.cancelReminder(for: routine)
            return
        }

        Task {
            await notificationService.scheduleReminder(for: routine)
        }
    }

    private func scheduleAllRemindersIfPossible() async {
        guard notificationsEnabled, notificationAuthorizationState == .authorized else {
            return
        }

        await notificationService.scheduleReminders(for: routines)
    }
}

#Preview {
    ContentView().modelContainer(for: LaundryRoutine.self, inMemory: true)
}
