//
//  LoginViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class LoginViewModel: ViewModel {
    weak var coordinator: LoginCoordinator?
    weak var viewController: LoginViewController?

    @Injected private var authService: AuthService
    @Injected private var appleSignInService: AppleSignInService
    @Injected private var facebookSignInService: FacebookSignInService
    
    var email = ""
    var password = ""
    
    init(with coordinator: LoginCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
    }
    
    func keyboardEnterPressed() {
        loginBtnPressed()
    }
    
    func loginBtnPressed() {
        let errorTitle = "Login Error"
        
        if email == "" {
            viewController?.showAlert(title: errorTitle, message: "Please enter your email address")
            return
        }
        
        if password == "" {
            viewController?.showAlert(title: errorTitle, message: "Please enter your password")
            return
        }
        
        viewController?.toggleLoginBtnLoading(loading: true)
        viewController?.closeKeyboard()
        
        authService.loginAccount(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.viewController?.toggleLoginBtnLoading(loading: false)

                switch result {
                case .success:
                    self?.coordinator?.loggedIn()
                case .failure(let error):
                    print(error.message)
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
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
                            self?.coordinator?.loggedIn()
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
                            self?.coordinator?.loggedIn()
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

    func resetPasswordBtnPressed() {
        coordinator?.gotoResetPassword()
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
}
