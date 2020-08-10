//
//  FormFieldTextView.swift
//  Grocery List
//
//  Created by Joe Benton on 29/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

@IBDesignable
class FormFieldTextView: UITextView, FormField {
    let padding = UIEdgeInsets(top: 15, left: 12, bottom: 15, right: 12)
    var placeholderLabel = UILabel()
    var fieldDelegate: UITextFieldDelegate?
    var maxCharacters: Int?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    var placeholder: String? {
        didSet {
            stylePlaceholder()
        }
    }

    fileprivate func setup() {
        backgroundColor = UIColor.white
        
        layer.cornerRadius = 5
        clipsToBounds = true
        
        layer.borderWidth = 0.3
        layer.borderColor = (UIColor(named: "zenGrey") ?? UIColor.lightGray).cgColor
        
        textContainerInset = padding
        
        tintColor = UIColor(named:"zenBlue")
        
        font = UIFont.systemFont(ofSize: 17)
        textColor = UIColor(named: "zenBlack")
        
        stylePlaceholder()
        
        addDoneToolbar()
        
        delegate = self
        placeholderLabel.font = UIFont.systemFont(ofSize: 17)
        placeholderLabel.textColor = UIColor(named: "zenGrey")
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 15).isActive = true
    }
        
    fileprivate func stylePlaceholder() {
        placeholderLabel.text = placeholder
    }
    
    func setText(text: String) {
        self.text = text
        showPlaceholderLabelIfNeeded()
    }
    
    func getText() -> String {
        return text
    }
    
    func showPlaceholderLabelIfNeeded() {
        if text.count == 0 {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
    }
}

extension FormFieldTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        showPlaceholderLabelIfNeeded()
    }

}
