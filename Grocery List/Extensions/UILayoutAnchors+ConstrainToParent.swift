//
//  UILayoutAnchors+ConstrainToParent.swift
//  Grocery List
//
//  Created by Joe Benton on 23/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

extension UIView {
    func constraintToParent(parent: UIView) {
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
    }
}
