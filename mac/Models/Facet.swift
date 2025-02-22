import Foundation


/// A model representing a facet, which conforms to the `Codable` protocol.
/// This allows instances of `Facet` to be encoded and decoded for data transfer or storage.
struct Facet: Codable {
    let features: [FacetFeature]
    let index: FacetIndex
}
