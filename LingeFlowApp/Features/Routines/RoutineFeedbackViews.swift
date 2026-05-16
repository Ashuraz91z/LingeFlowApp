import SwiftUI

struct CompletionUndoBanner: View {
    let routineName: String; let onUndo: () -> Void
    var body: some View {
        HStack { Text("\(routineName) terminé").foregroundStyle(.white); Spacer(); Button("Annuler", action: onUndo).foregroundStyle(Color.lingeUndoText) }
            .padding(.horizontal, 16).frame(height: 54)
            .background(LinearGradient(colors: [Color.lingeDoneStart, Color.lingeDoneEnd], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct EarlyCompletionConfirmationDialog: View {
    let routineName: String; let onCancel: () -> Void; let onConfirm: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.28).ignoresSafeArea().onTapGesture(perform: onCancel)
            VStack(spacing: 16) {
                Text("Marquer comme faite ?").font(.title3.bold())
                Text("“\(routineName)” est prévue plus tard. La prochaine date sera recalculée depuis aujourd’hui.").multilineTextAlignment(.center)
                Button(action: onConfirm) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))

                        Text("Oui, marquer comme faite")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color.lingeDoneStart, Color.lingeDoneEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.lingeDoneEnd.opacity(0.24), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)

                Button(action: onCancel) {
                    Text("Annuler")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.lingeInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.lingeSearchBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }.padding(24).background(.white).clipShape(RoundedRectangle(cornerRadius: 24)).padding(24)
        }
    }
}
