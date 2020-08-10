//
//  PrimaryButton.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

@IBDesignable
class PrimaryButton: UIButton {

    var padding = UIEdgeInsets(top: 17, left: 10, bottom: 17, right: 10) {
        didSet {
            titleEdgeInsets = padding
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCornerRadius()
    }
    
    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize
        return CGSize(width: originalSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: originalSize.height + titleEdgeInsets.top
            + titleEdgeInsets.bottom)
    }
    
    fileprivate func setup() {
        backgroundColor = UIColor(named: "zenBlue") ?? UIColor.blue
        
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                
        titleEdgeInsets = padding
        
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.white, for: .selected)
        setTitleColor(UIColor.white.withAlphaComponent(0.2), for: .disabled)
    }
    
    fileprivate func updateCornerRadius() {
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    func toggleEnabled(enabled: Bool) {
        switch enabled {
        case true:
            isEnabled = true
        case false:
            isEnabled = false
        }
    }

}

