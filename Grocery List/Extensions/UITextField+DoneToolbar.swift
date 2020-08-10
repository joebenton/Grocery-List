//
//  UITextField+DoneToolbar.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//


import UIKit

extension UITextField {
    func createDoneToolbar() -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(named: "zenBlack")
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }
    
    func addDoneToolbar() {
        inputAccessoryView = createDoneToolbar()
    }
    
    func removeDoneToolbar() {
        inputAccessoryView = nil
    }
    
    @objc func donePressed() {
        endEditing(true)
    }
}

extension UITextView {
    func createDoneToolbar() -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(named: "zenBlack")
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }
    
    func addDoneToolbar() {
        inputAccessoryView = createDoneToolbar()
    }
    
    func removeDoneToolbar() {
        inputAccessoryView = nil
    }
    
    @objc func donePressed() {
        endEditing(true)
    }
}
