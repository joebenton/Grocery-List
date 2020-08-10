//
//  SettingsCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Resolver
import SafariServices

class SettingsCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    lazy var rootViewController: SettingsViewController = {
        SettingsViewController.instantiate()
    }()
    
    @Injected private var authService: AuthService

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() {
        rootViewController.viewModel = SettingsViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    func gotoEditAccount() {
        let editAccountCoordinator = EditAccountCoordinator(navigationController: navigationController)
        addChildCoordinator(editAccountCoordinator)
        editAccountCoordinator.start()
    }
    
    func gotoChangePassword() {
        let changePasswordCoordinator = ChangePasswordCoordinator(navigationController: navigationController)
        addChildCoordinator(changePasswordCoordinator)
        changePasswordCoordinator.start()
    }
    
    func gotoAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
    
    func gotoSafariSupport() {
        let urlString = "http://www.joebenton.co.uk/support"
        guard let url = URL(string: urlString) else { return }
        
        openSafariBrowser(url: url)
    }
    
    func gotoSafariBrowserAbout() {
        let urlString = "http://www.joebenton.co.uk"
        guard let url = URL(string: urlString) else { return }
        
        openSafariBrowser(url: url)
    }
    
    func gotoSafariBrowserFeedback() {
        let urlString = "http://www.joebenton.co.uk/feedback"
        guard let url = URL(string: urlString) else { return }
        
        openSafariBrowser(url: url)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
    
    func didLogout() {
        finish()
    }
    
    fileprivate func openSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredBarTintColor = UIColor.white
        safariVC.preferredControlTintColor = UIColor(named: "zenBlue")
        navigationController.present(safariVC, animated: true, completion: nil)
    }
}
