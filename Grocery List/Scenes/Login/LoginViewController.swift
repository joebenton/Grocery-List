//
//  LoginViewController.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import AuthenticationServices
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController, StoryboardBased, ViewModelBased {
    
    var viewModel: LoginViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    
    var overlayLoader: OverlayLoader?
        
    @IBOutlet weak var emailField: FormFieldView!
    @IBOutlet weak var passwordField: FormFieldView!
    @IBOutlet weak var loginBtn: LoadingButton!
    @IBOutlet weak var resetPasswordBtn: UIButton!
    @IBOutlet weak var appleSignInBtnWrapper: UIView!
    @IBOutlet weak var facebookSignInBtnWrapper: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureFields()
        addAppleSignInBtn()
        addFacebookSignInBtn()
                
        emailField.fieldDelegate = self
        passwordField.fieldDelegate = self
    }
    
    fileprivate func configureFields() {
        emailField.setTitle(title: "Email")
        emailField.setPlaceholder(placeholder: "Enter Email")
        emailField.setKeyboardType(type: .email)
        emailField.setContentType(type: .username)
        
        passwordField.setTitle(title: "Password")
        passwordField.setPlaceholder(placeholder: "Enter Password")
        passwordField.setContentType(type: .newPassword)
    }
    
    fileprivate func addAppleSignInBtn() {
        let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn,
                                                               authorizationButtonStyle: .black)
        authorizationButton.cornerRadius = 6

        authorizationButton.addTarget(self, action: #selector(appleSignInBtnPressed), for: .touchUpInside)

        appleSignInBtnWrapper.addSubview(authorizationButton)

        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorizationButton.topAnchor.constraint(equalTo: appleSignInBtnWrapper.topAnchor, constant: 0.0),
            authorizationButton.leadingAnchor.constraint(equalTo: appleSignInBtnWrapper.leadingAnchor, constant: 0.0),
            authorizationButton.trailingAnchor.constraint(equalTo: appleSignInBtnWrapper.trailingAnchor, constant: 0.0),
            authorizationButton.bottomAnchor.constraint(equalTo: appleSignInBtnWrapper.bottomAnchor, constant: 0.0),
            authorizationButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    fileprivate func addFacebookSignInBtn() {
        let facebookButton = UIButton(type: .system)
        facebookButton.backgroundColor = UIColor(red: 0.231, green: 0.349, blue: 0.596, alpha: 1)
        facebookButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        facebookButton.setTitleColor(UIColor.white, for: .normal)
        facebookButton.setTitleColor(UIColor.white, for: .selected)
        facebookButton.setTitle("Continue with Facebook", for: .normal)
        facebookButton.setTitle("Continue with Facebook", for: .selected)
        facebookButton.layer.cornerRadius = 6
        facebookButton.clipsToBounds = true
        facebookButton.setImage(UIImage(named: "ic_facebookLogin"), for: .normal)
        facebookButton.setImage(UIImage(named: "ic_facebookLogin"), for: .selected)
        facebookButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        facebookButton.tintColor = UIColor.white
        
        facebookButton.addTarget(self, action: #selector(facebookSignInBtnPressed), for: .touchUpInside)
        
        facebookButton.translatesAutoresizingMaskIntoConstraints = false
        facebookSignInBtnWrapper.addSubview(facebookButton)
        
        NSLayoutConstraint.activate([
            facebookButton.topAnchor.constraint(equalTo: facebookSignInBtnWrapper.topAnchor, constant: 0.0),
            facebookButton.leadingAnchor.constraint(equalTo: facebookSignInBtnWrapper.leadingAnchor, constant: 0.0),
            facebookButton.trailingAnchor.constraint(equalTo: facebookSignInBtnWrapper.trailingAnchor, constant: 0.0),
            facebookButton.bottomAnchor.constraint(equalTo: facebookSignInBtnWrapper.bottomAnchor, constant: 0.0),
            facebookButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc func appleSignInBtnPressed() {
        viewModel?.appleSignInPressed()
    }
    
    @objc func facebookSignInBtnPressed() {
        viewModel?.facebookSignInPressed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (navigationController?.isNavigationBarHidden ?? false) {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewReady()
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        sendTextFields()
        viewModel?.loginBtnPressed()
    }
    
    @IBAction func resetPasswordBtn(_ sender: Any) {
        viewModel?.resetPasswordBtnPressed()
    }
    
    func toggleLoginBtnLoading(loading: Bool) {
        loginBtn.toggleLoading(loading: loading)
    }
    
    func sendTextFields() {
        viewModel?.email = emailField.getFieldValue().trimmingCharacters(in: .whitespaces)
        viewModel?.password = passwordField.getFieldValue().trimmingCharacters(in: .whitespaces)
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    func toggleOverlayLoading(show: Bool) {
        if let existingOverlayLoader = overlayLoader {
            existingOverlayLoader.removeFromSuperview()
            self.overlayLoader = nil
        }
        if show {
            self.overlayLoader = OverlayLoader()
            self.overlayLoader?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(self.overlayLoader!)
            self.overlayLoader?.constraintToParent(parent: view)
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            navigationController?.setNavigationBarHidden(true, animated: true)
            viewModel?.viewClosed()
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField.field {
            passwordField.becomeActiveField()
        } else if textField == passwordField.field {
            passwordField.resignActiveField()
            
            sendTextFields()
            viewModel?.keyboardEnterPressed()
        }
        return true
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
