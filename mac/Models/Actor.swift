import Foundation

/// A model representing an actor, conforming to the `Codable` protocol.
/// This struct can be used to encode and decode actor data.
struct Actor: Codable {
    let did: String
    let handle: String
    let displayName: String?
    let avatar: String?
    let createdAt: Date?
}

