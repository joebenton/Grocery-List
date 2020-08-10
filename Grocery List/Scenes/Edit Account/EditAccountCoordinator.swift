//
//  EditAccountCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Resolver

class EditAccountCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    lazy var rootViewController: EditAccountViewController = {
        EditAccountViewController.instantiate()
    }()
    
    @Injected private var authService: AuthService

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() {
        rootViewController.viewModel = EditAccountViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}
