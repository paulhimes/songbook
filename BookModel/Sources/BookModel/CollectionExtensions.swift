extension Collection {
    /// Flat maps the `Collection` by performing the given transform on each element in parallel.
    ///
    /// - Parameter transform: The transformation which results in an `Array<T>` for each `Element`
    ///   in the `Collection`.
    /// - Returns: The `Collection` flat mapped to a single `Array<T>`.
    ///
    func parallelFlatMap<T: Sendable>(
        _ transform: @escaping (Element) async throws -> [T]
    ) async rethrows -> [T] where Self: Sendable, Element: Sendable {
        let n = count

        // Make sure there is work to do.
        guard n > 0 else {
            return []
        }

        // Use a task group to await all the results of multiple tasks. Each task is expected to
        // return a tuple containing an integer index and a transformed value.
        return try await withThrowingTaskGroup(of: (Int, [T]).self, returning: [T].self) { group in

            // Allocate an array of arrays of the same size as the original collection.
            var result = [[T]](repeatElement([], count: n))

            var i = self.startIndex
            var submitted = 0
            var completed = 0

            while i < self.endIndex {
                let element = self[i]
                group.addTask { [submitted] in
                    let value = try await transform(element)
                    return (submitted, value)
                }
                formIndex(after: &i)
                submitted += 1
            }

            // As each task completes, save the result.
            for try await (index, taskResult) in group {
                result[index] = taskResult
                completed += 1
                try Task.checkCancellation()
            }

            return Array(result.flatMap { $0 })
        }
    }
}
