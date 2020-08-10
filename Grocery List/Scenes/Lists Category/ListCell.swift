//
//  ListCell.swift
//  Grocery List
//
//  Created by Joe Benton on 26/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import SwipeCellKit

class ListCell: SwipeTableViewCell {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var colourBar: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemsCountLabel: UILabel!
    
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

    func configure(list: List, categoryType: ListsCategoryType) {
        nameLabel.text = list.name
        
        itemsCountLabel.text = "\(list.itemsCount)"
        
        if let dueDate = list.dueDate, dueDateIsToday(dueDate: dueDate) {
            colourBar.backgroundColor = UIColor(named: "zenRed")
        } else {
            colourBar.backgroundColor = UIColor.clear
        }
    }
    
    fileprivate func dueDateIsToday(dueDate: Date) -> Bool {
        return Int(dueDate.timeIntervalSince1970) > Int(Date().startOfDay.timeIntervalSince1970) && Int(dueDate.timeIntervalSince1970) <= Int(Date().endOfDay.timeIntervalSince1970)
    }
}
