//
//  ExactMatchCell.swift
//  songbook
//
//  Created by Paul Himes on 1/23/18.
//  Copyright © 2018 Paul Himes. All rights reserved.
//

import UIKit

class ExactMatchCell: UITableViewCell {

    @objc @IBOutlet weak var sectionTitleLabel: UILabel!
    @objc @IBOutlet weak var numberLabel: UILabel!
    @objc @IBOutlet weak var songTitleLabel: UILabel!
    @objc @IBOutlet weak var hiddenSpacerLabel: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Theme.grayTrimColor
        self.selectedBackgroundView = selectedBackgroundView
        super.setSelected(selected, animated: animated)
    }
}
