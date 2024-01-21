import SwiftUI

/// The view for a partially matching search item.
struct PartialItemView: View {

    /// The action to perform when the item is tapped.
    let action: () -> Void

    /// The partially matching text followed by the remainder of the song text.
    let partialText: String

    /// The range of the highlighted portion of the text.
    let partialTextHighlight: ClosedRange<Int>
    
    /// A styled version of the partial text with the matching range highlighted in the accent
    /// color.
    private var attributedString: AttributedString {
        var attributed = AttributedString(partialText)
        attributed.foregroundColor = .secondary
        let highlightRangeStart = attributed.index(
            attributed.startIndex,
            offsetByCharacters: partialTextHighlight.lowerBound
        )
        let highlightRangeEnd = attributed.index(
            attributed.startIndex,
            offsetByCharacters: partialTextHighlight.upperBound
        )
        attributed[highlightRangeStart...highlightRangeEnd].foregroundColor = .accentColor
        return attributed
    }

    /// Initializes a ``PartialItemView``.
    /// - Parameters:
    ///   - partialText: The highlighted partially matching text in context.
    ///   - partialTextHighlight: The range of the highlighted portion of the text.
    ///   - action: The action to perform when the item is tapped.
    init(
        partialText: String,
        partialTextHighlight: ClosedRange<Int>,
        action: @escaping () -> Void
    ) {
        self.partialText = partialText
        self.partialTextHighlight = partialTextHighlight
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(attributedString)
                .lineLimit(1)
        }
    }
}

#Preview {
    PartialItemView(partialText: "Text", partialTextHighlight: 0...1, action: {})
}
