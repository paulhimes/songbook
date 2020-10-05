//
//  ExactMatchCell.swift
//  songbook
//
//  Created by Paul Himes on 1/23/18.
//

import UIKit

class ExactMatchCell: UITableViewCell {

    @objc @IBOutlet weak var sectionTitleLabel: UILabel!
    @objc @IBOutlet weak var numberLabel: UILabel! {
        didSet {
            updateNumberLabelForCurrentSizeCategory()
        }
    }
    @objc @IBOutlet weak var songTitleLabel: UILabel!
    @objc @IBOutlet weak var hiddenSpacerLabel: UILabel!
    @IBOutlet weak var lowerStackView: UIStackView! {
        didSet {
            updateLowerStackViewForCurrentSizeCategory()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(preferredSizeCategoryDidChange(notification:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(preferredSizeCategoryDidChange(notification:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    @objc func preferredSizeCategoryDidChange(notification: Notification) {
        updateLowerStackViewForCurrentSizeCategory()
        updateNumberLabelForCurrentSizeCategory()
    }
    
    private func updateLowerStackViewForCurrentSizeCategory() {
        if UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory {
            lowerStackView.axis = .vertical
            lowerStackView.alignment = .leading
            lowerStackView.spacing = 0
        } else {
            lowerStackView.axis = .horizontal
            lowerStackView.alignment = .firstBaseline
            lowerStackView.spacing = 10
        }
    }
    
    private func updateNumberLabelForCurrentSizeCategory() {
        if UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory {
            numberLabel.textAlignment = .natural
        } else {
            numberLabel.textAlignment = .right
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Theme.grayTrimColor
        self.selectedBackgroundView = selectedBackgroundView
        super.setSelected(selected, animated: animated)
    }
}
