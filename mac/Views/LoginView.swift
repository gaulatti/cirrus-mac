//
//  LoginView.swift
//  mac
//
//  Created by Javier Godoy Núñez on 2/22/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var identifier: String = ""
    @State private var password: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var loginError: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Cirrus Login")
                .font(.largeTitle)
            
            TextField("Identifier (e.g., handle.example.com)", text: $identifier)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let error = loginError {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                Task {
                    await login()
                }
            }) {
                if isLoggingIn {
                    ProgressView()
                } else {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(identifier.isEmpty || password.isEmpty || isLoggingIn)
            .padding(.top, 10)
        }
        .padding()
    }
    
    private func login() async {
        isLoggingIn = true
        loginError = nil
        
        do {
            // Call the login method from our API client.
            // It returns a tuple: (accessToken, refreshToken)
            let (accessToken, _) = try await BlueskyClient.shared.login(identifier: identifier, password: password)
            
            // Update the shared app state on the main thread.
            await MainActor.run {
                appState.authToken = accessToken
                appState.isLoggedIn = true
            }
        } catch {
            await MainActor.run {
                loginError = "Login failed. Please check your credentials."
            }
        }
        
        isLoggingIn = false
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
    }
}
