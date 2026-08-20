import SwiftUI

@main
struct DashMilesApp: App {
    @StateObject private var store = ShiftStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
        .onChange(of: scenePhase) { _, phase in
            // Get an in-progress dash onto disk before iOS can terminate us.
            if phase != .active { store.flush() }
        }
    }
}
