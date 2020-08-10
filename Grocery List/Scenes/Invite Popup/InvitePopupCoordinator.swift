//
//  InvitePopupCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Resolver

class InvitePopupCoordinator: Coordinator {
    var parentViewController: UIViewController
    var rootViewController: InvitePopupViewController = {
        InvitePopupViewController.instantiate()
    }()

    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
    
    var didAcceptInviteListUid: String?
    
    override func start() {
        rootViewController.viewModel = InvitePopupViewModel(with: self)
        rootViewController.modalPresentationStyle = .overFullScreen
        rootViewController.modalTransitionStyle = .crossDissolve
        parentViewController.present(rootViewController, animated: true, completion: nil)
    }
    
    func inviteAccepted(listUid: String) {
        didAcceptInviteListUid = listUid
        finish(animated: true)
    }
    
    override func finish(animated: Bool = false) {
        if rootViewController.presentingViewController == parentViewController {
            parentViewController.dismiss(animated: animated) {
                self.parentCoordinator?.didFinish(self)
            }
        } else {
            rootViewController.dismiss(animated: animated) {
                self.parentCoordinator?.didFinish(self)
            }
        }
    }
}
