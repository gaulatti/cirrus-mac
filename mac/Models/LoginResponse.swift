/// A struct representing the response received after a login attempt.
/// Conforms to the `Codable` protocol to support encoding and decoding.
struct LoginResponse: Codable {
    let accessJwt: String
    let refreshJwt: String?
}
