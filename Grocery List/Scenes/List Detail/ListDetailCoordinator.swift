//
//  ListDetailCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class ListDetailCoordinator: Coordinator {
    var navigationController: UINavigationController

    lazy var rootViewController: ListDetailViewController = {
        ListDetailViewController.instantiate()
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = ListDetailViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    func gotoAddMoreItems(listUid: String) {
        let addItemsNC = UINavigationController()
        let addItemsCoordinator = AddItemsCoordinator(navigationController: addItemsNC)
        addItemsCoordinator.parentViewController = rootViewController
        addChildCoordinator(addItemsCoordinator)
        addItemsCoordinator.start()
        
        let viewModel = addItemsCoordinator.rootViewController.viewModel
        viewModel?.listUid = listUid
        viewModel?.viewState = .addItemsToExistingList
        
        rootViewController.present(addItemsNC, animated: true, completion: nil)
    }
    
    func gotoEditListDetails(list: List) {
        let createListCoordinator = CreateListCoordinator(parentViewController: rootViewController)
        addChildCoordinator(createListCoordinator)
        createListCoordinator.start()
        
        let viewModel = createListCoordinator.createListViewController.viewModel
        viewModel?.viewState = .edit(list: list)
    }
    
    func gotoEditItem(item: Item, listUid: String) {
        let editItemCoordinator = EditItemCoordinator(parentViewController: rootViewController)
        addChildCoordinator(editItemCoordinator)
        editItemCoordinator.start()
                
        let viewModel = editItemCoordinator.editItemViewController.viewModel
        viewModel?.item = item
        viewModel?.listUid = listUid
    }
    
    func gotoShareList(list: List) {
        let shareCoordinator = ShareCoordinator(navigationController: navigationController)
        addChildCoordinator(shareCoordinator)
        shareCoordinator.start()
        
        let viewModel = shareCoordinator.rootViewController.viewModel
        viewModel?.list = list
    }

    override func didFinish(_ coordinator: Coordinator) {
        super.didFinish(coordinator)
        if let _ = coordinator as? AddItemsCoordinator {
            rootViewController.viewModel?.reloadContent()
        } else if let createListCoordinator = coordinator as? CreateListCoordinator {
            if createListCoordinator.didEditList == true {
                rootViewController.viewModel?.reloadContent()
            } else if createListCoordinator.didDeleteList == true {
                finish(animated: true)
            }
        } else if let editItemCoordinator = coordinator as? EditItemCoordinator {
            if editItemCoordinator.editedItem == true {
                rootViewController.viewModel?.reloadContent()
            }
        }
    }
    
    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}
