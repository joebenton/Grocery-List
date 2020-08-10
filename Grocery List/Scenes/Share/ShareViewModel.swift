//
//  ShareViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class ShareViewModel: ViewModel {
    weak var coordinator: ShareCoordinator?
    weak var viewController: ShareViewController?

    @Injected private var authService: AuthService
    @Injected private var listsService: ListsService
    @Injected private var dynamicLinksService: DynamicLinksService
    
    var list: List!
    var listUsers = Array<ListUser>()
    
    var shareInvites = Array<ShareInvite>()
    var users = Array<User>()
    
    var usersReady = false
    var pendingInvitesReady = false
    
    init(with coordinator: ShareCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        getUsersAndInvites()
    }
    
    fileprivate func getUsersAndInvites() {
        listUsers = []
        usersReady = false
        pendingInvitesReady = false

        viewController?.toggleOverlayLoading(show: true)
        
        getUsers()
        getShareInvites()
    }
    
    fileprivate func getUsers() {
        guard let userUid = authService.getUserUid() else { return }
        users = []
        
        listsService.getList(listUid: list.id, userUid: userUid) { [weak self] (result) in
            switch result {
            case .success(let updatedList):
                self?.list = updatedList
                
                self?.list.roles.forEach { (userUid, roleKey) in
                    let role = Role(rawValue: roleKey) ?? .collaborator
                    self?.users.append(User(id: userUid, role: role))
                }
                
                guard let users = self?.users else { return }
                
                var userDoneCount = 0
                for user in users {
                    self?.authService.getUsersProfile(userUid: user.id) { [weak self] (result) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let profile):
                                let existingUserIndex = self?.users.firstIndex { (existingUser) -> Bool in
                                    return existingUser.id == user.id
                                }
                                if let userIndex = existingUserIndex {
                                    self?.users[userIndex].profilePictureUrl = profile.pictureUrl
                                    self?.users[userIndex].name = profile.name
                                }
                            default: break
                            }
                            
                            userDoneCount += 1
                            
                            if userDoneCount == (self?.users.count ?? 0) {
                                self?.usersReady = true
                            }
                            
                            if let pendingInvitesReady = self?.pendingInvitesReady, let usersReady = self?.usersReady, pendingInvitesReady == true && usersReady == true {
                                self?.buildListUsers()
                            }
                        }
                    }
                }
            case .failure(let error):
                self?.viewController?.showAlert(title: "List Error", message: error.message)
                self?.viewController?.toggleOverlayLoading(show: false)
            }
        }
    }
    
    fileprivate func getShareInvites() {
        shareInvites = []
        listsService.getListInvites(listUid: list.id) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let shareInvites):
                    self?.shareInvites = shareInvites
                    self?.pendingInvitesReady = true
                case .failure(let error):
                    self?.viewController?.showAlert(title: "Share Invites Error", message: error.message)
                    self?.viewController?.toggleOverlayLoading(show: false)
                }
                if let pendingInvitesReady = self?.pendingInvitesReady, let usersReady = self?.usersReady, pendingInvitesReady == true && usersReady == true {
                    self?.buildListUsers()
                }
            }
        }
    }
    
    fileprivate func buildListUsers() {
        listUsers = []
        
        for user in users {
            switch user.role {
            case .owner:
                listUsers.append(ListUser(type: .user(user: user, acceptedInvite: nil)))
            case .collaborator:
                let listUser = createListUserWithAcceptedInvite(user: user)
                listUsers.append(listUser)
            }
        }
        
        let pendingInvites = shareInvites.filter({ $0.status == "pending" })
        for invite in pendingInvites {
            listUsers.append(ListUser(type: .pendingInvite(invite: invite)))
        }
        
        listUsers.sort { (listUserA, listUserB) -> Bool in
            if listUserA.type.sortOrder == listUserB.type.sortOrder {
                let listUserAType = listUserA.type
                let listUserBType = listUserB.type
                
                if case .user(let userA, _) = listUserAType, case .user(let userB, _) = listUserBType {
                    return userA.role.sortOrder < userB.role.sortOrder
                } else if case .pendingInvite(let inviteA) = listUserAType, case .pendingInvite(let inviteB) = listUserBType {
                    return inviteA.name < inviteB.name
                } else {
                    return true
                }
            } else {
                return listUserA.type.sortOrder < listUserB.type.sortOrder
            }
        }
        
        viewController?.reloadTableView()
        
        viewController?.toggleOverlayLoading(show: false)
    }
    
    fileprivate func createListUserWithAcceptedInvite(user: User) -> ListUser {
        let acceptedInvite = shareInvites.first { (invite) -> Bool in
            return invite.acceptedBy == user.id
        }
        return ListUser(type: .user(user: user, acceptedInvite: acceptedInvite))
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
    
    func didSelectListUser(listUser: ListUser, cellRect: CGRect) {
        guard case .pendingInvite(let invite) = listUser.type else { return }
        viewController?.showSharedInviteShareSheet(url: invite.link, cellRect: cellRect)
    }
    
    func addNewLink(name: String, addBtnRect: CGRect) {
        if name.count == 0 {
            viewController?.showAlert(title: "Share Invite Error", message: "Please enter a name for this share link")
            return
        }
        
        viewController?.toggleOverlayLoading(show: true)
        
        listsService.createListShareInvite(listUid: list.id, name: name, listName: list.name) { [weak self] (result) in
            switch result {
            case .success(let inviteUid):
                guard let listId = self?.list.id else { return }
                self?.dynamicLinksService.generateListInviteLink(listUid: listId, inviteUid: inviteUid) { [weak self] (dynamicLinkResult) in
                    switch dynamicLinkResult {
                    case .success(let inviteUrl):
                        self?.listsService.updateListShareInviteLink(listUid: listId, inviteUid: inviteUid, link: inviteUrl.absoluteString, completion: { [weak self] (updateLinkResult) in
                            DispatchQueue.main.async {
                                self?.viewController?.toggleOverlayLoading(show: false)
                                
                                switch updateLinkResult {
                                case .success:
                                    self?.viewController?.resetNewLinkField()
                                    self?.getUsersAndInvites()
                                    self?.viewController?.showSharedInviteShareSheet(url: inviteUrl.absoluteString, cellRect: addBtnRect)
                                case .failure(let error):
                                    self?.viewController?.showAlert(title: "Share Invite Error", message: error.message)
                                }
                            }
                        })
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self?.viewController?.toggleOverlayLoading(show: false)
                            self?.viewController?.showAlert(title: "Share Invite Error", message: error.message)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.toggleOverlayLoading(show: false)
                    self?.viewController?.showAlert(title: "Share Invite Error", message: error.message)
                }
            }
        }
    }
    
    func listUserSwipedToDelete(listUser: ListUser) {
        switch listUser.type {
        case .pendingInvite(let invite):
            viewController?.showDeleteLinkConfirmPopup(inviteUid: invite.id)
        case .user(let user, _):
            viewController?.showDeleteUserConfirmPopup(userUid: user.id)
        }
    }
    
    func deleteLink(inviteUid: String) {
        viewController?.showDeleteLinkConfirmPopup(inviteUid: inviteUid)
    }
    
    func deleteLinkConfirmed(inviteUid: String) {
        viewController?.toggleOverlayLoading(show: true)
        
        listsService.deleteListShareInvite(listUid: list.id, inviteUid: inviteUid) { [weak self] (result) in
            DispatchQueue.main.async {
                self?.viewController?.toggleOverlayLoading(show: false)
                
                switch result {
                case .success:
                    self?.getUsersAndInvites()
                case .failure(let error):
                    self?.viewController?.showAlert(title: "Delete Share Invite Error", message: error.message)
                }
            }
        }
    }
    
    func deleteUserConfirmed(userUid: String) {
        guard let ownerUserUid = authService.getUserUid() else { return }
        viewController?.toggleOverlayLoading(show: true)
        
        listsService.removeUserFromList(listUid: list.id, userUid: userUid) { [weak self] (result) in
            switch result {
            case .success:
                guard let listName = self?.list.name else { return }
                self?.listsService.addRemovedCollaboratorNotification(listName: listName, userUid: userUid, ownerUserUid: ownerUserUid) { [weak self] (notificationResult) in
                    DispatchQueue.main.async {
                        self?.viewController?.toggleOverlayLoading(show: false)

                        switch result {
                        case .success:
                            self?.getUsersAndInvites()
                        case .failure(let error):
                            self?.viewController?.showAlert(title: "Delete Share Invite Error", message: error.message)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.viewController?.toggleOverlayLoading(show: false)
                    self?.viewController?.showAlert(title: "Delete Share Invite Error", message: error.message)
                }
            }
        }
    }
    
    func deleteBtnPressed(listUser: ListUser) {
        switch listUser.type {
        case .pendingInvite(let invite):
            viewController?.showDeleteLinkConfirmPopup(inviteUid: invite.id)
        case .user(let user, _):
            viewController?.showDeleteUserConfirmPopup(userUid: user.id)
        }
    }
    
    func linkBtnPressed(listUser: ListUser, btnRect: CGRect) {
        switch listUser.type {
        case .pendingInvite(let invite):
            viewController?.showSharedInviteShareSheet(url: invite.link, cellRect: btnRect)
        case .user:
            break
        }
    }

}
