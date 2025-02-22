import Foundation

/// Represents the reason why an item appears in the feed (for instance, as a repost).
struct Reason: Codable {
    let by: Actor
    let createdAt: Date?
}
