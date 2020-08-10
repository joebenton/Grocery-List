//
//  RegisterCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class RegisterCoordinator: Coordinator {
    
    var navigationController: UINavigationController

    lazy var rootViewController: RegisterViewController = {
        RegisterViewController.instantiate()
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = RegisterViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    func registered() {
        finish(animated: true)
    } 

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}
