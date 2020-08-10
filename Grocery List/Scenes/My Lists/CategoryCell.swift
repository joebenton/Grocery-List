//
//  CategoryCell.swift
//  Grocery List
//
//  Created by Joe Benton on 01/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var listCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedBackgroundView = nil
        
        wrapperView.layer.cornerRadius = 4
        wrapperView.clipsToBounds = true
        
        layer.shadowRadius = 6
        layer.shadowColor = UIColor(red: 175/255, green: 175/255, blue: 175/255, alpha: 1.0).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.25
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.shadowPath = CGPath(roundedRect: wrapperView.frame, cornerWidth: 4, cornerHeight: 4, transform: nil)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            wrapperView.backgroundColor = UIColor(named: "zenLightGrey")
        } else {
            wrapperView.backgroundColor = UIColor.white
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            wrapperView.backgroundColor = UIColor(named: "zenLightGrey")
        } else {
            wrapperView.backgroundColor = UIColor.white
        }
    }

    func configure(category: ListCategory) {
        nameLabel.text = category.type.rawValue
        
        listCountLabel.text = "\(category.itemsCount)"
        
        switch category.type {
        case .all:
            iconImageView.image = UIImage(named: "ic_category_all")
        case .dueToday:
            iconImageView.image = UIImage(named: "ic_category_dueToday")
        case .dueThisWeek:
            iconImageView.image = UIImage(named: "ic_category_dueThisWeek")
        case .vip:
            iconImageView.image = UIImage(named: "ic_category_vip")
        case .shared:
            iconImageView.image = UIImage(named: "ic_category_shared")
        case .completed:
            iconImageView.image = UIImage(named: "ic_category_completed")
        }
    }
}
