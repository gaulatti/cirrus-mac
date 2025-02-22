import Foundation


/// A model representing a post.
/// Conforms to the `Codable` protocol to support encoding and decoding.
struct Post: Codable {
    let uri: String
    let cid: String
    let author: Actor
    let record: PostRecord
    let replyCount: Int?
    let repostCount: Int?
    let likeCount: Int?
    let quoteCount: Int?
    let indexedAt: Date?
}

