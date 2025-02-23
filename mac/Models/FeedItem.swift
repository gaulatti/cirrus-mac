import Foundation

/// Represents a single item in the timeline. Each item may contain either a post,
/// a reply, a reason (such as a repost), and an optional feedContext.
/// We use a computed property to generate a unique identifier.
struct FeedItem: Codable, Identifiable {
    let post: Post?
    let reply: Reply?
    let reason: Reason?
    let feedContext: String?

    var id: String {
        if let post = post {
            return post.cid
        } else {
            return UUID().uuidString
        }
    }
}
