import UIKit
import QuickLookThumbnailing

class ThumbnailProvider: QLThumbnailProvider {
    override func provideThumbnail(
        for request: QLFileThumbnailRequest,
        _ handler: @escaping (QLThumbnailReply?, Error?) -> Void
    ) {
        handler(
            QLThumbnailReply(
                imageFileURL: Bundle.main.url(forResource: "Icon", withExtension: "png")!
            ),
            nil
        )
    }
}
