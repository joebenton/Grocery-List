//
//  FormFieldTextField.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

@IBDesignable
class FormFieldTextField: UITextField, FormField {
    var fieldDelegate: UITextFieldDelegate?
    
    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    var maxCharacters: Int?
    
    override var delegate: UITextFieldDelegate? {
        get { return fieldDelegate }
        set { fieldDelegate = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override var placeholder: String? {
        didSet {
            stylePlaceholder()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateStyle()
        }
    }

    fileprivate func setup() {
        super.delegate = self
        
        backgroundColor = UIColor.white
        
        layer.cornerRadius = 5
        clipsToBounds = true
        
        layer.borderWidth = 0.3
        layer.borderColor = (UIColor(named: "zenGrey") ?? UIColor.lightGray).cgColor
        
        stylePlaceholder()
        
        updateStyle()
        
        addDoneToolbar()
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    fileprivate func stylePlaceholder() {
        let placeholderString = placeholder ?? ""
        attributedPlaceholder = NSAttributedString(string: placeholderString,
                                                   attributes: [NSAttributedString.Key.foregroundColor: (UIColor(named: "zenGrey") ?? UIColor.gray)])
    }
    
    func updateStyle() {
        if isEnabled {
            textColor = UIColor(named: "zenBlack") ?? UIColor.black
        } else {
            textColor = (UIColor(named: "zenBlack") ?? UIColor.black).withAlphaComponent(0.6)
        }
        tintColor = UIColor(named: "zenBlue") ?? UIColor.blue
    }
    
    func setText(text: String) {
        self.text = text
    }
    
    func getText() -> String {
        return text ?? ""
    }
}

extension FormFieldTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.textFieldDidBeginEditing?(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.delegate?.textFieldShouldReturn?(self) ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let maxCharacters = maxCharacters {
            let oldLength = textField.text?.count ?? 0
            let replacementLength = string.count
            let rangeLength = range.length

            let newLength = oldLength - rangeLength + replacementLength

            let pressedReturnKey = string.contains("\n")

            return (newLength <= maxCharacters) || pressedReturnKey
        }
        
        return self.delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}
