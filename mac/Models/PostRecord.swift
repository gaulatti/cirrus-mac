import Foundation

/// A structure representing a post record.
/// Conforms to the `Codable` protocol to support encoding and decoding.
struct PostRecord: Codable {
    let type: String
    let createdAt: Date
    let facets: [Facet]?
    let text: String?

    private enum CodingKeys: String, CodingKey {
        case type = "$type"
        case createdAt
        case facets
        case text
    }
}
