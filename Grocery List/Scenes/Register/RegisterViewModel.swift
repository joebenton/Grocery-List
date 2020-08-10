//
//  RegisterViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class RegisterViewModel: ViewModel {
    weak var coordinator: RegisterCoordinator?
    weak var viewController: RegisterViewController?

    @Injected private var authService: AuthService
    @Injected private var appleSignInService: AppleSignInService
    @Injected private var facebookSignInService: FacebookSignInService
    
    var email = ""
    var password = ""
    
    init(with coordinator: RegisterCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
    }
    
    func keyboardEnterPressed() {
        registerBtnPressed()
    }
    
    func registerBtnPressed() {
        let errorTitle = "Register Error"
        
        if email == "" {
            viewController?.showAlert(title: errorTitle, message: "Please enter your email address")
            return
        }
        
        if password == "" {
            viewController?.showAlert(title: errorTitle, message: "Please enter your password")
            return
        }
        
        viewController?.toggleRegisterBtnLoading(loading: true)
        viewController?.closeKeyboard()
        
        authService.registerAccount(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.viewController?.toggleRegisterBtnLoading(loading: false)

                switch result {
                case .success(let registerResponse):
                    self?.coordinator?.registered()
                    print(registerResponse.uid)
                case .failure(let error):
                    print(error.message)
                    self?.viewController?.showAlert(title: "Register Error", message: error.message)
                }
            }
        }
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
    
    func appleSignInPressed() {
        appleSignInService.signInWithApple(showFrom: viewController!) { [weak self] (result) in
            switch result {
            case .success((let nonce, let appleToken)):
                DispatchQueue.main.async {
                    self?.viewController?.toggleOverlayLoading(show: true)
                }
                    
                self?.authService.loginWithApple(nonce: nonce, appleToken: appleToken) { [weak self] (firebaseResult) in
                    DispatchQueue.main.async {
                        self?.viewController?.toggleOverlayLoading(show: false)
                        
                        switch firebaseResult {
                        case .success:
                            self?.coordinator?.registered()
                        case .failure(let error):
                            print(error.message)
                            self?.viewController?.showAlert(title: "Apple Sign-in Error", message: error.message)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.showAlert(title: "Apple Sign-in Error", message: error.message)
                }
            }
        }
    }
    
    func facebookSignInPressed() {
        facebookSignInService.signInWithFacebook(showFrom: viewController!) { [weak self] (result) in
            switch result {
            case .success(let accessToken):
                DispatchQueue.main.async {
                    self?.viewController?.toggleOverlayLoading(show: true)
                }
                
                self?.authService.loginWithFacebook(accessToken: accessToken) { [weak self] (firebaseResult) in
                    DispatchQueue.main.async {
                        self?.viewController?.toggleOverlayLoading(show: false)
                        
                        switch firebaseResult {
                        case .success:
                            self?.coordinator?.registered()
                        case .failure(let error):
                            self?.viewController?.showAlert(title: "Facebook Sign-in Error", message: error.message)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.showAlert(title: "Facebook Sign-in Error", message: error.message)
                }
            }
        }
    }
}
