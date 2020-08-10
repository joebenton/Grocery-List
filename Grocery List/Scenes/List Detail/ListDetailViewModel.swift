//
//  ListDetailViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class ListDetailViewModel: ViewModel {
    weak var coordinator: ListDetailCoordinator?
    weak var viewController: ListDetailViewController?

    @Injected var authService: AuthService
    @Injected var listsService: ListsService
    @Injected var reviewPromptService: ReviewPromptService
    
    var listUid: String?
    var list: List?
    var items = Array<Item>()
        
    init(with coordinator: ListDetailCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        if let list = list, listUid == nil {
            self.listUid = list.id
            configureList()
            getListItems(listUid: list.id)
        } else if let listUid = listUid, list == nil {
            viewController?.setTitle(title: "")
            getList(listUid: listUid)
            getListItems(listUid: listUid)
        }
        
        getSharedCount()
        
        reviewPromptService.showReviewPromptIfNeeded()
    }
    
    func reloadContent() {
        guard let list = list else { return }
        getList(listUid: list.id)
        getListItems(listUid: list.id)
    }
    
    fileprivate func getList(listUid: String) {
        guard let userUid = authService.getUserUid() else { return }
        
        viewController?.toggleListLoading(loading: true)
        
        listsService.getList(listUid: listUid, userUid: userUid) { [weak self] (result) in
            DispatchQueue.main.async {
                self?.viewController?.toggleListLoading(loading: false)
                
                switch result {
                case .success(let list):
                    self?.list = list
                    self?.configureList()
                case .failure(let error):
                    self?.viewController?.showAlert(title: "List Error", message: error.message)
                }
            }
        }
    }
    
    fileprivate func getListItems(listUid: String) {
        viewController?.toggleListLoading(loading: true)
        
        listsService.addListenerForListItemsChanges(listUid: listUid) { [weak self] (result) in
            DispatchQueue.main.async {
                self?.viewController?.toggleListLoading(loading: false)
                
                switch result {
                case .success(let items):
                    self?.items = items
                    self?.configureListItems()
                    self?.viewController?.reloadTableView()
                case .failure(let error):
                    self?.viewController?.showAlert(title: "Items Error", message: error.message)
                }
            }
        }
    }
    
    fileprivate func configureList() {
        guard let list = self.list else { return }
        viewController?.setTitle(title: list.name)
        viewController?.configureNavigationButtons(shareCount: 0)
    }
    
    fileprivate func configureListItems() {
        if items.count > 0 {
            viewController?.setAddMoreItemsBtnTitle(title: "Add more items")
        } else {
            viewController?.setAddMoreItemsBtnTitle(title: "Add items")
        }
    }
    
    func getSharedCount() {
        guard let listId = list?.id else { return }
        listsService.getListPendingInvites(listUid: listId) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let invites):
                    guard let list = self?.list else { return }
                    let usersCount = list.roles.count - 1
                    let shareCount = invites.count + usersCount
                    self?.viewController?.configureNavigationButtons(shareCount: shareCount)
                case .failure(let error):
                    self?.viewController?.showAlert(title: "Shared Users Count", message: error.message)
                }
            }
        }
    }
    
    func addMoreItemsBtnPressed() {
        guard let list = list else { return }
        coordinator?.gotoAddMoreItems(listUid: list.id)
    }
    
    func editBtnPressed() {
        viewController?.showEditActionSheet()
    }
    
    func addItemsSelected() {
        guard let list = list else { return }
        coordinator?.gotoAddMoreItems(listUid: list.id)
    }
    
    func editListSelected() {
        guard let list = self.list else { return }
        guard case .owner = list.viewAs else { return }

        coordinator?.gotoEditListDetails(list: list)
    }
    
    func itemSwipedToDelete(item: Item) {
        viewController?.showConfirmDeleteItem(item: item)
    }
    
    func confirmDeleteItem(item: Item) {
        guard let userUid = authService.getUserUid() else { return }
        guard let list = self.list else { return }
        
        viewController?.toggleListLoading(loading: true)
        
        listsService.deleteListItem(listUid: list.id, itemUid: item.id) { [weak self] (result) in
            switch result {
            case .success:
                let itemChange = ItemChange(itemUids: [item.id], type: .removed, changeDescription: "\(item.name)")
                self?.listsService.addItemChangeEntry(listUid: list.id, userUid: userUid, change: itemChange) { [weak self] (result) in
                    DispatchQueue.main.async {
                        self?.viewController?.toggleListLoading(loading: false)
                        
                        switch result {
                        case .success:
                            self?.getListItems(listUid: list.id)
                        case .failure(let error):
                            self?.viewController?.showAlert(title: "Delete Item Error", message: error.message)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.toggleListLoading(loading: false)
                    self?.viewController?.showAlert(title: "Delete Item Error", message: error.message)
                }
            }
        }
    }
    
    func itemSwipedToEdit(item: Item) {
        guard let list = self.list else { return }
        coordinator?.gotoEditItem(item: item, listUid: list.id)
    }
    
    func checkedBtnPressed(item: Item, checked: Bool) {
        toggleCheckedListItem(itemUid: item.id, checked: checked)
    }
    
    func shareListBtnPressed() {
        guard let list = self.list else { return }
        guard case .owner = list.viewAs else { return }

        coordinator?.gotoShareList(list: list)
    }
    
    fileprivate func toggleCheckedListItem(itemUid: String, checked: Bool) {
        guard let userUid = authService.getUserUid() else { return }
        guard let list = self.list else { return }

        let firstItemIndex = items.firstIndex { (existingItem) -> Bool in
            return itemUid == existingItem.id
        }
        guard let itemIndex = firstItemIndex else { return }
        
        let itemName = items[itemIndex].name

        items[itemIndex].checked = checked
        viewController?.reloadTableView()
        
        viewController?.toggleListLoading(loading: true)
        
        listsService.toggleCheckedListItem(listUid: list.id, itemUid: itemUid, checked: checked) { [weak self] (result) in
            switch result {
            case .success:
                let itemChange = ItemChange(itemUids: [itemUid], type: checked ? .checked : .unchecked, changeDescription: "\(itemName)")
                self?.listsService.addItemChangeEntry(listUid: list.id, userUid: userUid, change: itemChange) { [weak self] (result) in
                    DispatchQueue.main.async {
                        self?.viewController?.toggleListLoading(loading: false)

                        switch result {
                        case .success:
                            self?.getListItems(listUid: list.id)
                            self?.checkIfListCompleted()
                        case .failure(let error):
                            self?.viewController?.showAlert(title: "Delete Item Error", message: error.message)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.toggleListLoading(loading: false)

                    self?.viewController?.showAlert(title: "Error Updating Item", message: error.message)
                    
                    self?.items[itemIndex].checked = !checked
                    self?.viewController?.reloadTableView()
                }
            }
        }
    }
    
    fileprivate func checkIfListCompleted() {
        guard let list = self.list else { return }
        guard case .owner = list.viewAs else { return }

        let completedItemsCount = items.filter { (item) -> Bool in
            return item.checked
        }.count
        
        if (completedItemsCount == items.count) && list.completed == false {
            //Update list to completed
            toggleListCompleted(completed: true)
        } else if (completedItemsCount != items.count) && list.completed == true {
            //Update list to not completed
            toggleListCompleted(completed: false)
        }
    }
    
    fileprivate func toggleListCompleted(completed: Bool) {
        guard let list = self.list else { return }
        listsService.toggleListCompleted(listUid: list.id, completed: completed) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.list?.completed = completed
                case .failure(let error):
                    self?.viewController?.showAlert(title: "Edit List Error", message: error.message)
                }
            }
        }
    }
    
    func leaveListSelected() {
        guard let list = self.list else { return }
        guard case .collaborator = list.viewAs else { return }
        viewController?.showConfirmLeaveListAlert()
    }
    
    func deleteListSelected() {
        guard let list = self.list else { return }
        guard case .owner = list.viewAs else { return }
        viewController?.showConfirmDeleteListAlert()
    }
    
    func leaveListConfirmed() {
        guard let list = self.list else { return }
        guard case .collaborator = list.viewAs else { return }

        let errorTitle = "Leave List Error"
        
        guard let userId = authService.getUserUid() else { return }
        
        listsService.removeUserFromList(listUid: list.id, userUid: userId){ [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.coordinator?.finish(animated: true)
                case .failure(let error):
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
    
    func deleteListConfirmed() {
        guard let list = self.list else { return }
        guard case .owner = list.viewAs else { return }

        let errorTitle = "Delete List Error"
                                     
        listsService.deleteList(listUid: list.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.coordinator?.finish(animated: true)
                case .failure(let error):
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
    
    func viewClosed() {
        listsService.removeListenerForListItemChanges()
        coordinator?.finish()
    }
}
