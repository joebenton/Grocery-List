//
//  ChangePasswordViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, StoryboardBased, ViewModelBased {
    
    var viewModel: ChangePasswordViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var keyboardAdjustBehaviour: KeyboardAdjust!
            
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentPasswordField: FormFieldView!
    @IBOutlet weak var newPasswordField: FormFieldView!
    @IBOutlet weak var newPasswordRepeatField: FormFieldView!
    @IBOutlet weak var changeBtn: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureFields()
        configureKeyboardAdjustBehaviour()
                
        currentPasswordField.fieldDelegate = self
        newPasswordField.fieldDelegate = self
        newPasswordRepeatField.fieldDelegate = self
    }
    
    fileprivate func configureFields() {
        currentPasswordField.setTitle(title: "Current Password")
        currentPasswordField.setPlaceholder(placeholder: "Enter Current Password")
        currentPasswordField.setContentType(type: .password)
        
        newPasswordField.setTitle(title: "New Password")
        newPasswordField.setPlaceholder(placeholder: "Enter New Password")
        newPasswordField.setContentType(type: .newPassword)
        
        newPasswordRepeatField.setTitle(title: "Confirm New Password")
        newPasswordRepeatField.setPlaceholder(placeholder: "Enter New Password")
        newPasswordRepeatField.setContentType(type: .newPassword)
    }
    
    fileprivate func configureKeyboardAdjustBehaviour() {
        keyboardAdjustBehaviour = KeyboardAdjust(scrollView: scrollView)
        keyboardAdjustBehaviour.keyboardPadding = -(tabBarController?.tabBar.frame.size.height ?? 0)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewReady()
    }
    
    @IBAction func changeBtnPressed(_ sender: Any) {
        sendTextFields()
        viewModel?.changeBtnPressed()
    }
    
    func toggleChangeBtnLoading(loading: Bool) {
        changeBtn.toggleLoading(loading: loading)
    }
    
    func sendTextFields() {
        viewModel?.currentPassword = currentPasswordField.getFieldValue().trimmingCharacters(in: .whitespaces)
        viewModel?.newPassword = newPasswordField.getFieldValue().trimmingCharacters(in: .whitespaces)
        viewModel?.newPasswordRepeat = newPasswordRepeatField.getFieldValue().trimmingCharacters(in: .whitespaces)
    }
    
    func resetFields() {
        currentPasswordField.setFieldValue(text: "")
        newPasswordField.setFieldValue(text: "")
        newPasswordRepeatField.setFieldValue(text: "")
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == currentPasswordField.field {
            newPasswordField.becomeActiveField()
        } else if textField == newPasswordField.field {
            newPasswordRepeatField.becomeActiveField()
        } else if textField == newPasswordRepeatField.field {
            newPasswordRepeatField.resignActiveField()
            
            sendTextFields()
            viewModel?.keyboardEnterPressed()
        }
        return true
    }
}
