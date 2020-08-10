//
//  NotificationsViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class NotificationsViewModel: ViewModel {
    weak var coordinator: NotificationsCoordinator?
    weak var viewController: NotificationsViewController?

    @Injected private var authService: AuthService
    @Injected private var listsService: ListsService
    @Injected private var fileService: FileService
    
    var notifications = Array<ActivityNotification>()
    
    init(with coordinator: NotificationsCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        buildNotifications()
    }
    
    func buildNotifications() {
        notifications = []
        getOpenedLocalNotifications()
        getActivityNotifications()
    }
    
    func getOpenedLocalNotifications() {
        let openedLocalNotifications = fileService.getOpenedLocalNotifications()
        let openedActivityNotifications = openedLocalNotifications.map { (openedListReminder) -> ActivityNotification in
            return ActivityNotification(id: openedListReminder.id, type: .localNotificationListReminder, title: openedListReminder.title, body: openedListReminder.body, listUid: openedListReminder.listUid, timestamp: openedListReminder.timestamp, changeUid: "", changeUserUid: "", changeUserPicture: nil, opened: true)
        }
        notifications.append(contentsOf: openedActivityNotifications)
    }
    
    fileprivate func getActivityNotifications() {
        viewController?.toggleLoadingIndicator(loading: true)
        
        authService.getNotifications { [weak self] (result) in
            DispatchQueue.main.async {
                self?.viewController?.toggleLoadingIndicator(loading: false)
                
                switch result {
                case .success(let notifications):
                    self?.notifications.append(contentsOf: notifications)
                    self?.sortNotifications()
                    self?.getUsersPictures()
                    self?.viewController?.reloadTableView()
                case .failure(let error):
                    self?.viewController?.showAlert(title: "Notifications Error", message: error.message)
                }
            }
        }
    }
    
    func getUsersPictures() {
        let userIds = notifications.compactMap { (notification) -> String? in
            return notification.changeUserUid
        }
        
        let uniqueUserIds = Array(Set(userIds))
        
        authService.getUsersProfiles(userUids: uniqueUserIds) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let profiles):
                    var userPictures = Dictionary<String, String>()
                    
                    profiles.forEach { (profile) in
                        if profile.pictureUrl.count > 0 {
                            userPictures[profile.userId] = profile.pictureUrl
                        }
                    }
                    
                    guard let notifications = self?.notifications else { return }
                    for (index, notification) in notifications.enumerated() {
                        if let userPictureUrl = userPictures[notification.changeUserUid] {
                            self?.notifications[index].changeUserPicture = userPictureUrl
                        }
                    }
                    self?.viewController?.reloadTableView()
                case .failure(let error):
                    self?.viewController?.showAlert(title: "Get Profiles", message: error.message)
                }
            }
        }
    }
    
    func sortNotifications() {
        self.notifications.sort { (notificationA, notificationB) -> Bool in
            return notificationA.timestamp > notificationB.timestamp
        }
    }
    
    func viewClosed() {
        coordinator?.finish()
    }

    func didSelectNotification(notification: ActivityNotification) {
        if notification.listUid.count > 0 {
            coordinator?.gotoListDetail(listUid: notification.listUid)
        }
        
        if notification.opened == false && notification.type == .pushNotification {
            guard let userUid = authService.getUserUid() else { return }
            authService.markNotificationOpened(userUid: userUid, notificationUid: notification.id) { [weak self] (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        self?.viewController?.showAlert(title: "Notification Error", message: error.message)
                    }
                }
            }
        }
    }
    
    func notificationSwipedToDelete(notification: ActivityNotification) {
        switch notification.type {
        case .pushNotification:
            guard let userUid = authService.getUserUid() else { return }

            viewController?.toggleOverlayLoading(show: true)
            
            authService.deleteNotification(userUid: userUid, notificationUid: notification.id) { [weak self] (result) in
                DispatchQueue.main.async {
                    self?.viewController?.toggleOverlayLoading(show: false)

                    switch result {
                    case .success:
                        self?.buildNotifications()
                    case .failure(let error):
                        self?.viewController?.showAlert(title: "Delete Notification Error", message: error.message)
                    }
                }
            }
        case .localNotificationListReminder:
            fileService.deleteOpenedLocalNotification(notificationId: notification.id)
            buildNotifications()
        }
    }
    
}
