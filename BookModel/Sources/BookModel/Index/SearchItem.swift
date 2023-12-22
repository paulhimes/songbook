import Foundation

/// An item that can be searched for.
public struct SearchItem: Equatable {
    /// The full text of the item.
    let fullText: String

    /// The number of the item.
    public let number: String?

    /// The index of the page containing this item.
    public let pageIndex: Int

    /// The title of the item.
    public let title: String

    /// Searchable tokens extracted form the item's text.
    let tokens: [SearchToken]
}
