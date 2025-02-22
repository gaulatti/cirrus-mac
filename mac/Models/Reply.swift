import Foundation

/// Contains reply information. For example, if the feed item is a reply,
/// the grandparentAuthor might be provided.
struct Reply: Codable {
    let grandparentAuthor: Actor?
}
