//
//  ListsCategoryViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

enum ListsCategoryType: String {
    case all = "All"
    case dueToday = "Due today"
    case dueThisWeek = "Due this week"
    case vip = "VIP"
    case shared = "Shared"
    case completed = "Completed"
}

class ListsCategoryViewModel: ViewModel {
    weak var coordinator: ListsCategoryCoordinator?
    weak var viewController: ListsCategoryViewController?

    @Injected var authService: AuthService
    @Injected var listsService: ListsService
    
    var categoryType: ListsCategoryType = .all
    var lists = Array<List>()
    
    init(with coordinator: ListsCategoryCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        configureTitle()
        getLists()
        getUnreadNotificationsCount()
    }
    
    fileprivate func configureTitle() {
        viewController?.setTitle(title: categoryType.rawValue)
    }
    
    fileprivate func getLists() {
        guard let userUid = authService.getUserUid() else { return }
        
        viewController?.toggleListsLoading(loading: true)
        viewController?.toggleEmptyListLabel(show: false)
        
        listsService.getLists(category: categoryType, userUid: userUid) { [weak self] (result) in
            DispatchQueue.main.async {
                self?.viewController?.toggleListsLoading(loading: false)
                
                switch result {
                case .success(let lists):
                    self?.lists = lists
                    self?.configureEmptyLabel()
                    self?.viewController?.reloadTableView()
                case .failure(let error):
                    self?.viewController?.showAlert(title: "Lists Error", message: error.message)
                }
            }
        }
    }
    
    fileprivate func getUnreadNotificationsCount() {
        authService.getNotifications { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let notifications):
                    let unreadCount = notifications.filter { (notification) -> Bool in
                        return notification.opened == false
                    }.count
                    self?.viewController?.setUnreadNotificationsCount(unreadCount: unreadCount)
                case .failure:
                    break
                }
            }
        }
    }
    
    fileprivate func configureEmptyLabel() {
        if lists.count == 0 {
            viewController?.toggleEmptyListLabel(show: true)
        } else {
            viewController?.toggleEmptyListLabel(show: false)
        }
    }
    
    func didSelectList(list: List) {
        coordinator?.gotoListDetail(list: list)
    }
    
    func listSwipedToDelete(list: List) {
        switch list.viewAs {
        case .owner:
            viewController?.showConfirmDeleteList(list: list)
        case .collaborator:
            viewController?.showConfirmLeaveList(list: list)
        }
    }
    
    func listSwipedToEdit(list: List) {
        guard case .owner = list.viewAs else { return }
        coordinator?.gotoEditList(list: list)
    }
    
    func listSwipedToShare(list: List) {
        guard case .owner = list.viewAs else { return }
        coordinator?.gotoShareList(list: list)
    }
    
    func listSwipedToComplete(list: List) {
        guard case .owner = list.viewAs else { return }

        let errorTitle = "Edit List Error"
        let completed = !list.completed
        
        viewController?.toggleOverlayLoading(show: true)
        
        listsService.toggleListCompleted(listUid: list.id, completed: completed) { [weak self] (result) in
            DispatchQueue.main.async {
                self?.viewController?.toggleOverlayLoading(show: false)
                
                switch result {
                case .success:
                    self?.getLists()
                case .failure(let error):
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
    
    func confirmDeleteList(list: List) {
        guard case .owner = list.viewAs else { return }
        let errorTitle = "Delete List Error"
                     
        viewController?.toggleOverlayLoading(show: true)
                
        listsService.deleteList(listUid: list.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.viewController?.toggleOverlayLoading(show: false)
                
                switch result {
                case .success:
                    self?.getLists()
                case .failure(let error):
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
    
    func confirmLeaveList(list: List) {
        guard case .collaborator = list.viewAs else { return }
        let errorTitle = "Leave List Error"
                     
        viewController?.toggleOverlayLoading(show: true)
        
        guard let userUid = authService.getUserUid() else { return }
        
        listsService.removeUserFromList(listUid: list.id, userUid: userUid){ [weak self] result in
            DispatchQueue.main.async {
                self?.viewController?.toggleOverlayLoading(show: false)
                
                switch result {
                case .success:
                    self?.getLists()
                case .failure(let error):
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
    
    func notificationsBtnPressed() {
        coordinator?.gotoNotifications()
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
}
