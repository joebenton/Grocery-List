//
//  LoginCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class LoginCoordinator: Coordinator {
    
    var navigationController: UINavigationController

    lazy var rootViewController: LoginViewController = {
        LoginViewController.instantiate()
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = LoginViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    func loggedIn() {
        finish(animated: true)
    }
    
    func gotoResetPassword() {
        let resetPasswordCoordinator = ResetPasswordCoordinator(navigationController: navigationController)
        addChildCoordinator(resetPasswordCoordinator)
        resetPasswordCoordinator.start()
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}
