//
//  BookViewController.swift
//  songbook
//
//  Created by Paul Himes on 2/7/18.
//

import UIKit

class BookViewController: SimpleSplitViewController, SearchViewControllerDelegate, PageContainerViewControllerDelegate {

    @objc var coreDataStack: CoreDataStack?
    
    private var pageContainerViewController: PageContainerViewController?
    private var searchViewController: SearchViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let pageContainerViewController = segue.destination as? PageContainerViewController {
            self.pageContainerViewController = pageContainerViewController
            pageContainerViewController.delegate = self
            pageContainerViewController.coreDataStack = coreDataStack
            if let searchViewController = searchViewController {
                searchViewController.closestSongID = pageContainerViewController.closestSongID
            }
        }
        if let searchViewController = segue.destination as? SearchViewController {
            self.searchViewController = searchViewController
            searchViewController.delegate = self
            searchViewController.coreDataStack = coreDataStack
            if let pageContainerViewController = pageContainerViewController {
                searchViewController.closestSongID = pageContainerViewController.closestSongID
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateThemedElements), name: UserDefaults.didChangeNotification, object: nil)
        updateThemedElements()
    }
    
    @objc private func updateThemedElements() {
        DispatchQueue.main.async { [weak self] in
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [], animations: {
                self?.pageContainerViewController?.updateThemedElements()
                self?.searchViewController?.updateThemedElements()
                self?.view.backgroundColor = Theme.grayTrimColor
            }, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    // MARK: - SearchViewControllerDelegate
    func searchCancelled(_ searchViewController: SearchViewController!) {
        setOpen(false, animated: true)
    }
    
    func searchViewController(_ searchViewController: SearchViewController!, selectedSong selectedSongID: NSManagedObjectID!, with range: NSRange) {
        self.pageContainerViewController?.selectSong(selectedSongID, with: range)
        
        if traitCollection.horizontalSizeClass == .compact {
            setOpen(false, animated: true)
        }
    }
    
    // MARK: - PageContainerViewControllerDelegate
    func search(_ pageContainerViewController: PageContainerViewController!) {
        if isOpen {
            searchViewController?.endSearch()
            setOpen(false, animated: true)
        } else {
            searchViewController?.closestSongID = pageContainerViewController.closestSongID
            searchViewController?.beginSearch()
            setOpen(true, animated: true)
        }
    }
}
