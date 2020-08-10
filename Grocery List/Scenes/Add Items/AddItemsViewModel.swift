//
//  AddItemsViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

enum AddItemsViewState {
    case addItemsToNewList
    case addItemsToExistingList
}

class AddItemsViewModel: ViewModel {
    weak var coordinator: AddItemsCoordinator?
    weak var viewController: AddItemsViewController?
    
    @Injected var authService: AuthService
    @Injected var listsService: ListsService
    
    var listUid: String?
    var items = Array<CreateItem>()
    
    var viewState: AddItemsViewState = .addItemsToNewList
    
    init(with coordinator: AddItemsCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        if items.count == 0 {
            viewController?.toggleAddedItemsSection(show: false)
            viewController?.toggleSaveItemsBtnEnabled(enabled: false)
        }
        
        if case .addItemsToNewList = viewState {
            viewController?.hideBackButton()
        }
        
        if case .addItemsToExistingList = viewState {
            viewController?.hideSkipBtn()
            viewController?.showCancelBtn()
        }
    }
    
    func addItemBtnPressed(name: String) {
        if name == "" {
            viewController?.showAlert(title: "Add Item Error", message: "Please enter the item name.")
            return
        }
        
        let id = items.count
        let newItem = CreateItem(id: id, name: name, unitType: .pcs, quantity: 1)
        items.append(newItem)
        
        viewController?.addItemToAddedItemsStackView(item: newItem)
        
        viewController?.resetNameField()
        
        viewController?.toggleAddedItemsSection(show: true)
        
        viewController?.toggleSaveItemsBtnEnabled(enabled: true)
    }
    
    func addItemsBtnPressed() {
        let errorTitle = "Save Items Error"
        if items.count == 0 {
            viewController?.showAlert(title: errorTitle, message: "You have not added any items yet.")
            return
        }
        
        guard let listUid = listUid else { return }
        guard let userUid = authService.getUserUid() else { return }
        
        viewController?.toggleSaveItemsBtnLoading(loading: true)
        
        listsService.addListItems(listUid: listUid, userUid: userUid, items: items) { [weak self] result in
            switch result {
            case .success(let createItemsResponse):
                let itemsNames = self?.items.compactMap({ $0.name }).joined(separator: ", ")
                let itemChange = ItemChange(itemUids: createItemsResponse.uids, type: .added, changeDescription: itemsNames)
                self?.listsService.addItemChangeEntry(listUid: listUid, userUid: userUid, change: itemChange, completion: { [weak self] (result) in
                    DispatchQueue.main.async {
                        self?.viewController?.toggleSaveItemsBtnLoading(loading: false)

                        switch result {
                        case .success:
                            switch self?.viewState {
                            case .addItemsToNewList:
                                self?.coordinator?.addedItems(newListUid: listUid)
                            case .addItemsToExistingList:
                                self?.coordinator?.addedMoreItems()
                            default: break
                            }
                        case .failure(let error):
                            self?.viewController?.showAlert(title: errorTitle, message: error.message)
                        }
                    }
                })
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.toggleSaveItemsBtnLoading(loading: false)
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
    
    func didUpdateAddedItem(item: CreateItem) {
        let firstIndex = items.firstIndex { (existingItem) -> Bool in
            return existingItem.id == item.id
        }
        guard let itemIndex = firstIndex else { return }
        items[itemIndex] = item
    }
    
    func skipBtnPressed() {
        guard let listUid = listUid else { return }
        coordinator?.skippedAddingItems(newListUid: listUid)
    }
    
    func cancelBtnPressed() {
        coordinator?.finish(animated: true)
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
}
