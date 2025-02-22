import Foundation

/// `BlueskyClient` is a class responsible for handling network operations and interactions
/// with the Bluesky service. This class provides methods to perform various actions
/// such as fetching data, sending requests, and processing responses from the Bluesky API.
class BlueskyClient {
    static let shared = BlueskyClient()
    var authToken: String? = nil
    private let baseURL = URL(string: "https://bsky.social")!

    /// Logs in a user with the provided identifier and password.
    ///
    /// - Parameters:
    ///   - identifier: The user's identifier (e.g., username or email).
    ///   - password: The user's password.
    /// - Returns: A string representing the login token or session identifier.
    /// - Throws: An error if the login process fails.
    func login(identifier: String, password: String) async throws -> (String, String?) {
        let loginURL = baseURL.appendingPathComponent("/xrpc/com.atproto.server.createSession")
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "identifier": identifier,
            "password": password,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                let responseBody = String(data: data, encoding: .utf8) ?? "N/A"
                print("Login failed with HTTP status \(httpResponse.statusCode): \(responseBody)")
                throw URLError(.badServerResponse)
            }
        }

        // Decode the JSON response.
        let decoder = JSONDecoder()
        let loginResponse = try decoder.decode(LoginResponse.self, from: data)

        KeychainManager.shared.saveAuthTokens(
            authToken: loginResponse.accessJwt, refreshToken: loginResponse.refreshJwt)

        // Store the token for future requests.
        self.authToken = loginResponse.accessJwt
        return (loginResponse.accessJwt, loginResponse.refreshJwt)
    }

    /// Refreshes the current session and returns a new access token and an optional refresh token.
    ///
    /// - Returns: A tuple containing the new access token as a `String` and an optional refresh token as a `String?`.
    /// - Throws: An error if the session could not be refreshed.
    func refreshSession() async throws -> (String, String?) {
        guard let refreshToken = KeychainManager.shared.retrieveRefreshToken() else {
            throw NSError(
                domain: "BlueskyAPIClient", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No refresh token available."])
        }
        let refreshURL = baseURL.appendingPathComponent("/xrpc/com.atproto.server.refreshSession")
        var request = URLRequest(url: refreshURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "refreshToken": refreshToken
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, _) = try await URLSession.shared.data(for: request)

        struct RefreshResponse: Codable {
            let accessJwt: String
            let refreshJwt: String?
        }
        let decoder = JSONDecoder()
        // Use the same custom date strategy if necessary.
        let refreshResponse = try decoder.decode(RefreshResponse.self, from: data)

        // Save new tokens
        KeychainManager.shared.saveAuthTokens(
            authToken: refreshResponse.accessJwt,
            refreshToken: refreshResponse.refreshJwt)
        authToken = refreshResponse.accessJwt
        return (refreshResponse.accessJwt, refreshResponse.refreshJwt)
    }

    /// Fetches the timeline with a specified limit and optional cursor.
    ///
    /// - Parameters:
    ///   - limit: The maximum number of items to fetch. Defaults to 50.
    ///   - cursor: An optional cursor for pagination.
    /// - Returns: A `TimelineResponse` containing the fetched timeline data.
    /// - Throws: An error if the fetch operation fails.
    func fetchTimeline(limit: Int = 50, cursor: String? = nil) async throws -> TimelineResponse {
        // Ensure we have a token from memory or Keychain.
        if authToken == nil {
            authToken = KeychainManager.shared.retrieveAuthToken()
        }

        // Refresh the token if it's expired.
        if let token = authToken, isTokenExpired(token) {
            print("Token expired, refreshing...")
            _ = try await refreshSession()
        }

        // At this point, we must have a valid token.
        guard let token = authToken else {
            throw URLError(.userAuthenticationRequired)
        }

        // Build the URL with query items.
        var urlComponents = URLComponents(
            url: baseURL.appendingPathComponent("/xrpc/app.bsky.feed.getTimeline"),
            resolvingAgainstBaseURL: false
        )!
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        if let cursor = cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else { throw URLError(.badURL) }

        // Build the request.
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Execute the request.
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
            !(200...299).contains(httpResponse.statusCode)
        {
            let body = String(data: data, encoding: .utf8) ?? "N/A"
            print("Timeline fetch failed: HTTP \(httpResponse.statusCode) - \(body)")
            throw URLError(.badServerResponse)
        }

        // Decode the timeline response.
        let decoder = JSONDecoder()
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(dateString)")
        }
        return try decoder.decode(TimelineResponse.self, from: data)
    }

}
