import Foundation

public extension URL {
    static let book = bookDirectory.appending(component: "book.json")
    static let bookDirectory = documentsDirectory.appending(component: "book")
    static let bookWithoutTunesDirectory = bookDirectory.appending(component: "bookWithoutTunes")
    static let bookWithTunesDirectory = bookDirectory.appending(component: "bookWithTunes")
    static let defaultBook = Bundle.module.url(
        forResource: "default",
        withExtension: "songbook"
    )!

    /// `true` iff the ``URL`` points to a directory rather than a file.
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }

    /// `true` iff the `URL` points to a file in the app bundle.
    var isInBundle: Bool {
        path(percentEncoded: false).hasPrefix(
            Bundle(for: BookModel.self).bundleURL.path(percentEncoded: false)
        )
    }
}
