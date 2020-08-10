//
//  SettingsItemTextCell.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class SettingsItemTextCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var subTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectedBackgroundView = HighlightedCellView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(settingsItem: SettingsItem) {
        titleLabel.text = settingsItem.type.rawValue
        
        switch settingsItem.accessory {
        case .arrow:
            arrowImageView.isHidden = false
            subTextLabel.isHidden = true
        case .text(let text):
            arrowImageView.isHidden = true
            subTextLabel.isHidden = false
            subTextLabel.text = text
        case .none:
            arrowImageView.isHidden = true
            subTextLabel.isHidden = true
        }
        
    }
}
