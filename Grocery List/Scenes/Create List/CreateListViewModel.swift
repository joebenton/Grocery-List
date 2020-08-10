//
//  CreateListViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

enum CreateListState {
    case create
    case edit(list: List)
}

class CreateListViewModel: ViewModel {
    weak var coordinator: CreateListCoordinator?
    weak var viewController: CreateListViewController?

    @Injected var authService: AuthService
    @Injected var listsService: ListsService
    @Injected var reviewPromptService: ReviewPromptService
    @Injected var notificationService: NotificationService
        
    var viewState: CreateListState = .create
    
    var name: String = ""
    var notes: String = ""
    var isVip = false {
        didSet {
            vipDidChange()
        }
    }
    var dueDate: Date? {
        didSet {
            dueDateDidChange()
        }
    }
    
    init(with coordinator: CreateListCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        if case .edit = viewState {
            configureViewForEdit()
        } else if case .create = viewState {
            configureViewForCreate()
        }
    }
    
    fileprivate func configureViewForCreate() {
        viewController?.setTitle(title: "Create New List")
        viewController?.setCreateBtnTitle(title: "Create List")
        viewController?.hideDeleteListBtn()
        viewController?.hideShareBtn()
        configureViewForDueDate()
    }
    
    fileprivate func configureViewForEdit() {
        guard case .edit(let list) = viewState else { return }
        
        viewController?.setTitle(title: "Edit List")
        viewController?.setCreateBtnTitle(title: "Save List")
        
        name = list.name
        notes = list.notes
        isVip = list.vip
        dueDate = list.dueDate
        
        viewController?.setNameField(name: list.name)
        viewController?.setNotesField(notes: list.notes)
        viewController?.toggleVipBtn(enabled: list.vip)
        
        viewController?.setDueDateSwitch(on: list.dueDate != nil)
    }
    
    func closeBtnPressed() {
        coordinator?.finish(animated: true)
    }
    
    func vipBtnPressed() {
        isVip = !isVip
    }
    
    func dueDateSwitched(on: Bool) {
        switch on {
        case true:
            dueDate = Date()
        case false:
            dueDate = nil
        }
    }
    
    fileprivate func configureViewForDueDate() {
        if let dueDate = dueDate {
            viewController?.toggleDueDatePickerSection(show: true)
            
            viewController?.setDueDatePicker(date: dueDate)
        } else {
            viewController?.toggleDueDatePickerSection(show: false)
        }
    }
    
    fileprivate func vipDidChange() {
        viewController?.toggleVipBtn(enabled: isVip)
    }
    
    fileprivate func dueDateDidChange() {
        configureViewForDueDate()
        setDueDateLabel()
    }
    
    fileprivate func setDueDateLabel() {
        guard let dueDate = dueDate else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let formattedDate = dateFormatter.string(from: dueDate)
        viewController?.setDueDateLabel(dateString: formattedDate)
    }
    
    func shareBtnPressed() {
        if case .edit(let list) = viewState {
            coordinator?.gotoShareList(list: list)
        } else {
            coordinator?.gotoShareNewList()
        }
    }
    
    func createListBtnPressed() {
        switch viewState {
        case .create:
            createList()
        case .edit:
            editList()
        }
    }
    
    func deleteListBtnPressed() {
        guard case .edit = viewState else { return }

        viewController?.showConfirmDeleteAlert()
    }
    
    func deleteListConfirmed() {
        deleteList()
    }
    
    fileprivate func createList() {
        let errorTitle = "Create List Error"
        if name.count == 0 {
            viewController?.showAlert(title: errorTitle, message: "Please enter a list name")
            return
        }
        
        let createList = CreateList(name: name, notes: notes, vip: isVip, dueDate: dueDate)
        
        guard let userUid = authService.getUserUid() else { return }
        
        viewController?.toggleCreateListBtnLoading(loading: true)
        
        listsService.createList(userUid: userUid, list: createList) { [weak self] result in
            DispatchQueue.main.async {
                self?.viewController?.toggleCreateListBtnLoading(loading: false)
                
                switch result {
                case .success(let response):
                    self?.setupNotifications(listId: response.uid, listTitle: createList.name, listReminderDate: createList.dueDate)
                    self?.reviewPromptService.increaseEventCount()
                case .failure(let error):
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
    
    fileprivate func editList() {
        let errorTitle = "Edit List Error"
        if name.count == 0 {
            viewController?.showAlert(title: errorTitle, message: "Please enter a list name")
            return
        }
                        
        viewController?.toggleCreateListBtnLoading(loading: true)
        
        guard case .edit(var list) = viewState else { return }
        
        list.name = name
        list.notes = notes
        list.vip = isVip
        list.dueDate = dueDate
        
        listsService.editList(list: list) { [weak self] result in
            DispatchQueue.main.async {
                self?.viewController?.toggleCreateListBtnLoading(loading: false)
                
                switch result {
                case .success:
                    self?.setupNotifications(listId: list.id, listTitle: list.name, listReminderDate: list.dueDate)
                case .failure(let error):
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
    
    fileprivate func setupNotifications(listId: String, listTitle: String, listReminderDate: Date?) {
        notificationService.askForPermissions { [weak self] (granted) in
            if granted {
                self?.notificationService.removeNotificationsForList(listId: listId, completionHandler: {
                    if let reminderDate = listReminderDate {
                        let dateWithZeroSeconds = reminderDate.zeroSeconds ?? reminderDate
                        self?.notificationService.scheduleListReminderNotifcation(listId: listId, listTitle: listTitle, reminderDate: dateWithZeroSeconds)
                        DispatchQueue.main.async {
                            self?.finished(listUid: listId)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.finished(listUid: listId)
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self?.viewController?.showAlert(title: "Notifications Error", message: "Notifications are disabled. You will need to allow Notifications in your Settings app for reminder notifications to be set.", onWindow: true)
                }
            }
        }
    }
    
    fileprivate func finished(listUid: String) {
        switch viewState {
        case .create:
            self.coordinator?.gotoAddItems(listUid: listUid)
        case .edit:
            self.coordinator?.didFinishEditingList()
        }
    }
    
    fileprivate func deleteList() {
        let errorTitle = "Delete List Error"
             
        guard case .edit(let list) = viewState else { return }
        
        viewController?.toggleDeleteListBtnLoading(loading: true)
                
        listsService.deleteList(listUid: list.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.viewController?.toggleDeleteListBtnLoading(loading: false)
                
                switch result {
                case .success:
                    self?.coordinator?.didFinishEditingListDeleted()
                case .failure(let error):
                    self?.viewController?.showAlert(title: errorTitle, message: error.message)
                }
            }
        }
    }
}
