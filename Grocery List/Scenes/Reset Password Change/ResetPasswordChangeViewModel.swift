//
//  ForgotPasswordResetViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 03/08/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class ResetPasswordChangeViewModel: ViewModel {
    weak var coordinator: ResetPasswordChangeCoordinator?
    weak var viewController: ResetPasswordChangeViewController?

    @Injected private var authService: AuthService
    
    var oobCode: String
    var emailReference: String
    
    var password = ""
    var confirmPassword = ""
    
    init(with coordinator: ResetPasswordChangeCoordinator, oobCode: String, emailReference: String) {
        self.coordinator = coordinator
        self.oobCode = oobCode
        self.emailReference = emailReference
    }
    
    func viewReady() {
        if emailReference.count > 0 {
            viewController?.setEmailTF(email: emailReference)
        } else {
            viewController?.showAlert(title: "Reset Password Error", message: "Error getting email used")
        }
    }
    
    func viewDidAppear() {
        viewController?.makePassordFirstResponder()
    }
    
    func keyboardEnterPressed() {
        resetPasswordBtnPressed()
    }
    
    func resetPasswordBtnPressed() {
        let errorTitle = "Reset Password Error"
        
        guard self.oobCode.count > 0 else {
            viewController?.showAlert(title: errorTitle, message: "Error getting reset code")
            return
        }
        
        guard self.emailReference.count > 0 else {
            viewController?.showAlert(title: errorTitle, message: "Error getting email used")
            return
        }
        
        if password == "" {
            viewController?.showAlert(title: errorTitle, message: "Please enter your new password")
            return
        }
        
        if confirmPassword == "" {
            viewController?.showAlert(title: errorTitle, message: "Please confirm your new password")
            return
        }
        
        if password != confirmPassword {
            viewController?.showAlert(title: errorTitle, message: "Your new passwords don't match")
            return
        }
        
        viewController?.toggleresetPasswordBtnLoading(loading: true)
        
        authService.verifyChangePasswordResetCode(oobCode: oobCode) { [weak self] (verifyResult) in
            switch verifyResult {
            case .success(let email):
                guard email.lowercased() == self?.emailReference.lowercased() else {
                    DispatchQueue.main.async {
                        self?.viewController?.toggleresetPasswordBtnLoading(loading: false)
                        self?.viewController?.showAlert(title: errorTitle, message: "Reset email invalid")
                    }
                    return
                }
                self?.authService.changePasswordFromResetEmail(oobCode: self!.oobCode, newPassword: self!.password) { [weak self] (result) in
                    DispatchQueue.main.async {
                        self?.viewController?.toggleresetPasswordBtnLoading(loading: false)

                        switch result {
                        case .success:
                            self?.coordinator?.passwordReset()
                            self?.viewController?.showAlert(title: "Password Reset", message: "Your password has been reset and you can now login with these new details.", onWindow: true)
                        case .failure(let error):
                            print(error.message)
                            self?.viewController?.showAlert(title: errorTitle, message: error.message)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.toggleresetPasswordBtnLoading(loading: false)
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
}
