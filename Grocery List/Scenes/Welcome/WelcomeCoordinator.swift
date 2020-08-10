//
//  WelcomeCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Resolver

class WelcomeCoordinator: Coordinator {

    var window: UIWindow
    var navigationController: UINavigationController = {
        let controller = UINavigationController()
        controller.setNavigationBarHidden(true, animated: false)
        controller.navigationBar.prefersLargeTitles = true
        return controller
    }()
    var rootViewController: UIViewController {
        navigationController
    }
    var welcomeViewController: WelcomeViewController = {
        WelcomeViewController.instantiate()
    }()

    init(window: UIWindow) {
        self.window = window
    }

    override func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        welcomeViewController.viewModel = WelcomeViewModel(with: self)
        navigationController.pushViewController(welcomeViewController, animated: true)
    }
    
    func showInviteBanner() {
        let viewModel = welcomeViewController.viewModel
        viewModel?.showInviteBanner()
    }
    
    func gotoRegister() {
        let child = RegisterCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
    
    func gotoLogin() {
        let child = LoginCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
    
    func deepLinkGotoPasswordReset(oobCode: String, emailReference: String) {
        navigationController.popToRootViewController(animated: false)
        
        let forgotPasswordResetCoordinator = ResetPasswordChangeCoordinator(navigationController: navigationController)
        addChildCoordinator(forgotPasswordResetCoordinator)
        forgotPasswordResetCoordinator.start(oobCode: oobCode, emailReference: emailReference)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}
