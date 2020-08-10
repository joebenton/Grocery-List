//
//  EditItemCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class EditItemCoordinator: Coordinator {
    var parentViewController: UIViewController
    lazy var rootViewController: UINavigationController = {
        let controller = UINavigationController(rootViewController: editItemViewController)
        controller.navigationBar.prefersLargeTitles = true
        return controller
    }()

    lazy var editItemViewController: EditItemViewController = {
        EditItemViewController.instantiate()
    }()

    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
    
    var editedItem: Bool?

    override func start() {
        editItemViewController.viewModel = EditItemViewModel(with: self)
        rootViewController.modalPresentationStyle = .fullScreen
        parentViewController.present(rootViewController, animated: true, completion: nil)
    }
    
    func finishedEditingItem() {
        editedItem = true
        finish(animated: true)
    }
    
    override func didFinish(_ coordinator: Coordinator) {
        super.didFinish(coordinator)
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
