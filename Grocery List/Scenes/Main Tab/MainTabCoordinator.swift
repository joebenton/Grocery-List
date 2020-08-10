//
//  MainTabCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Resolver

class MainTabCoordinator: Coordinator {

    var window: UIWindow
    var tabBarController: MainTabBarController?
    
    var listsHomeCoordinator: ListsHomeCoordinator? = {
        let listsNavigationController = UINavigationController()
        listsNavigationController.navigationBar.prefersLargeTitles = true
        listsNavigationController.tabBarItem = UITabBarItem(title: "Lists", image: UIImage(named: "ic_tab_lists"), tag: 0)
        let listsHomeCoordinator = ListsHomeCoordinator(navigationController: listsNavigationController)
        return listsHomeCoordinator
    }()
    
    var settingsCoordinator: SettingsCoordinator? = {
        let settingsNavigationController = UINavigationController()
        settingsNavigationController.navigationBar.prefersLargeTitles = true
        settingsNavigationController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "ic_tab_settings"), tag: 2)
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNavigationController)
        return settingsCoordinator
    }()
    
    var createListCoordinator: CreateListCoordinator?
    var invitePopupCoordinator: InvitePopupCoordinator?
        
    init(window: UIWindow) {
        self.window = window
    }

    override func start() {
        self.tabBarController = MainTabBarController.instantiate()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        tabBarController?.viewModel = MainTabBarViewModel(with: self)

        self.tabBarController?.coordinator = self
        
        let middleNavigationController = UINavigationController()
        middleNavigationController.tabBarItem = UITabBarItem(title: "", image: nil, tag: 1)
        middleNavigationController.tabBarItem.isEnabled = false
        
        self.tabBarController?.viewControllers = [
            listsHomeCoordinator!.navigationController,
            middleNavigationController,
            settingsCoordinator!.navigationController
        ]
        
        listsHomeCoordinator?.start()
        settingsCoordinator?.start()

    }
    
    func gotoAddEvent() {
        guard let tabBarController = tabBarController else { return }
        createListCoordinator = CreateListCoordinator(parentViewController: tabBarController)
        addChildCoordinator(createListCoordinator!)
        createListCoordinator?.start()
    }
    
    func notificationReceivedPushToList(listId: String) {
        if let presented = tabBarController?.presentedViewController {
            presented.dismiss(animated: false)
        }
        
        tabBarController?.selectedIndex = 0
        
        listsHomeCoordinator?.notificationReceivedPushToList(listId: listId)
    }
    
    func showListInvitePopup(incomingShareInvite: IncomingShareInvite) {
        if let presented = tabBarController?.presentedViewController {
            presented.dismiss(animated: false)
        }
        
        guard let tabBarController = tabBarController else { return }
        invitePopupCoordinator = InvitePopupCoordinator(parentViewController: tabBarController)
        addChildCoordinator(invitePopupCoordinator!)
        invitePopupCoordinator?.start()
        
        let viewModel = invitePopupCoordinator?.rootViewController.viewModel
        viewModel?.shareInviteLink = incomingShareInvite
    }
    
    override func didFinish(_ coordinator: Coordinator) {
        if let createListCoordinator = coordinator as? CreateListCoordinator {
            self.createListCoordinator = nil
            if let listUid = createListCoordinator.addedListUid {
                tabBarController?.selectedIndex = 0
                listsHomeCoordinator?.gotoCreatedList(listUid: listUid)
            }
        } else if let invitePopupCoordinator = coordinator as? InvitePopupCoordinator {
            if let listUid = invitePopupCoordinator.didAcceptInviteListUid {
                tabBarController?.selectedIndex = 0
                listsHomeCoordinator?.acceptedListInvite(listUid: listUid)
            }
            self.invitePopupCoordinator = nil
        }
        super.didFinish(coordinator)
    }

    override func finish(animated: Bool = false) {
        tabBarController = nil
        listsHomeCoordinator = nil
        settingsCoordinator = nil
        invitePopupCoordinator = nil
        
        parentCoordinator?.didFinish(self)
    }
}
