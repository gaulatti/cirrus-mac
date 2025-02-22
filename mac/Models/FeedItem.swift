import Foundation

/// Represents a single item in the timeline. Each item may contain either a post,
/// a reply, a reason (such as a repost), and an optional feedContext.
/// We use a computed property to generate a unique identifier.
struct FeedItem: Codable, Identifiable {
    let post: Post?
    let reply: Reply?
    let reason: Reason?
    let feedContext: String?

    // Compute a unique identifier:
    // If the item has a post, use its URI.
    // Otherwise, if there's a reason, use the actor's DID.
    // Otherwise, fall back to feedContext or a generated UUID.
    var id: String {
        if let post = post {
            return post.uri
        } else if let reason = reason {
            return reason.by.did
        } else if let context = feedContext, !context.isEmpty {
            return context
        } else {
            return UUID().uuidString
        }
    }
}
