//
//  NotificationsCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Resolver

class NotificationsCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    lazy var rootViewController: NotificationsViewController = {
        NotificationsViewController.instantiate()
    }()
    
    @Injected private var authService: AuthService

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() {
        rootViewController.viewModel = NotificationsViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    func gotoListDetail(listUid: String) {
        let listDetailCoordinator = ListDetailCoordinator(navigationController: navigationController)
        addChildCoordinator(listDetailCoordinator)
        listDetailCoordinator.start()
        
        let viewModel = listDetailCoordinator.rootViewController.viewModel
        viewModel?.listUid = listUid
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}

