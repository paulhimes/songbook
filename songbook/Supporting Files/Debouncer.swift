import Combine
import Foundation

/// Executes the last submitted closure after a debounce period in seconds.
final class Debouncer {

    /// The interval in seconds at which to debounce execution.
    private let seconds: TimeInterval

    /// A `Combine` subject used to build a debouncing pipeline.
    private let subject = PassthroughSubject<() -> Void, Never>()

    /// Holds a reference to the `Combine` pipeline.
    private var subscription: AnyCancellable?

    /// Initialize a ``Debouncer`` with an interval.
    /// - Parameters:
    ///   - seconds: The interval in seconds at which to debounce execution.
    init(seconds: TimeInterval) {
        self.seconds = seconds
    }

    /// Submits a job to run. Only the last submitted closure will be run after the configured
    /// debounce interval.
    /// - Parameter job: The job to run.
    func run(_ job: @escaping () -> Void) {
        if subscription == nil {
            subscription = subject
                .debounce(for: .seconds(seconds), scheduler: DispatchQueue.main)
                .sink { job in
                    job()
                }
        }

        subject.send(job)
    }
}
