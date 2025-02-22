import Foundation

/// A struct representing a facet index, conforming to the `Codable` protocol.
/// This struct is used to encode and decode facet index data.
struct FacetIndex: Codable {
    let byteEnd: Int
    let byteStart: Int
}
