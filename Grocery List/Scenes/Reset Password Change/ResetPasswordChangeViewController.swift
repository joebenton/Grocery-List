//
//  ForgotPasswordResetViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 03/08/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class ResetPasswordChangeViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: ResetPasswordChangeViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var keyboardAdjustBehaviour: KeyboardAdjust!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailField: FormFieldView!
    @IBOutlet weak var passwordField: FormFieldView!
    @IBOutlet weak var confirmPassword: FormFieldView!
    @IBOutlet weak var resetPasswordBtn: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureFields()
        configureKeyboardAdjustBehaviour()
        
        emailField.field.fieldDelegate = self
        passwordField.field.fieldDelegate = self
        confirmPassword.field.fieldDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()
    }
    
    func makePassordFirstResponder() {
        passwordField.becomeActiveField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.viewReady()
        
        if (navigationController?.isNavigationBarHidden ?? false) {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    fileprivate func configureFields() {
        emailField.setTitle(title: "Email")
        emailField.setPlaceholder(placeholder: "Enter Email")
        emailField.setKeyboardType(type: .email)
        emailField.setContentType(type: .username)
        
        passwordField.setTitle(title: "New Password")
        passwordField.setPlaceholder(placeholder: "Enter New Password")
        passwordField.setContentType(type: .newPassword)
        
        confirmPassword.setTitle(title: "Confirm New Password")
        confirmPassword.setPlaceholder(placeholder: "Confirm New Password")
        confirmPassword.setContentType(type: .newPassword)
    }
    
    fileprivate func configureKeyboardAdjustBehaviour() {
        keyboardAdjustBehaviour = KeyboardAdjust(scrollView: scrollView)
    }
    
    @IBAction func resetPasswordBtnPressed(_ sender: Any) {
        sendTextFields()
        viewModel?.resetPasswordBtnPressed()
        view.endEditing(true)
    }
    
    func sendTextFields() {
        viewModel?.password = passwordField.getFieldValue().trimmingCharacters(in: .whitespaces)
        viewModel?.confirmPassword = confirmPassword.getFieldValue().trimmingCharacters(in: .whitespaces)
    }
    
    func toggleresetPasswordBtnLoading(loading: Bool) {
        resetPasswordBtn.toggleLoading(loading: loading)
    }
    
    func setEmailTF(email: String) {
        emailField.setFieldValue(text: email)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}

extension ResetPasswordChangeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordField {
            confirmPassword.becomeActiveField()
        } else if textField == confirmPassword.field {
            confirmPassword.resignActiveField()
            
            sendTextFields()
            viewModel?.keyboardEnterPressed()
        }
        return true
    }
}
