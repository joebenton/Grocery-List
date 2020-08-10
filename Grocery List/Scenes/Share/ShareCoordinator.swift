//
//  ShareCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Resolver

class ShareCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    lazy var rootViewController: ShareViewController = {
        ShareViewController.instantiate()
    }()
    
    @Injected private var authService: AuthService

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() {
        rootViewController.viewModel = ShareViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}

