import SwiftUI
import UIKit
import QuickLook

class PreviewViewController: UIViewController, QLPreviewingController {

    /// A controller to host the SwiftUI View.
    let contentView = UIHostingController(rootView: PreviewView(title: "Songbook"))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Embed the SwiftUI controller view in the view of this controller.
        addChild(contentView)
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView.view)
        contentView.didMove(toParent: self)
        NSLayoutConstraint.activate(
            [
                contentView.view.topAnchor.constraint(equalTo: view.topAnchor),
                contentView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                contentView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ]
        )
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        // Update the SwiftUI view's title with the name of the file at the given `URL`.
        contentView.rootView = PreviewView(
            title: url
                .lastPathComponent
                .components(separatedBy: ".")
                .dropLast(1)
                .joined(separator: ".")
        )

        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        handler(nil)
    }

}
