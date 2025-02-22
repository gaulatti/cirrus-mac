import SwiftUI
import SwiftData

@main
struct macApp: App {
    @StateObject private var appState = AppState()
       
       var body: some Scene {
           WindowGroup {
               ContentView()
                   .environmentObject(appState)
           }
       }
}
