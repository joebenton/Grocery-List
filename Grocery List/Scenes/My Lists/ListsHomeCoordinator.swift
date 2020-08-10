//
//  ListsHomeCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class ListsHomeCoordinator: Coordinator {
    var navigationController: UINavigationController

    lazy var rootViewController: ListsHomeViewController = {
        ListsHomeViewController.instantiate()
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = ListsHomeViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    func gotoListCategory(category: ListsCategoryType) {
        let listsCategoryCoordinator = ListsCategoryCoordinator(navigationController: navigationController)
        addChildCoordinator(listsCategoryCoordinator)
        listsCategoryCoordinator.start()
        
        let viewModel = listsCategoryCoordinator.rootViewController.viewModel
        viewModel?.categoryType = category
    }
    
    func gotoCreatedList(listUid: String) {
        navigationController.popToRootViewController(animated: false)
        
        let listDetailCoordinator = ListDetailCoordinator(navigationController: navigationController)
        addChildCoordinator(listDetailCoordinator)
        listDetailCoordinator.start()
        
        let viewModel = listDetailCoordinator.rootViewController.viewModel
        viewModel?.listUid = listUid
    }
    
    func notificationReceivedPushToList(listId: String) {
        navigationController.popToRootViewController(animated: false)
        
        let listDetailCoordinator = ListDetailCoordinator(navigationController: navigationController)
        addChildCoordinator(listDetailCoordinator)
        listDetailCoordinator.start()
        
        let viewModel = listDetailCoordinator.rootViewController.viewModel
        viewModel?.listUid = listId
    }
    
    func acceptedListInvite(listUid: String) {
        navigationController.popToRootViewController(animated: false)
        
        let listDetailCoordinator = ListDetailCoordinator(navigationController: navigationController)
        addChildCoordinator(listDetailCoordinator)
        listDetailCoordinator.start()
        
        let viewModel = listDetailCoordinator.rootViewController.viewModel
        viewModel?.listUid = listUid
    }
    
    func gotoNotifications() {
        let notificationsCoordinator = NotificationsCoordinator(navigationController: navigationController)
        addChildCoordinator(notificationsCoordinator)
        notificationsCoordinator.start()
    }

    override func didFinish(_ coordinator: Coordinator) {
        super.didFinish(coordinator)
    }
    
    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}
