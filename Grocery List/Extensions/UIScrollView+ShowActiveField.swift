//
//  UIScrollView+ShowActiveField.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

extension UIScrollView {
    func scrollToActiveField(animated: Bool) {
        guard let firstResponderView = self.firstResponder else { return }
        let targetRect = convert(firstResponderView.frame, from: firstResponderView.superview)
        scrollRectToVisible(targetRect, animated: animated)
    }
}
