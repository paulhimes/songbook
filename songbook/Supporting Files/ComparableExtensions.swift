extension Comparable {

    /// Limits the receiver to the given range and returns the result.
    /// - Parameter range: The range of possible result values.
    /// - Returns: The limited value based on the receiver and the given range.
    func limited(_ range: ClosedRange<Self>) -> Self {
        min(range.upperBound, max(range.lowerBound, self))
    }

    /// Limits the receiver to the given range and returns the result.
    /// - Parameter range: The range of possible result values.
    /// - Returns: The limited value based on the receiver and the given range.
    func limited(_ range: Range<Self>) -> Self {
        min(range.upperBound, max(range.lowerBound, self))
    }
}
