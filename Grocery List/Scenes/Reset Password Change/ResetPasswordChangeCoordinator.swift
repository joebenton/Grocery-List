//
//  ForgotPasswordResetCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 03/08/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class ResetPasswordChangeCoordinator: Coordinator {
    var navigationController: UINavigationController

    lazy var rootViewController: ResetPasswordChangeViewController = {
        ResetPasswordChangeViewController.instantiate()
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start(oobCode: String, emailReference: String) {
        rootViewController.viewModel = ResetPasswordChangeViewModel(with: self, oobCode: oobCode, emailReference: emailReference)
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    func passwordReset() {
        finish(animated: true)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: animated)
        }
        parentCoordinator?.didFinish(self)
    }
}
