//
//  ListsService.swift
//  Grocery List
//
//  Created by Joe Benton on 25/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Firebase

class ListsService {
    let db = Firestore.firestore()

    var listItemsListenerRegistration: ListenerRegistration?
    
    func createList(userUid: String, list: CreateList, completion: @escaping (Result<CreateListResponse, DisplayableError>) -> Void) {
        guard userUid.count > 0 else {
            completion(.failure(DisplayableError(message: "User UID not valid")))
            return
        }
        
        let dueDateTimestamp = list.dueDate != nil ? Int(list.dueDate!.timeIntervalSince1970) : nil
        
        let createdDate = Int(Date().timeIntervalSince1970)
        let roles = [userUid: Role.owner.rawValue]
        
        let createListRequest = CreateListRequest(name: list.name, notes: list.notes, vip: list.vip, dueDate: dueDateTimestamp, createdDate: createdDate, roles: roles, completed: false)
        
        var createListRef: DocumentReference?
        createListRef = db.collection("lists").addDocument(data: createListRequest.dictionary) { err in
            if let err = err {
                print("Error creating list: \(err.localizedDescription) with data: \(createListRequest.dictionary)")
                completion(.failure(DisplayableError(message: err.localizedDescription)))
            } else {
                guard let newListUid = createListRef?.documentID else {
                    completion(.failure(DisplayableError(message: "Error getting new list UID")))
                    return
                }
                completion(.success(CreateListResponse(uid: newListUid)))
            }
        }
    }
    
    func addListItems(listUid: String, userUid: String, items: Array<CreateItem>, completion: @escaping (Result<CreateItemsResponse, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        guard userUid.count > 0 else {
            completion(.failure(DisplayableError(message: "User UID not valid")))
            return
        }
                
        let createdDate = Int(Date().timeIntervalSince1970)
        
        let batch = db.batch()
        
        let itemsCollectionRef = db.collection("lists").document(listUid).collection("items")
        
        var newItemsIds = Array<String>()
        
        for item in items {
            let createItemRequest = CreateItemRequest(userUid: userUid, name: item.name, unitType: item.unitType.rawValue, quantity: item.quantity, checked: false, createdDate: createdDate)
            let newItemDocRef = itemsCollectionRef.document()
            batch.setData(createItemRequest.dictionary, forDocument: newItemDocRef)
            newItemsIds.append(newItemDocRef.documentID)
        }
        
        batch.commit { (error) in
            if let error = error {
                if (error as NSError).code == FirestoreErrorCode.permissionDenied.rawValue {
                    completion(.failure(DisplayableError(message: "The list is unavailable or no longer exists")))
                } else {
                    print("Error adding list items: \(error.localizedDescription)")
                    completion(.failure(DisplayableError(message: error.localizedDescription)))
                }
            } else {
                completion(.success(CreateItemsResponse(uids: newItemsIds)))
            }
        }
    }
    
    func getLists(category: ListsCategoryType, userUid: String, completion: @escaping (Result<Array<List>, DisplayableError>) -> Void) {
        guard userUid.count > 0 else {
            completion(.failure(DisplayableError(message: "User UID not valid")))
            return
        }
        
        var query = db.collection("lists").whereField("roles.\(userUid)", in: [Role.owner.rawValue, Role.collaborator.rawValue])
        
        switch category {
        case .all: break
        case .dueToday:
            //Filter lists locally
            break
        case .dueThisWeek:
            //Filter lists locally
            break
        case .vip:
            query = query.whereField("vip", isEqualTo: true)
        case .shared:
            //Filter lists locally
            break
        case .completed:
            query = query.whereField("completed", isEqualTo: true)
        }
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error loading lists: \(error.localizedDescription)")
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                var listsResponse = Array<ListResponse>()
                for document in snapshot!.documents {
                    listsResponse.append(ListResponse(documentId: document.documentID, documentData: document.data()))
                }
                
                //Filter lists locally for date ranges
                let filteredListsResponse = listsResponse.filter { (list) -> Bool in
                    switch category {
                    case .dueToday:
                        guard let dueDate = list.dueDate else { return false }
                        let dayStartTimestamp = Int(Date().startOfDay.timeIntervalSince1970)
                        let dayEndTimestamp = Int(Date().endOfDay.timeIntervalSince1970)
                        return dueDate > dayStartTimestamp && dueDate <= dayEndTimestamp
                    case .dueThisWeek:
                        guard let dueDate = list.dueDate else { return false }
                        guard let weekStartTimestamp = Date().startOfWeek?.timeIntervalSince1970 else { return false }
                        guard let weekEndTimestamp = Date().endOfWeek?.timeIntervalSince1970 else { return false }
                        return dueDate > Int(weekStartTimestamp) && dueDate < Int(weekEndTimestamp)
                    case .shared:
                        return list.invitesCount > 0
                    default: break
                    }
                    return true
                }
                
                let lists = filteredListsResponse.map { (listResponse) -> List in
                    let dueDate = listResponse.dueDate != nil ? Date(timeIntervalSince1970: TimeInterval(listResponse.dueDate!)) : nil
                    
                    var viewAsRole = Role.collaborator
                    if let userRoleString = listResponse.roles[userUid], let userRole = Role(rawValue: userRoleString) {
                        viewAsRole = userRole
                    }
                    
                    let list = List(id: listResponse.id, name: listResponse.name, notes: listResponse.notes, vip: listResponse.vip, dueDate: dueDate, roles: listResponse.roles, completed: listResponse.completed, itemsCount: listResponse.itemsCount, invitesCount: listResponse.invitesCount, viewAs: viewAsRole)
                    return list
                }
                
                completion(.success(lists))
            }
        }
    }
    
    func getList(listUid: String, userUid: String, completion: @escaping (Result<List, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        guard userUid.count > 0 else {
            completion(.failure(DisplayableError(message: "User UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).getDocument { (snapshot, error) in
            if let error = error {
                print("Error loading list: \(error.localizedDescription)")
                if (error as NSError).code == FirestoreErrorCode.permissionDenied.rawValue {
                    completion(.failure(DisplayableError(message: "The list is unavailable or no longer exists")))
                } else {
                    completion(.failure(DisplayableError(message: error.localizedDescription)))
                }
            } else {
                guard snapshot?.exists == true else {
                    completion(.failure(DisplayableError(message: "List not found")))
                    return
                }
                
                guard let documentID = snapshot?.documentID, let data = snapshot?.data() else {
                    completion(.failure(DisplayableError(message: "List id or data not found")))
                    return
                }
                
                let listResponse = ListResponse(documentId: documentID, documentData: data)
                
                let dueDate = listResponse.dueDate != nil ? Date(timeIntervalSince1970: TimeInterval(listResponse.dueDate!)) : nil
                
                var viewAsRole = Role.collaborator
                if let userRoleString = listResponse.roles[userUid], let userRole = Role(rawValue: userRoleString) {
                    viewAsRole = userRole
                }
                
                let list = List(id: listResponse.id, name: listResponse.name, notes: listResponse.notes, vip: listResponse.vip, dueDate: dueDate, roles: listResponse.roles, completed: listResponse.completed, itemsCount: listResponse.itemsCount, invitesCount: listResponse.invitesCount, viewAs: viewAsRole)
                
                completion(.success(list))
            }
        }
    }
    
    func getListItems(listUid: String, completion: @escaping (Result<Array<Item>, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).collection("items").order(by: "checked", descending: false).order(by: "createdDate", descending: false).getDocuments { (snapshot, error) in
            if let error = error {
                if (error as NSError).code == FirestoreErrorCode.permissionDenied.rawValue {
                    completion(.failure(DisplayableError(message: "The list is unavailable or no longer exists")))
                } else {
                    print("Error loading items: \(error.localizedDescription)")
                    completion(.failure(DisplayableError(message: error.localizedDescription)))
                }
            } else {
                var itemsResponse = Array<ItemsResponse>()
                for document in snapshot!.documents {
                    itemsResponse.append(ItemsResponse(documentId: document.documentID, documentData: document.data()))
                }
                
                let items = itemsResponse.map { (itemsResponse) -> Item in
                    let unitType = UnitType(rawValue: itemsResponse.unitType) ?? .pcs
                    let item = Item(id: itemsResponse.id, name: itemsResponse.name, unitType: unitType, quantity: itemsResponse.quantity, checked: itemsResponse.checked)
                    return item
                }
                
                completion(.success(items))
            }
        }
    }
    
    func addListenerForListItemsChanges(listUid: String, completion: @escaping (Result<Array<Item>, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        listItemsListenerRegistration?.remove()
        listItemsListenerRegistration = db.collection("lists").document(listUid).collection("items").order(by: "checked", descending: false).order(by: "createdDate", descending: false).addSnapshotListener { (snapshot, error) in
            if let error = error {
                if (error as NSError).code == FirestoreErrorCode.permissionDenied.rawValue {
                    completion(.failure(DisplayableError(message: "The list is unavailable or no longer exists")))
                } else {
                    print("Error loading items: \(error.localizedDescription)")
                    completion(.failure(DisplayableError(message: error.localizedDescription)))
                }
            } else {
                var itemsResponse = Array<ItemsResponse>()
                for document in snapshot!.documents {
                    itemsResponse.append(ItemsResponse(documentId: document.documentID, documentData: document.data()))
                }
                
                let items = itemsResponse.map { (itemsResponse) -> Item in
                    let unitType = UnitType(rawValue: itemsResponse.unitType) ?? .pcs
                    let item = Item(id: itemsResponse.id, name: itemsResponse.name, unitType: unitType, quantity: itemsResponse.quantity, checked: itemsResponse.checked)
                    return item
                }
                
                completion(.success(items))
            }
        }
    }
    
    func removeListenerForListItemChanges() {
        listItemsListenerRegistration?.remove()
    }
    
    func editList(list: List, completion: @escaping (Result<EditListResponse, DisplayableError>) -> Void) {
        guard list.id.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        let dueDateTimestamp = list.dueDate != nil ? Int(list.dueDate!.timeIntervalSince1970) : nil
        
        let editedDate = Int(Date().timeIntervalSince1970)
        
        let editListRequest = EditListRequest(name: list.name, notes: list.notes, vip: list.vip, dueDate: dueDateTimestamp, updatedDate: editedDate)
        
        var editListRequestDict = editListRequest.dictionary
        if editListRequest.dueDate == nil {
            editListRequestDict["dueDate"] = FieldValue.delete()
        }
        
        db.collection("lists").document(list.id).updateData(editListRequestDict) { err in
            if let err = err {
                if (err as NSError).code == FirestoreErrorCode.permissionDenied.rawValue {
                    completion(.failure(DisplayableError(message: "The list is unavailable or no longer exists")))
                } else {
                    print("Error editing list: \(err.localizedDescription) with data: \(editListRequest.dictionary)")
                    completion(.failure(DisplayableError(message: err.localizedDescription)))
                }
            } else {
                completion(.success(EditListResponse()))
            }
        }
    }
    
    func deleteList(listUid: String, completion: @escaping (Result<DeleteListResponse, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).delete() { err in
            if let err = err {
                if (err as NSError).code == FirestoreErrorCode.permissionDenied.rawValue {
                    completion(.failure(DisplayableError(message: "The list is unavailable or no longer exists")))
                } else {
                    print("Error delete list: \(err.localizedDescription)")
                    completion(.failure(DisplayableError(message: err.localizedDescription)))
                }
            } else {
                completion(.success(DeleteListResponse()))
            }
        }
    }
    
    func toggleListCompleted(listUid: String, completed: Bool, completion: @escaping (Result<ToggleListCompletedResponse, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).updateData(["completed": completed]) { err in
            if let err = err {
                if (err as NSError).code == FirestoreErrorCode.permissionDenied.rawValue {
                    completion(.failure(DisplayableError(message: "The list is unavailable or no longer exists")))
                } else {
                    print("Error toggling completed list: \(err.localizedDescription)")
                    completion(.failure(DisplayableError(message: err.localizedDescription)))
                }
            } else {
                completion(.success(ToggleListCompletedResponse()))
            }
        }
    }
    
    func deleteListItem(listUid: String, itemUid: String, completion: @escaping (Result<DeleteListItemResponse, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        guard itemUid.count > 0 else {
            completion(.failure(DisplayableError(message: "Item UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).collection("items").document(itemUid).delete() { err in
            if let err = err {
                if (err as NSError).code == FirestoreErrorCode.permissionDenied.rawValue {
                    completion(.failure(DisplayableError(message: "The list or item is unavailable or no longer exists")))
                } else {
                    print("Error delete list item: \(err.localizedDescription)")
                    completion(.failure(DisplayableError(message: err.localizedDescription)))
                }
            } else {
                completion(.success(DeleteListItemResponse()))
            }
        }
    }
    
    func toggleCheckedListItem(listUid: String, itemUid: String, checked: Bool, completion: @escaping (Result<DeleteListItemResponse, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        guard itemUid.count > 0 else {
            completion(.failure(DisplayableError(message: "Item UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).collection("items").document(itemUid).updateData(["checked": checked]) { err in
            if let err = err {
                if (err as NSError).code == FirestoreErrorCode.permissionDenied.rawValue {
                    completion(.failure(DisplayableError(message: "The list or item is unavailable or no longer exists")))
                } else {
                    print("Error toggling checked list item: \(err.localizedDescription)")
                    completion(.failure(DisplayableError(message: err.localizedDescription)))
                }
            } else {
                completion(.success(DeleteListItemResponse()))
            }
        }
    }
    
    func editListItem(listUid: String, item: Item, completion: @escaping (Result<EditItemResponse, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
                
        let editedDate = Int(Date().timeIntervalSince1970)
        
        let editItemRequest = EditItemRequest(name: item.name, unitType: item.unitType.rawValue, quantity: item.quantity, checked: item.checked, updatedDate: editedDate)
        
        db.collection("lists").document(listUid).collection("items").document(item.id).updateData(editItemRequest.dictionary) { err in
            if let err = err {
                if (err as NSError).code == FirestoreErrorCode.permissionDenied.rawValue {
                    completion(.failure(DisplayableError(message: "The list or item is unavailable or no longer exists")))
                } else {
                    print("Error editing list item: \(err.localizedDescription) with data: \(editItemRequest.dictionary)")
                    completion(.failure(DisplayableError(message: err.localizedDescription)))
                }
            } else {
                completion(.success(EditItemResponse()))
            }
        }
    }
    
    func createListShareInvite(listUid: String, name: String, listName: String, completion: @escaping (Result<String, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        let createdDate = Int(Date().timeIntervalSince1970)

        let createShareInviteRequest = CreateShareInviteRequest(name: name, createdDate: createdDate, status: "pending", listName: listName)
        
        var createShareInviteRef: DocumentReference?
        createShareInviteRef = db.collection("lists").document(listUid).collection("invites").addDocument(data: createShareInviteRequest.dictionary) { err in
            if let error = err {
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                guard let newShareInviteUid = createShareInviteRef?.documentID else {
                    completion(.failure(DisplayableError(message: "Error getting new share invite UID")))
                    return
                }
                completion(.success(newShareInviteUid))
            }
        }
    }
    
    func getListPendingInvites(listUid: String, completion: @escaping (Result<Array<ShareInvite>, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).collection("invites").whereField("status", isEqualTo: "pending").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error loading list share invites: \(error.localizedDescription)")
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                var shareInvitesResponse = Array<ShareInviteResponse>()
                for document in snapshot!.documents {
                    shareInvitesResponse.append(ShareInviteResponse(documentId: document.documentID, documentData: document.data()))
                }
                
                let shareInvites = shareInvitesResponse.map { (shareInviteResponse) -> ShareInvite in
                    let shareInvite = ShareInvite(id: shareInviteResponse.id, name: shareInviteResponse.name, link: shareInviteResponse.link, listName: shareInviteResponse.listName, status: shareInviteResponse.status, acceptedBy: shareInviteResponse.acceptedBy)
                    return shareInvite
                }
                
                completion(.success(shareInvites))
            }
        }
    }
    
    func getListInvites(listUid: String, completion: @escaping (Result<Array<ShareInvite>, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).collection("invites").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error loading list share invites: \(error.localizedDescription)")
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                var shareInvitesResponse = Array<ShareInviteResponse>()
                for document in snapshot!.documents {
                    shareInvitesResponse.append(ShareInviteResponse(documentId: document.documentID, documentData: document.data()))
                }
                
                let shareInvites = shareInvitesResponse.map { (shareInviteResponse) -> ShareInvite in
                    let shareInvite = ShareInvite(id: shareInviteResponse.id, name: shareInviteResponse.name, link: shareInviteResponse.link, listName: shareInviteResponse.listName, status: shareInviteResponse.status, acceptedBy: shareInviteResponse.acceptedBy)
                    return shareInvite
                }
                
                completion(.success(shareInvites))
            }
        }
    }
    
    func getListInvite(listUid: String, inviteUid: String, completion: @escaping (Result<ShareInvite, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        guard inviteUid.count > 0 else {
            completion(.failure(DisplayableError(message: "Invite UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).collection("invites").document(inviteUid).getDocument { (snapshot, error) in
            if let error = error {
                print("Error loading list share invite: \(error.localizedDescription)")
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                guard snapshot?.exists == true else {
                    completion(.failure(DisplayableError(message: "The invite no longer exists. Ask the owner to send another link.")))
                    return
                }
                
                guard let documentID = snapshot?.documentID, let data = snapshot?.data() else {
                    completion(.failure(DisplayableError(message: "Invite id or data not found")))
                    return
                }
                
                let inviteResponse = ShareInviteResponse(documentId: documentID, documentData: data)
                let invite = ShareInvite(id: inviteResponse.id, name: inviteResponse.name, link: inviteResponse.link, listName: inviteResponse.listName, status: inviteResponse.status, acceptedBy: inviteResponse.acceptedBy)
                completion(.success(invite))
            }
        }
    }
    
    func updateListShareInviteLink(listUid: String, inviteUid: String, link: String, completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        guard inviteUid.count > 0 else {
            completion(.failure(DisplayableError(message: "Invite UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).collection("invites").document(inviteUid).updateData(["link": link]) { err in
            if let error = err {
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func deleteListShareInvite(listUid: String, inviteUid: String, completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        guard inviteUid.count > 0 else {
            completion(.failure(DisplayableError(message: "Invite UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).collection("invites").document(inviteUid).delete() { err in
            if let error = err {
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func acceptListShareInviteLink(listUid: String, inviteUid: String, userUid: String, completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        guard inviteUid.count > 0 else {
            completion(.failure(DisplayableError(message: "Invite UID not valid")))
            return
        }
        
        guard userUid.count > 0 else {
            completion(.failure(DisplayableError(message: "User UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).collection("invites").document(inviteUid).getDocument { (snapshot, error) in
            if let error = error {
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                guard snapshot?.exists == true else {
                    completion(.failure(DisplayableError(message: "The invite no longer exists. Ask the owner to send another link.")))
                    return
                }
                
                guard let documentID = snapshot?.documentID, let data = snapshot?.data() else {
                    completion(.failure(DisplayableError(message: "Invite id or data not found")))
                    return
                }
                
                let inviteResponse = ShareInviteResponse(documentId: documentID, documentData: data)
                guard inviteResponse.status == "pending" else {
                    completion(.failure(DisplayableError(message: "The invite has already been accepted and is no longer available. Ask the owner to send another link.")))
                    return
                }
                
                self.db.collection("lists").document(listUid).getDocument { (snapshot, error) in
                    if let error = error {
                        if (error as NSError).code != FirestoreErrorCode.permissionDenied.rawValue {
                            completion(.failure(DisplayableError(message: error.localizedDescription)))
                            return
                        }
                    } else {
                        guard snapshot?.exists == true else {
                            completion(.failure(DisplayableError(message: "The list no longer exists.")))
                            return
                        }
                        guard let documentID = snapshot?.documentID, let data = snapshot?.data() else {
                            completion(.failure(DisplayableError(message: "List id or data not found")))
                            return
                        }
                        
                        let listResponse = ListResponse(documentId: documentID, documentData: data)
                        if listResponse.roles[userUid] != nil {
                            completion(.failure(DisplayableError(message: "You are already a user of this list")))
                            return
                        }
                    }
                    
                    self.db.collection("lists").document(listUid).updateData(["roles.\(userUid)": Role.collaborator.rawValue]) { error in
                        if let error = error {
                            completion(.failure(DisplayableError(message: error.localizedDescription)))
                        } else {
                            self.db.collection("lists").document(listUid).collection("invites").document(inviteUid).updateData([
                                "status":"accepted",
                                "acceptedBy": userUid
                            ]) { error in
                                if let error = error {
                                    completion(.failure(DisplayableError(message: error.localizedDescription)))
                                } else {
                                    completion(.success(true))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removeUserFromList(listUid: String, userUid: String, completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        guard userUid.count > 0 else {
            completion(.failure(DisplayableError(message: "User UID not valid")))
            return
        }
        
        db.collection("lists").document(listUid).updateData(["roles.\(userUid)": FieldValue.delete()]) { error in
            if let error = error {
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func addItemChangeEntry(listUid: String, userUid: String, change: ItemChange, completion: @escaping (Result<CreateItemChangeResponse, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
            completion(.failure(DisplayableError(message: "List UID not valid")))
            return
        }
        
        guard userUid.count > 0 else {
            completion(.failure(DisplayableError(message: "User UID not valid")))
            return
        }
        
        let createdDate = Int(Date().timeIntervalSince1970)
        let type = change.type.rawValue
        let createItemChangeRequest = CreateItemChangeRequest(itemUids: change.itemUids, userUid: userUid, type: type, changeDescription: change.changeDescription, timestamp: createdDate)
        
        var createChangeEntryRef: DocumentReference?
        createChangeEntryRef = db.collection("lists").document(listUid).collection("changes").addDocument(data: createItemChangeRequest.dictionary) { err in
            if let err = err {
                print("Error creating change entry: \(err.localizedDescription) with data: \(createItemChangeRequest.dictionary)")
                completion(.failure(DisplayableError(message: err.localizedDescription)))
            } else {
                guard let newItemChangeUid = createChangeEntryRef?.documentID else {
                    completion(.failure(DisplayableError(message: "Error getting new item change UID")))
                    return
                }
                completion(.success(CreateItemChangeResponse(uid: newItemChangeUid)))
            }
        }
    }
    
    func addRemovedCollaboratorNotification(listName: String, userUid: String, ownerUserUid: String, completion: @escaping (Result<AddNotificationResponse, DisplayableError>) -> Void) {
        guard userUid.count > 0 else {
           completion(.failure(DisplayableError(message: "User UID not valid")))
           return
        }
        
        let createdDate = Int(Date().timeIntervalSince1970)
        let title = "\(listName) - Collaborator Removed"
        let message = "You have been removed from the list \(listName)"
        let addNotificationRequest = AddNotificationRequest(title: title, body: message, changeUid: "", changeUserUid: ownerUserUid, listUid: "", timestamp: createdDate, opened: false)
        
        var addNotificationRef: DocumentReference?
        addNotificationRef = db.collection("users").document(userUid).collection("notifications").addDocument(data: addNotificationRequest.dictionary) { err in
            if let err = err {
                print("Error creating notification entry: \(err.localizedDescription) with data: \(addNotificationRequest.dictionary)")
                completion(.failure(DisplayableError(message: err.localizedDescription)))
            } else {
                guard let addNotificationId = addNotificationRef?.documentID else {
                    completion(.failure(DisplayableError(message: "Error getting new notification UID")))
                    return
                }
                completion(.success(AddNotificationResponse(uid: addNotificationId)))
            }
        }
    }

    func addAcceptedInviteNotification(listUid: String, listName: String, acceptedInviteUserUid: String, acceptedInviteUserName: String, ownerUserUid: String, completion: @escaping (Result<AddNotificationResponse, DisplayableError>) -> Void) {
        guard listUid.count > 0 else {
           completion(.failure(DisplayableError(message: "List UID not valid")))
           return
        }
        
        guard listName.count > 0 else {
           completion(.failure(DisplayableError(message: "List name not valid")))
           return
        }
        
        guard acceptedInviteUserUid.count > 0 else {
           completion(.failure(DisplayableError(message: "User UID not valid")))
           return
        }
        
        guard acceptedInviteUserName.count > 0 else {
           completion(.failure(DisplayableError(message: "User Name not valid")))
           return
        }
        
        guard ownerUserUid.count > 0 else {
           completion(.failure(DisplayableError(message: "Owner User UID not valid")))
           return
        }
        
        let createdDate = Int(Date().timeIntervalSince1970)
        let title = "\(listName) - Invite Accepted"
        let message = "\(acceptedInviteUserName) has accepted your invitation to collaborate on the grocery list \(listName)"
        let addNotificationRequest = AddNotificationRequest(title: title, body: message, changeUid: "", changeUserUid: acceptedInviteUserUid, listUid: listUid, timestamp: createdDate, opened: false)
        
        var addNotificationRef: DocumentReference?
        addNotificationRef = db.collection("users").document(ownerUserUid).collection("notifications").addDocument(data: addNotificationRequest.dictionary) { err in
            if let err = err {
                print("Error creating notification entry: \(err.localizedDescription) with data: \(addNotificationRequest.dictionary)")
                completion(.failure(DisplayableError(message: err.localizedDescription)))
            } else {
                guard let addNotificationId = addNotificationRef?.documentID else {
                    completion(.failure(DisplayableError(message: "Error getting new notification UID")))
                    return
                }
                completion(.success(AddNotificationResponse(uid: addNotificationId)))
            }
        }
    }
}
