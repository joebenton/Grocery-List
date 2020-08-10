//
//  ItemCell.swift
//  Grocery List
//
//  Created by Joe Benton on 26/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol ItemCellDelegate: class {
    func didPressCheckedBtn(item: Item, checked: Bool)
}

class ItemCell: SwipeTableViewCell {

    weak var itemDelegate: ItemCellDelegate?
    var item: Item?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var checkedBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(item: Item) {
        self.item = item
        
        switch item.checked {
        case true:
            let image = UIImage(named: "ic_checkbox_ticked")
            checkedBtn.setImage(image, for: .normal)
            checkedBtn.setImage(image, for: .selected)
            
            nameLabel.textColor = UIColor(named: "zenGrey")
            qtyLabel.textColor = UIColor(named: "zenGrey")
            
            let nameAttributeString: NSMutableAttributedString =  NSMutableAttributedString(string: item.name)
                nameAttributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, nameAttributeString.length))
            nameLabel.attributedText = nameAttributeString
            let qtyAttributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(item.quantity) \(item.unitType.description)")
                qtyAttributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, qtyAttributeString.length))
            qtyLabel.attributedText =  qtyAttributeString
        case false:
            let image = UIImage(named: "ic_checkbox")
            checkedBtn.setImage(image, for: .normal)
            checkedBtn.setImage(image, for: .selected)
            
            nameLabel.textColor = UIColor(named: "zenBlack")
            qtyLabel.textColor = UIColor(named: "zenBlack")
            
            nameLabel.attributedText = nil
            qtyLabel.attributedText = nil
            nameLabel.text = item.name
            qtyLabel.text = "\(item.quantity) \(item.unitType.description)"

        }
    }
    
    @IBAction func checkedBtnPressed(_ sender: Any) {
        guard let item = self.item else { return }
        let checked = !item.checked
        itemDelegate?.didPressCheckedBtn(item: item, checked: checked)
    }
}
