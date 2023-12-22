struct SearchToken: Equatable {
    let endIndex: Int
    let startIndex: Int
    let text: String

    init(text: String, startIndex: Int, endIndex: Int) {
        self.text = text.folding(
            options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
            locale: .current
        )
        self.startIndex = startIndex
        self.endIndex = endIndex
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return rhs.text.hasPrefix(lhs.text)
    }
}
