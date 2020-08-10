//
//  InvitePopupViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class InvitePopupViewModel: ViewModel {
    weak var coordinator: InvitePopupCoordinator?
    weak var viewController: InvitePopupViewController?

    var shareInviteLink: IncomingShareInvite!
    var shareInvite: ShareInvite?
    
    @Injected private var authService: AuthService
    @Injected private var listsService: ListsService
    
    init(with coordinator: InvitePopupCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        viewController?.toggleInviteLoading(loading: true)
        
        listsService.getListInvite(listUid: shareInviteLink.listUid, inviteUid: shareInviteLink.inviteUid) { [weak self] (result) in
            DispatchQueue.main.async {
                self?.viewController?.toggleInviteLoading(loading: false)
                
                switch result {
                case .success(let invite):
                    self?.shareInvite = invite
                    self?.configureView()
                case .failure(let error):
                    self?.viewController?.showAlert(title: "Get Invite Error", message: error.message)
                }
            }
        }
    }
    
    fileprivate func configureView() {
        guard let shareInvite = self.shareInvite else { return }
        let text = "You have been invited to join the '\(shareInvite.listName)' list. Do you want to accept this invite and join the list?"
        viewController?.setLabelText(text: text)
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
    
    func cancelBtnPressed() {
        removeUserDefaultsKeys()
        coordinator?.finish(animated: true)
    }
    
    func acceptBtnPressed() {
        viewController?.toggleAcceptBtnLoading(loading: true)
        
        guard let userUid = authService.getUserUid() else { return }
        
        let acceptedInviteUserName = shareInvite?.name ?? "A user"
        
        listsService.acceptListShareInviteLink(listUid: shareInviteLink.listUid, inviteUid: shareInviteLink.inviteUid, userUid: userUid) { [weak self] (result) in
            switch result {
            case .success:
                guard let listUid = self?.shareInviteLink.listUid else { return }
                self?.listsService.getList(listUid: listUid, userUid: userUid, completion: { (listResult) in
                    switch listResult {
                    case .success(let list):
                        var ownerUserUid = ""
                        for (key, value) in list.roles {
                            if value == "owner" {
                                ownerUserUid = key
                            }
                        }
                        
                        guard let listUid = self?.shareInviteLink.listUid else { return }
                        self?.listsService.addAcceptedInviteNotification(listUid: listUid, listName: list.name, acceptedInviteUserUid: userUid, acceptedInviteUserName: acceptedInviteUserName, ownerUserUid: ownerUserUid) { [weak self] (notificationResult) in
                            DispatchQueue.main.async {
                                self?.viewController?.toggleAcceptBtnLoading(loading: false)

                                switch notificationResult {
                                case .success:
                                    self?.removeUserDefaultsKeys()
                                    guard let listUid = self?.shareInviteLink.listUid else { return }
                                    self?.coordinator?.inviteAccepted(listUid: listUid)
                                case .failure(let error):
                                    self?.viewController?.showAlert(title: "Invite Error", message: error.message)
                                }
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self?.viewController?.toggleAcceptBtnLoading(loading: false)
                            self?.viewController?.showAlert(title: "Invite Error", message: error.message)
                        }
                    }
                })
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.toggleAcceptBtnLoading(loading: false)
                    self?.viewController?.showAlert(title: "Invite Error", message: error.message)
                }
            }
        }
    }
    
    func removeUserDefaultsKeys() {
        if let _ = UserDefaults.standard.value(forKey: Config.userDefaultKeys.incomingListInviteListUid) as? String,
            let _ = UserDefaults.standard.value(forKey: Config.userDefaultKeys.incomingListInviteInviteUid) as? String {
            UserDefaults.standard.removeObject(forKey: Config.userDefaultKeys.incomingListInviteListUid)
            UserDefaults.standard.removeObject(forKey: Config.userDefaultKeys.incomingListInviteInviteUid)
        }
    }
}
