//
//  ListsCategoryCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class ListsCategoryCoordinator: Coordinator {
    var navigationController: UINavigationController

    lazy var rootViewController: ListsCategoryViewController = {
        ListsCategoryViewController.instantiate()
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = ListsCategoryViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    func gotoListDetail(list: List) {
        let listDetailCoordinator = ListDetailCoordinator(navigationController: navigationController)
        addChildCoordinator(listDetailCoordinator)
        listDetailCoordinator.start()
        
        let viewModel = listDetailCoordinator.rootViewController.viewModel
        viewModel?.list = list
    }
    
    func gotoEditList(list: List) {
        let createListCoordinator = CreateListCoordinator(parentViewController: rootViewController)
        addChildCoordinator(createListCoordinator)
        createListCoordinator.start()
        
        let viewModel = createListCoordinator.createListViewController.viewModel
        viewModel?.viewState = .edit(list: list)
    }
    
    func gotoShareList(list: List) {
        let shareCoordinator = ShareCoordinator(navigationController: navigationController)
        addChildCoordinator(shareCoordinator)
        shareCoordinator.start()
        
        let viewModel = shareCoordinator.rootViewController.viewModel
        viewModel?.list = list
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
