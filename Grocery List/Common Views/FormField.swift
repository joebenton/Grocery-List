//
//  FormField.swift
//  Grocery List
//
//  Created by Joe Benton on 29/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

protocol FormField: UIView {
    var fieldDelegate: UITextFieldDelegate? { get set }
    var placeholder: String? { get set }
    var maxCharacters: Int? { get set }
    
    var keyboardType: UIKeyboardType { get set }
    var isSecureTextEntry: Bool { get set }
    var textContentType: UITextContentType! { get set }
    var returnKeyType: UIReturnKeyType { get set }
    var autocapitalizationType: UITextAutocapitalizationType { get set }
    
    func setText(text: String)
    func getText() -> String
}
