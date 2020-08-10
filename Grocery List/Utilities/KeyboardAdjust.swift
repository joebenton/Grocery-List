//
//  KeyboardAdjust.swift
//  WebiLog
//
//  Created by Joe Benton on 15/05/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

public class KeyboardAdjust: NSObject {
    @IBOutlet public weak var scrollView: UIScrollView!
    public var keyboardPadding: CGFloat = 0

    public init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init()
        addKeyboardObservers()
    }

    private func addKeyboardObservers() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = scrollView.convert(keyboardScreenEndFrame, from: scrollView.window)

        var insets = scrollView.contentInset
        insets.bottom = keyboardViewEndFrame.size.height + keyboardPadding
        scrollView.contentInset = insets

        insets = scrollView.verticalScrollIndicatorInsets
        insets.bottom = keyboardViewEndFrame.size.height + keyboardPadding
        scrollView.scrollIndicatorInsets = insets

        let curveValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)!.intValue
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)!.doubleValue

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(curveValue)),
                       animations: {
                        self.scrollView.scrollToActiveField(animated: true)
                                   },
                       completion: nil)
    }

    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}
