//
//  AddItemsCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class AddItemsCoordinator: Coordinator {
    var navigationController: UINavigationController
    var parentViewController: UIViewController?

    lazy var rootViewController: AddItemsViewController = {
        AddItemsViewController.instantiate()
    }()
    
    var addedListUid: String?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = AddItemsViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    func addedItems(newListUid: String) {
        addedListUid = newListUid
        finish()
    }
    
    func skippedAddingItems(newListUid: String) {
        addedListUid = newListUid
        finish()
    }
    
    func addedMoreItems() {
        finish(animated: true)
    }

    override func didFinish(_ coordinator: Coordinator) {
        super.didFinish(coordinator)
    }
    
    override func finish(animated: Bool = false) {
        if let parentViewController = parentViewController {
            parentViewController.dismiss(animated: animated, completion: nil)
        } else if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}
