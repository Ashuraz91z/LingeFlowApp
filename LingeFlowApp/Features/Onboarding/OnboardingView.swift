import SwiftUI

struct OnboardingView: View {
    let onStart: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.lingeBackground.ignoresSafeArea()
            LinearGradient(colors: [.clear, Color.lingePurple.opacity(0.04)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer(minLength: 26)
                Image("OnboardingHero").resizable().scaledToFit().frame(maxWidth: 330).padding(.horizontal, 18)
                VStack(spacing: 12) {
                    Text("Ne pense plus\nà \(Text("ton linge").foregroundStyle(Color.lingePurple))")
                        .foregroundStyle(Color.lingeInk)
                        .font(.system(size: 31, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("Crée tes routines et reçois\nun rappel au bon moment")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.lingeMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.top, 8)
                Spacer()
                Button(action: onStart) {
                    Text("Commencer")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity).frame(height: 58)
                        .background(LinearGradient(colors: [Color.lingePurple, Color.lingeDoneEnd], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.lingePurple.opacity(0.24), radius: 14, x: 0, y: 8)
                }
                .buttonStyle(.plain).padding(.horizontal, 28).padding(.bottom, 38)
            }
        }
    }
}

#Preview {
    OnboardingView {}
}
