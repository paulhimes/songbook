import CoreTransferable
import UniformTypeIdentifiers

public struct Songbook: Transferable {
    let url: URL
    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .songbook) { songbook in
            SentTransferredFile(songbook.url)
        }
        ProxyRepresentation { songbook in
            return "Proxy!"
        }
    }

    public init(url: URL) {
        self.url = url
    }
}

extension UTType {
    static var songbook: UTType { .init(exportedAs: "com.paulhimes.songbook.songbook") }
}
