import Foundation

/// A struct representing a facet feature.
///
/// This struct conforms to the `Codable` protocol, allowing it to be easily encoded and decoded.
///
/// - Note: The exact properties and functionality of this struct are not provided in the selection.
struct FacetFeature: Codable {
    let type: String

    private enum CodingKeys: String, CodingKey {
        case type = "$type"
    }
}
