//
//  ResetPasswordViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: ResetPasswordViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    fileprivate var keyboardAdjustBehaviour: KeyboardAdjust?
    
    @IBOutlet weak var emailField: FormFieldView!
    @IBOutlet weak var resetPasswordBtn: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureFields()
        
        emailField.field.fieldDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewReady()
    }
    
    func makeEmailFirstResponder() {
        emailField.becomeActiveField()
    }
    
    fileprivate func configureFields() {
        emailField.setTitle(title: "Email")
        emailField.setPlaceholder(placeholder: "Enter Email")
        emailField.setKeyboardType(type: .email)
        emailField.setContentType(type: .username)
    }
    
    @IBAction func sendResetEmailBtnPressed(_ sender: Any) {
        sendTextFields()
        viewModel?.resetEmailBtnPressed()
        emailField.resignActiveField()
    }
    
    func sendTextFields() {
        viewModel?.email = emailField.getFieldValue().trimmingCharacters(in: .whitespaces)
    }
    
    func toggleResetEmailBtnLoading(loading: Bool) {
        resetPasswordBtn.toggleLoading(loading: loading)
    }
    
    func closeKeyboard() {
        emailField.resignActiveField()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField.field {
            emailField.resignActiveField()
            
            sendTextFields()
            viewModel?.keyboardEnterPressed()
        }
        return true
    }
}
