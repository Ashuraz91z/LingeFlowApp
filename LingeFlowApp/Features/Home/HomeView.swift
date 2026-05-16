import SwiftUI

struct HomeView: View {
    let routines: [LaundryRoutine]
    let dueTodayRoutines: [RoutineDisplay]
    let upcomingRoutines: [RoutineDisplay]
    let routineMoveNamespace: Namespace.ID
    let onAddRoutine: () -> Void
    let onComplete: (RoutineDisplay) -> Void
    let onEarlyCompletion: (RoutineDisplay) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                Text("Linge Flow").font(.system(size: 34, weight: .bold, design: .rounded)).foregroundStyle(Color.lingeInk)
                if routines.isEmpty {
                    EmptyRoutineSection(onAddRoutine: onAddRoutine)
                } else {
                    RoutineSection(title: "À faire aujourd’hui") {
                        if dueTodayRoutines.isEmpty {
                            RoutinePlaceholderCard(message: "Rien à faire aujourd’hui")
                        } else {
                            VStack(spacing: 0) {
                                ForEach(dueTodayRoutines) { routine in
                                    RoutineCard(routine: routine, onComplete: { onComplete(routine) }, onEarlyCompletion: { onEarlyCompletion(routine) })
                                        .matchedGeometryEffect(id: routine.id, in: routineMoveNamespace)
                                        .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .move(edge: .trailing).combined(with: .opacity)))
                                }
                            }
                        }
                    }
                    if !upcomingRoutines.isEmpty {
                        RoutineSection(title: "À venir") {
                            VStack(spacing: 0) {
                                ForEach(upcomingRoutines) { routine in
                                    RoutineCard(routine: routine, onComplete: { onComplete(routine) }, onEarlyCompletion: { onEarlyCompletion(routine) })
                                        .matchedGeometryEffect(id: routine.id, in: routineMoveNamespace)
                                    if routine.id != upcomingRoutines.last?.id { Divider().padding(.leading, 96) }
                                }
                            }
                            .background(Color.lingeSurface).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
                            .overlay { RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.black.opacity(0.06), lineWidth: 1) }
                        }
                    }
                }
            }
            .padding(.horizontal, 20).padding(.top, 28).padding(.bottom, 24)
            .animation(.spring(response: 0.48, dampingFraction: 0.88), value: dueTodayRoutines.map(\.id))
            .animation(.spring(response: 0.48, dampingFraction: 0.88), value: upcomingRoutines.map(\.id))
        }
    }
}

struct RoutineSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(Color.lingeInk)
            content
        }
    }
}

struct EmptyRoutineSection: View {
    let onAddRoutine: () -> Void
    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 10) {
                Image(systemName: "basket").font(.system(size: 34)).foregroundStyle(Color.lingePurple)
                Text("Aucune routine enregistrée").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(Color.lingeInk)
                Text("Ajoute ta première routine pour suivre tes prochains lavages.").font(.system(size: 15, weight: .medium)).foregroundStyle(Color.lingeMuted).multilineTextAlignment(.center)
            }
            Button(action: onAddRoutine) {
                Text("Ajouter une routine").font(.system(size: 16, weight: .bold)).foregroundStyle(.white).frame(maxWidth: .infinity).frame(height: 52).background(Color.lingePurple).clipShape(RoundedRectangle(cornerRadius: 14))
            }.buttonStyle(.plain)
        }
        .padding(22).frame(maxWidth: .infinity).background(Color.lingeSurface).clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 6)
        .overlay { RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.06), lineWidth: 1) }
    }
}
