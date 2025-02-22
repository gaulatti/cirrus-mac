import Foundation

/// A struct representing the response for a timeline request.
///
/// This struct conforms to the `Codable` protocol, allowing it to be easily
/// encoded and decoded from JSON or other formats.
struct TimelineResponse: Codable {
    let cursor: String?
    let feed: [FeedItem]
}
