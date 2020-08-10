//
//  CreateListCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class CreateListCoordinator: Coordinator {
    var parentViewController: UIViewController
    lazy var rootViewController: UINavigationController = {
        let controller = UINavigationController(rootViewController: createListViewController)
        controller.navigationBar.prefersLargeTitles = true
        return controller
    }()

    lazy var createListViewController: CreateListViewController = {
        CreateListViewController.instantiate()
    }()

    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
    
    var addedListUid: String?
    var didEditList: Bool = false
    var didDeleteList: Bool = false

    override func start() {
        createListViewController.viewModel = CreateListViewModel(with: self)
        rootViewController.modalPresentationStyle = .fullScreen
        parentViewController.present(rootViewController, animated: true, completion: nil)
    }
    
    func gotoAddItems(listUid: String) {
        let addItemsCoordinator = AddItemsCoordinator(navigationController: rootViewController)
        addChildCoordinator(addItemsCoordinator)
        addItemsCoordinator.start()
        
        let viewModel = addItemsCoordinator.rootViewController.viewModel
        viewModel?.listUid = listUid
    }
    
    func didFinishEditingList() {
        didEditList = true
        finish(animated: true)
    }
    
    func didFinishEditingListDeleted() {
        didDeleteList = true
        finish(animated: true)
    }
    
    func gotoShareList(list: List) {
        let shareCoordinator = ShareCoordinator(navigationController: rootViewController)
        addChildCoordinator(shareCoordinator)
        shareCoordinator.start()
        
        let viewModel = shareCoordinator.rootViewController.viewModel
        viewModel?.list = list
    }
    
    func gotoShareNewList() {
        
    }

    override func didFinish(_ coordinator: Coordinator) {
        super.didFinish(coordinator)
        if let addItemsCoordinator = coordinator as? AddItemsCoordinator {
            if let addedListUid = addItemsCoordinator.addedListUid {
                self.addedListUid = addedListUid
                finish(animated: true)
            }
        }
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
