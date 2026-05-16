import SwiftUI

enum MainTab: CaseIterable, Identifiable {
    case home, routines, settings
    var id: Self { self }
    var title: String {
        switch self { case .home: "Accueil"; case .routines: "Routines"; case .settings: "Réglages" }
    }
    var iconName: String {
        switch self { case .home: "house.fill"; case .routines: "list.bullet"; case .settings: "gearshape" }
    }
}

struct MainTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack {
            ForEach(MainTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) { selectedTab = tab }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.iconName).font(.system(size: 22, weight: .semibold))
                        Text(tab.title).font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(selectedTab == tab ? Color.lingePurple : Color.lingeTabMuted)
                    .frame(maxWidth: .infinity).frame(height: 56).contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18).padding(.top, 8).padding(.bottom, 10)
        .background(.white)
        .overlay(alignment: .top) { Divider().opacity(0.35) }
    }
}
