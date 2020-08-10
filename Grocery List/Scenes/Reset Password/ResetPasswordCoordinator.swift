//
//  ResetPasswordCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class ResetPasswordCoordinator: Coordinator {
    var navigationController: UINavigationController

    lazy var rootViewController: ResetPasswordViewController = {
        ResetPasswordViewController.instantiate()
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = ResetPasswordViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    func passwordResetEmailSent() {
        finish(animated: true)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: animated)
        }
        parentCoordinator?.didFinish(self)
    }
}
