//
//  ResetPasswordViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class ResetPasswordViewModel: ViewModel {
    weak var coordinator: ResetPasswordCoordinator?
    weak var viewController: ResetPasswordViewController?

    @Injected private var authService: AuthService
    
    var email = ""
    
    init(with coordinator: ResetPasswordCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        viewController?.makeEmailFirstResponder()
    }
    
    func keyboardEnterPressed() {
        resetEmailBtnPressed()
    }
    
    func resetEmailBtnPressed() {
        let errorTitle = "Reset Password Error"
        if email == "" {
            viewController?.showAlert(title: errorTitle, message: "Please enter your email address")
            return
        }
        
        viewController?.toggleResetEmailBtnLoading(loading: true)
        viewController?.closeKeyboard()
        
        authService.sendForgotPasswordEmail(email: email) { [weak self] result in
            DispatchQueue.main.async {
                self?.viewController?.toggleResetEmailBtnLoading(loading: false)

                switch result {
                case .success:
                    self?.coordinator?.passwordResetEmailSent()
                    self?.viewController?.showAlert(title: "Reset Password Sent", message: "A password reset link has been sent to your email address.", onWindow: true)
                case .failure(let error):
                    print(error.message)
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
}
