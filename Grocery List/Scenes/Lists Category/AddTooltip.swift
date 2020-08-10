//
//  AddTooltip.swift
//  Grocery List
//
//  Created by Joe Benton on 29/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class AddTooltip: UIView {

    @IBOutlet weak var containerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        xibSetup()
    }
    
    fileprivate func xibSetup() {
        backgroundColor = UIColor.clear
        containerView = loadNib()
        containerView.frame = bounds
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }

}
