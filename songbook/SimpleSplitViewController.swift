//
//  SimpleSplitViewController.swift
//
//  Created by Paul Himes on 2/1/18.
//

import UIKit

class SimpleSplitViewController: UIViewController {

    @IBOutlet private weak var primaryContainer: UIView! {
        didSet {
            primaryContainer?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet private weak var secondaryContainer: UIView! {
        didSet {
            secondaryContainer?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet private weak var secondarySubContainer: UIView! {
        didSet {
            secondarySubContainer?.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private var primaryViewController: UIViewController? {
        didSet {
            primaryViewController?.viewRespectsSystemMinimumLayoutMargins = false
        }
    }
    private var secondaryViewController: UIViewController? {
        didSet {
            secondaryViewController?.viewRespectsSystemMinimumLayoutMargins = false
        }
    }

    private let dividerWidth: CGFloat = 1
    
    private(set) var isOpen = false

    func setOpen(_ open: Bool, animated: Bool) {
        isOpen = open

        // Show immidiately to make sure it's visible as it slides on screen.
        if isOpen {
            secondaryContainer.isHidden = false
        }

        if !animated {
            updateFrames()
            secondaryContainer.isHidden = !open // Set the resting state visibility.
        } else {
            // Duration and damping ratio were tuned to match the native iOS modal presentation animation.
            let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.99231, animations: { [weak self] in
                self?.updateFrames()
            })
            animator.addCompletion { [weak self] (position) in
                self?.secondaryContainer.isHidden = !open // Set the resting state visibility.
            }
            animator.startAnimation()
        }
    }

    private func updateFrames() {
        let maxSideSafeAreaInsets = max(view.safeAreaInsets.left, view.safeAreaInsets.right)
        let outsideInsets: CGFloat
        if maxSideSafeAreaInsets > 0 {
            outsideInsets = 0
        } else {
            outsideInsets = 16
        }
        let insideInsets: CGFloat = 16
        
        switch traitCollection.horizontalSizeClass {
        case .compact:
            // Secondary view is presented full screen.
            let secondaryWidth = view.bounds.size.width + dividerWidth
            if isOpen {
                secondaryContainer.frame = CGRect(x: 0, y: 0, width: secondaryWidth, height: view.bounds.size.height)
            } else {
                secondaryContainer.frame = CGRect(x: 0, y: view.bounds.size.height, width: secondaryWidth, height: view.bounds.size.height)
            }
            primaryContainer.frame = view.bounds

            primaryViewController?.view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: outsideInsets, bottom: 0, trailing: outsideInsets)
            secondaryViewController?.view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: outsideInsets, bottom: 0, trailing: outsideInsets)
        default:
            // Secondary view is presented as a left-side split view.
            let secondaryWidth = ceil(view.bounds.size.width * 1.0/3.0)
            if isOpen {
                primaryContainer.frame = CGRect(x: secondaryWidth, y: 0, width: view.bounds.size.width - secondaryWidth, height: view.bounds.size.height)
                secondaryContainer.frame = CGRect(x: 0, y: 0, width: secondaryWidth, height: view.bounds.size.height)
                primaryViewController?.view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: insideInsets, bottom: 0, trailing: outsideInsets)
            } else {
                primaryContainer.frame = view.bounds
                secondaryContainer.frame = CGRect(x: -secondaryWidth, y: 0, width: secondaryWidth, height: view.bounds.size.height)
                primaryViewController?.view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: outsideInsets, bottom: 0, trailing: outsideInsets)
            }
            secondaryViewController?.view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: outsideInsets, bottom: 0, trailing: insideInsets)
        }
        secondarySubContainer.frame = CGRect(x: 0, y: 0, width: secondaryContainer.bounds.size.width - dividerWidth, height: secondaryContainer.bounds.size.height)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Primary" {
            primaryViewController = segue.destination
        } else if segue.identifier == "Secondary" {
            secondaryViewController = segue.destination
        }
    }

    private var observation: NSKeyValueObservation?
    override func viewDidLoad() {
        super.viewDidLoad()
        observation = view.observe(\.frame) { [weak self] (view, changeValue) in
            guard let stelf = self else { return }
            stelf.setOpen(stelf.isOpen, animated: false)
        }
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        updateFrames()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setOpen(isOpen, animated: false)
    }
}

extension UIViewController {
    var simpleSplitViewController: SimpleSplitViewController? {
        get {
            if let simpleSplitViewController = parent as? SimpleSplitViewController {
                return simpleSplitViewController
            } else {
                return nil
            }
        }
    }
}
