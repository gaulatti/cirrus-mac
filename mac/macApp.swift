import SwiftData
import SwiftUI

@main
struct macApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        window.title = "Cirrus"
                    }
                }
        }
    }
}
