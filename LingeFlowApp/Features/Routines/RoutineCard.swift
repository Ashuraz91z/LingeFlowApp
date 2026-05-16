import SwiftUI

struct RoutineCard: View {
    let routine: RoutineDisplay
    let onComplete: () -> Void
    let onEarlyCompletion: () -> Void
    @State private var isCompleting = false
    private var isCompleted: Bool { (routine.isDueToday && routine.isCompletedToday) || isCompleting }

    var body: some View {
        HStack(spacing: 16) {
            RoutineIcon(routine: routine)
            VStack(alignment: .leading, spacing: 5) {
                Text(routine.name).font(.system(size: 17, weight: .bold))
                Text("Tous les \(routine.frequencyDays) jours").font(.system(size: 14, weight: .medium))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Prochain rappel").font(.system(size: 13, weight: .medium)).foregroundStyle(Color.lingeMuted)
                    Text(routine.nextReminderText).font(.system(size: 14, weight: .bold)).foregroundStyle(Color.lingePurple)
                }.padding(.top, 4)
            }.foregroundStyle(Color.lingeInk)
            Spacer(minLength: 8)
            Button(action: handleCompleteTap) {
                HStack(spacing: 7) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "checkmark")
                    Text("Fait").font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(isCompleted ? .white : Color.lingePurple)
                .frame(width: 78, height: 47)
                .background {
                    if isCompleted {
                        LinearGradient(colors: [Color.lingeDoneStart, Color.lingeDoneEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        Color.white
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 13))
                .overlay { RoundedRectangle(cornerRadius: 13).stroke(isCompleted ? Color.white.opacity(0.22) : Color.lingePurple.opacity(0.35), lineWidth: 1.5) }
            }.buttonStyle(.plain)
        }
        .padding(.horizontal, 17).padding(.vertical, 18)
        .background(routine.isDueToday ? .white : .clear).clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: routine.isDueToday ? Color.black.opacity(0.05) : .clear, radius: 12, x: 0, y: 6)
    }
    private func handleCompleteTap() { routine.isDueToday ? completeWithAnimation() : onEarlyCompletion() }
    private func completeWithAnimation() {
        guard !isCompleted else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
            isCompleting = true
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(380))
            onComplete()
            isCompleting = false
        }
    }
}

struct RoutineIcon: View {
    let routine: RoutineDisplay
    var size: CGFloat = 68
    var body: some View {
        ZStack {
            if routine.assetName.isEmpty {
                RoundedRectangle(cornerRadius: 12).fill(routine.tint.opacity(0.13))
                Image(systemName: routine.systemImageName).font(.system(size: 31)).foregroundStyle(routine.tint)
            } else { Image(routine.assetName).resizable().scaledToFit() }
        }.frame(width: size, height: size)
    }
}
