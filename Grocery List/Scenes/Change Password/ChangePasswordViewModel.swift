//
//  ChangePasswordViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class ChangePasswordViewModel: ViewModel {
    weak var coordinator: ChangePasswordCoordinator?
    weak var viewController: ChangePasswordViewController?

    @Injected private var authService: AuthService
    
    var currentPassword = ""
    var newPassword = ""
    var newPasswordRepeat = ""
    
    init(with coordinator: ChangePasswordCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
    }
    
    func keyboardEnterPressed() {
        changeBtnPressed()
    }
    
    func changeBtnPressed() {
        let errorTitle = "Change Password Error"
        
        if currentPassword == "" {
            viewController?.showAlert(title: errorTitle, message: "Please enter your current password")
            return
        }
        
        if newPassword == "" {
            viewController?.showAlert(title: errorTitle, message: "Please enter your new password")
            return
        }
        
        if newPasswordRepeat == "" {
            viewController?.showAlert(title: errorTitle, message: "Please confirm your new password")
            return
        }
        
        if newPassword != newPasswordRepeat {
            viewController?.showAlert(title: errorTitle, message: "Your new passwords do not match")
            return
        }
        
        viewController?.toggleChangeBtnLoading(loading: true)
        viewController?.closeKeyboard()
        
        authService.changePassword(oldPassword: currentPassword, newPassword: newPassword) { [weak self] result in
            DispatchQueue.main.async {
                self?.viewController?.toggleChangeBtnLoading(loading: false)

                switch result {
                case .success:
                    self?.viewController?.showAlert(title: "Password Changed", message: "Your password has been changed.")
                    self?.viewController?.resetFields()
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
