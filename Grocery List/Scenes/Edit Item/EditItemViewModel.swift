//
//  EditItemViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class EditItemViewModel: ViewModel {
    weak var coordinator: EditItemCoordinator?
    weak var viewController: EditItemViewController?
    
    @Injected var authService: AuthService
    @Injected var listsService: ListsService
    
    var listUid: String?
    var item: Item?
        
    init(with coordinator: EditItemCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        viewController?.setNameField(name: item?.name ?? "")
    }
    
    func saveItemBtnPressed() {
        let errorTitle = "Save Item Error"
        guard let userUid = authService.getUserUid() else { return }
        guard let listUid = listUid else { return }
        guard let item = item else { return }
        
        if item.name.count == 0 {
            viewController?.showAlert(title: errorTitle, message: "Please enter an item name")
            return
        }
        
        viewController?.toggleSaveItemBtnLoading(loading: true)
        
        listsService.editListItem(listUid: listUid, item: item) { [weak self] result in
            switch result {
            case .success:
                let itemChange = ItemChange(itemUids: [item.id], type: .edited, changeDescription: "\(item.name)")
                self?.listsService.addItemChangeEntry(listUid: listUid, userUid: userUid, change: itemChange) { [weak self] (result) in
                    DispatchQueue.main.async {
                        self?.viewController?.toggleSaveItemBtnLoading(loading: false)
                        
                        switch result {
                        case .success:
                            self?.coordinator?.finishedEditingItem()
                        case .failure(let error):
                            self?.viewController?.showAlert(title: errorTitle, message: error.message)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.toggleSaveItemBtnLoading(loading: false)
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
    
    func deleteItemBtnPressed() {
        viewController?.showConfirmDeleteAlert()
    }
    
    func deleteItemConfirmed() {
        guard let userUid = authService.getUserUid() else { return }
        guard let listUid = listUid else { return }
        guard let item = item else { return }
        
        self.viewController?.toggleDeleteItemBtnLoading(loading: true)
        
        listsService.deleteListItem(listUid: listUid, itemUid: item.id) { [weak self] (result) in
            switch result {
            case .success:
                let itemChange = ItemChange(itemUids: [item.id], type: .removed, changeDescription: "\(item.name)")
                self?.listsService.addItemChangeEntry(listUid: listUid, userUid: userUid, change: itemChange) { [weak self] (result) in
                    DispatchQueue.main.async {
                        self?.viewController?.toggleSaveItemBtnLoading(loading: false)
                        
                        switch result {
                        case .success:
                            self?.coordinator?.finishedEditingItem()
                        case .failure(let error):
                            self?.viewController?.showAlert(title: "Delete Item Error", message: error.message)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.toggleSaveItemBtnLoading(loading: false)
                    self?.viewController?.showAlert(title: "Delete Item Error", message: error.message)
                }
            }
        }
    }
    
    func cancelBtnPressed() {
        coordinator?.finish(animated: true)
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
}
