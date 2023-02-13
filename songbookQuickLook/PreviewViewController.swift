//
//  PreviewViewController.swift
//  songbookQuickLook
//
//  Created by Paul Himes on 2/5/23.
//

import SwiftUI
import UIKit
import QuickLook

class PreviewViewController: UIViewController, QLPreviewingController {

    let contentView = UIHostingController(rootView: PreviewView(title: "Songbook"))

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    /*
     * Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.
     *
    func preparePreviewOfSearchableItem(identifier: String, queryString: String?, completionHandler handler: @escaping (Error?) -> Void) {
        // Perform any setup necessary in order to prepare the view.
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        handler(nil)
    }
    */
    

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        contentView.rootView = PreviewView(
            title: url
                .lastPathComponent
                .components(separatedBy: ".")
                .dropLast(1)
                .joined(separator: ".")
        )

        // Add the supported content types to the QLSupportedContentTypes array in the Info.plist of the extension.
        
        // Perform any setup necessary in order to prepare the view.
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        handler(nil)
    }

}
