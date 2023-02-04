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
}
