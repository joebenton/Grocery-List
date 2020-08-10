//
//  ListsHomeViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class ListsHomeViewModel: ViewModel {
    weak var coordinator: ListsHomeCoordinator?
    weak var viewController: ListsHomeViewController?

    @Injected var authService: AuthService
    @Injected var listsService: ListsService
    
    var lists = Array<List>()
    var categories = Array<ListCategory>()
    
    init(with coordinator: ListsHomeCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        getLists()
        getUnreadNotificationsCount()
    }
    
    fileprivate func getLists() {
        guard let userUid = authService.getUserUid() else { return }

        viewController?.toggleLoadingIndicator(loading: true)

        listsService.getLists(category: .all, userUid: userUid) { [weak self] (result) in
            DispatchQueue.main.async {
                self?.viewController?.toggleLoadingIndicator(loading: false)

                switch result {
                case .success(let lists):
                    self?.lists = lists
                    self?.buildCategories()
                    self?.configureEmptyTooltip()
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
    
    fileprivate func configureEmptyTooltip() {
        if lists.count == 0 {
            viewController?.toggleEmptyTooltip(show: true)
        } else {
            viewController?.toggleEmptyTooltip(show: false)
        }
    }
    
    fileprivate func buildCategories() {
        let allCount = lists.count
        
        let vipCount = lists.filter { (list) -> Bool in
            return list.vip
        }.count
        
        let completedCount = lists.filter { (list) -> Bool in
            return list.completed
        }.count
        
        let dueTodayCount = lists.filter { (list) -> Bool in
            guard let dueDate = list.dueDate else { return false }
            return Int(dueDate.timeIntervalSince1970) > Int(Date().startOfDay.timeIntervalSince1970) && Int(dueDate.timeIntervalSince1970) <= Int(Date().endOfDay.timeIntervalSince1970)
        }.count
        
        let dueThisWeekCount = lists.filter { (list) -> Bool in
            guard let dueDate = list.dueDate else { return false }
            guard let weekStartTimestamp = Date().startOfWeek?.timeIntervalSince1970 else { return false }
            guard let weekEndTimestamp = Date().endOfWeek?.timeIntervalSince1970 else { return false }
            return Int(dueDate.timeIntervalSince1970) > Int(weekStartTimestamp) && Int(dueDate.timeIntervalSince1970) < Int(weekEndTimestamp)
        }.count
        
        let sharedCount = lists.filter { (list) -> Bool in
            return list.invitesCount > 0
        }.count
        
        categories = [
            ListCategory(type: .all, itemsCount: allCount),
            ListCategory(type: .dueToday, itemsCount: dueTodayCount),
            ListCategory(type: .dueThisWeek, itemsCount: dueThisWeekCount),
            ListCategory(type: .vip, itemsCount: vipCount),
            ListCategory(type: .shared, itemsCount: sharedCount),
            ListCategory(type: .completed, itemsCount: completedCount)
        ]
        viewController?.reloadTableView()
    }
    
    func didSelectCategory(category: ListCategory) {
        coordinator?.gotoListCategory(category: category.type)
    }
    
    func notificationsBtnPressed() {
        coordinator?.gotoNotifications()
    }
}
