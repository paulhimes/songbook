import Foundation

final class UserDefaultsObserver: NSObject {

    /// Called when the given key is set.
    private let handler: () -> Void

    /// The key to observe.
    private let key: String

    /// Initialize a ``UserDefaultsObserver`` with a key and handler.
    /// - Parameters:
    ///   - key: The key of the value to observe.
    ///   - handler: Called when the value is set.
    init(key: String, handler: @escaping () -> Void) {
        self.handler = handler
        self.key = key
        super.init()
        UserDefaults.standard.addObserver(
            self,
            forKeyPath: key,
            options: [.initial, .new],
            context: nil
        )
    }

    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: key)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        handler()
    }
}
