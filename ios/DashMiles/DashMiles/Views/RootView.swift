import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            DashView()
                .tabItem { Label("Dash", systemImage: "car.fill") }

            HistoryView()
                .tabItem { Label("History", systemImage: "list.bullet.rectangle") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
