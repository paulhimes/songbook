import SwiftUI

/// A container which vertically centers its subviews at a specified location based on a ratio
/// multiplier.
struct VerticalRatioLayout: Layout {

    // The location in the container, from 0 to 1, where the centers of the subviews should be
    // placed. Subviews will be placed as close as possible to this location without exceeding the
    // bounds of the container.
    let ratio: CGFloat

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        subviews.forEach {
            let sizeThatFits = $0.sizeThatFits(
                ProposedViewSize(width: bounds.width, height: bounds.height)
            )

            let idealCenter = bounds.minY + bounds.height * ratio
            let height = min(sizeThatFits.height, bounds.height)
            let width = min(sizeThatFits.width, bounds.width)
            let halfHeight = height / 2

            let top: CGFloat
            if idealCenter + halfHeight > bounds.height {
                // Move up.
                top = bounds.maxY - height
            } else if idealCenter - halfHeight < 0 {
                // Move down.
                top = bounds.minY
            } else {
                // Don't move.
                top = idealCenter - halfHeight
            }

            $0.place(
                at: CGPoint(x: bounds.origin.x, y: top),
                proposal: ProposedViewSize(width: width, height: height)
            )
        }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
}

extension CGFloat {
    static let phi = 1.61803399
}
