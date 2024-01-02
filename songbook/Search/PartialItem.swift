import SwiftUI

/// The view for a partially matching search item.
struct PartialItem: View {

    /// The action to perform when the item is tapped.
    let action: () -> Void

    /// The highlighted partially matching text in context.
    let partialText: AttributedString
    
    /// Initializes a ``PartialItem``.
    /// - Parameters:
    ///   - partialText: The highlighted partially matching text in context.
    ///   - action: The action to perform when the item is tapped.
    init(partialText: AttributedString, action: @escaping () -> Void) {
        self.partialText = partialText
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(partialText)
                .lineLimit(1)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    PartialItem(partialText: "Text", action: {})
}
