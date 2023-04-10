/// Models a page in the book UI. Allows book cover, section, and song pages to exist together in an
/// array of pages.
public enum PageModel {
    /// The book cover page.
    case book(title: String, version: Int)
    /// A section title page.
    case section(title: String)
    /// A song page.
    case song(title: String)
}
