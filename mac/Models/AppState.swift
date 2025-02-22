import Foundation
import Combine

/// A class that conforms to the `ObservableObject` protocol and represents the state of the application.
/// This class is used to manage and publish changes to the app's state, allowing SwiftUI views to react to those changes.
class AppState: ObservableObject {
    // Whether the user is logged in.
    @Published var isLoggedIn: Bool = false
    // Store the authentication token.
    @Published var authToken: String? = nil
}
