import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isLoggedIn {
                TimelineView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            loadAuthToken()
        }
    }
    
    private func loadAuthToken() {
        if let savedToken = KeychainManager.shared.retrieveAuthToken() {
            if !isTokenExpired(savedToken) {
                appState.authToken = savedToken
                appState.isLoggedIn = true
                print("Token loaded from Keychain")
            } else {
                print("Saved token is expired.")
            }
        } else {
            print("No saved token found.")
        }
    }
}
