import SwiftUI

struct RoutinesView: View {
    let displayedRoutines: [RoutineDisplay]
    @Binding var searchText: String
    let onAddRoutine: () -> Void
    let onEdit: (RoutineDisplay) -> Void
    let onDelete: (RoutineDisplay) -> Void

    private var filteredRoutines: [RoutineDisplay] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty ? displayedRoutines : displayedRoutines.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 18) {
                Text("Mes routines").font(.system(size: 34, weight: .bold, design: .rounded)).foregroundStyle(Color.lingeInk)
                RoutineSearchField(text: $searchText)
                if filteredRoutines.isEmpty {
                    RoutinePlaceholderCard(message: displayedRoutines.isEmpty ? "Aucune routine enregistrée" : "Aucune routine trouvée")
                } else {
                    VStack(spacing: 0) {
                        ForEach(filteredRoutines) { routine in
                            SwipeableRoutineRow(routine: routine, onEdit: { onEdit(routine) }, onDelete: { onDelete(routine) })
                            if routine.id != filteredRoutines.last?.id { Divider().padding(.leading, 86) }
                        }
                    }
                    .background(.white).clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay { RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.06), lineWidth: 1) }
                }
                AddRoutineButton(onAddRoutine: onAddRoutine)
            }
            .padding(.horizontal, 20).padding(.top, 28).padding(.bottom, 24)
        }
    }
}

struct RoutinePlaceholderCard: View {
    let message: String
    var body: some View {
        Text(message).font(.system(size: 15, weight: .medium)).foregroundStyle(Color.lingeMuted).frame(maxWidth: .infinity, alignment: .leading)
            .padding(18).background(.white).clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay { RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.06), lineWidth: 1) }
    }
}

private struct RoutineSearchField: View {
    @Binding var text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").font(.system(size: 17, weight: .semibold)).foregroundStyle(Color.lingeMuted)
            TextField("Rechercher une routine", text: $text).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.lingeInk).textFieldStyle(.plain)
        }.padding(.horizontal, 14).frame(height: 44).background(Color.lingeSearchBackground).clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AddRoutineButton: View {
    let onAddRoutine: () -> Void
    var body: some View {
        Button(action: onAddRoutine) {
            HStack(spacing: 14) {
                ZStack { Circle().fill(.white.opacity(0.18)); Image(systemName: "plus").font(.system(size: 18, weight: .bold)) }.frame(width: 38, height: 38)
                Text("Ajouter une routine").font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .bold)).opacity(0.78)
            }
            .foregroundStyle(.white).padding(.horizontal, 14).frame(maxWidth: .infinity).frame(height: 62)
            .background(LinearGradient(colors: [Color.lingePurple, Color.lingeDoneEnd], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 18)).shadow(color: Color.lingePurple.opacity(0.28), radius: 15, x: 0, y: 8)
        }.buttonStyle(.plain)
    }
}

private struct SwipeableRoutineRow: View {
    let routine: RoutineDisplay; let onEdit: () -> Void; let onDelete: () -> Void
    @State private var offsetX: CGFloat = 0; @State private var isDeleting = false
    private let deleteWidth: CGFloat = 112; private let rowHeight: CGFloat = 82
    var body: some View {
        RoutineListRow(routine: routine).contentShape(Rectangle()).frame(height: rowHeight).frame(maxWidth: .infinity)
            .onTapGesture { offsetX == 0 ? onEdit() : close() }
            .overlay(alignment: .trailing) {
                Button(action: deleteWithAnimation) {
                    VStack(spacing: 6) { Image(systemName: "trash.fill"); Text("Supprimer").font(.system(size: 12, weight: .bold)) }
                        .foregroundStyle(.white).frame(width: deleteWidth, height: rowHeight)
                        .background(LinearGradient(colors: [Color.lingeDestructive, Color.lingeDestructiveDark], startPoint: .topLeading, endPoint: .bottomTrailing))
                }.buttonStyle(.plain).offset(x: deleteWidth + offsetX).frame(width: deleteWidth, height: rowHeight).clipped()
            }
            .frame(height: isDeleting ? 0 : rowHeight).opacity(isDeleting ? 0 : 1).offset(x: isDeleting ? -28 : 0)
            .gesture(DragGesture(minimumDistance: 10).onChanged { value in
                guard !isDeleting, abs(value.translation.width) > abs(value.translation.height) else { return }
                offsetX = min(0, max(-deleteWidth, (offsetX == -deleteWidth ? -deleteWidth : 0) + value.translation.width))
            }.onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                withAnimation(.spring(response: 0.36, dampingFraction: 0.84)) { offsetX = value.predictedEndTranslation.width < -46 || offsetX < -deleteWidth / 2 ? -deleteWidth : 0 }
            }).clipped()
    }
    private func close() { withAnimation { offsetX = 0 } }
    private func deleteWithAnimation() { withAnimation { offsetX = -deleteWidth; isDeleting = true }; DispatchQueue.main.asyncAfter(deadline: .now() + 0.24, execute: onDelete) }
}

private struct RoutineListRow: View {
    let routine: RoutineDisplay
    var body: some View {
        HStack(spacing: 16) {
            RoutineIcon(routine: routine, size: 58)
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.name).font(.system(size: 15, weight: .bold))
                Text("Tous les \(routine.frequencyDays) jours").font(.system(size: 12, weight: .bold))
                Text(routine.nextReminderText).font(.system(size: 12, weight: .bold)).foregroundStyle(Color.lingePurple)
            }.foregroundStyle(Color.lingeInk)
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(Color.lingeTabMuted)
        }.padding(.horizontal, 18).padding(.vertical, 12).background(.white)
    }
}
