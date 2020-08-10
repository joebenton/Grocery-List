//
//  FormFieldView.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

enum FormFieldType {
    case textField(maxCharacters: Int?)
    case textView
}
enum FormFieldKeyboardType {
    case normal
    case email
}
enum FormFieldContentType {
    case normal
    case username
    case password
    case newPassword
    case name
    case cityState
}
enum FormFieldKeyboardReturnKeyType {
    case normal
    case done
    case go
}
enum FormFieldCapitalisationType {
    case noCapitalisation
    case words
}

@IBDesignable
class FormFieldView: UIView {
    
    weak var fieldDelegate: UITextFieldDelegate? {
        didSet {
            field.fieldDelegate = fieldDelegate
        }
    }
    
    var type: FormFieldType = .textField(maxCharacters: nil) {
        didSet {
            configureForType()
        }
    }
    
    var field: FormField!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var fieldWrapper: UIView!
    @IBOutlet weak var fieldWrapperHeightConstraint: NSLayoutConstraint!
    
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
        
        containerView.backgroundColor = UIColor.clear
        
        configureForType()
    }
    
    func setType(type: FormFieldType) {
        self.type = type
    }
    
    fileprivate func configureForType() {
        self.fieldWrapper.subviews.first?.removeFromSuperview()
        
        switch type {
        case .textField(let maxCharacters):
            self.field = FormFieldTextField()
            self.field.maxCharacters = maxCharacters
            self.field!.translatesAutoresizingMaskIntoConstraints = false
            fieldWrapper.addSubview(self.field!)
            self.field!.constraintToParent(parent: fieldWrapper)
            
            fieldWrapperHeightConstraint.constant = 56
        case .textView:
            self.field = FormFieldTextView()
            self.field!.translatesAutoresizingMaskIntoConstraints = false
            fieldWrapper.addSubview(self.field!)
            self.field!.constraintToParent(parent: fieldWrapper)
            
            fieldWrapperHeightConstraint.constant = 112
        }
    }
    
    func setFieldValue(text: String) {
        field.setText(text: text)
    }
    
    func setTitle(title: String) {
        fieldLabel.text = title
    }
    
    func setPlaceholder(placeholder: String) {
        field.placeholder = placeholder
    }
    
    func getFieldValue() -> String {
        return field.getText()
    }
    
    func becomeActiveField() {
        field.becomeFirstResponder()
    }
    
    func resignActiveField() {
        field.resignFirstResponder()
    }
    
    func setKeyboardType(type: FormFieldKeyboardType) {
        switch type {
        case .email:
            field.keyboardType = .emailAddress
        default:
            field.keyboardType = .default
        }
    }
    
    func setContentType(type: FormFieldContentType) {
        switch type {
        case .username:
            field.textContentType = .username
        case .password:
            field.textContentType = .password
            field.isSecureTextEntry = true
        case .newPassword:
            field.textContentType = .newPassword
            field.isSecureTextEntry = true
        case .name:
            field.textContentType = .name
        case .cityState:
            field.textContentType = .addressCityAndState
        default:
            break
        }
    }
    
    func setKeyboardReturnKeyType(type: FormFieldKeyboardReturnKeyType) {
        switch type {
        case .done:
            field.returnKeyType = .done
        case .go:
            field.returnKeyType = .go
        default:
            field.returnKeyType = .default
        }
    }
    
    func setCapitalisationType(type: FormFieldCapitalisationType) {
        switch type {
        case .words:
            field.autocapitalizationType = .words
        default:
            field.autocapitalizationType = .none
        }
    }
}
