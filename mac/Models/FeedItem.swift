import Foundation

/// Represents a single item in the timeline. Each item may contain either a post,
/// a reply, a reason (such as a repost), and an optional feedContext.
/// We use a computed property to generate a unique identifier.
struct FeedItem: Codable, Identifiable, Equatable {
    let post: Post?
    let reply: Reply?
    let reason: Reason?
    let feedContext: String?

    var id: String {
        post?.cid ?? "missing-post-\(reason?.by.did ?? UUID().uuidString)"
    }

    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        return lhs.id == rhs.id
    }
}
