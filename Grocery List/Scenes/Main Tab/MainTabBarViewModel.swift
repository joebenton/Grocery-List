//
//  MainTabBarViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Resolver

class MainTabBarViewModel: ViewModel {

    weak var coordinator: MainTabCoordinator?
    weak var viewController: MainTabBarController?

    @Injected var authService: AuthService
    
    init(with coordinator: MainTabCoordinator) {
        self.coordinator = coordinator
    }

    func viewReady() {
        if let incomingListInviteListUid = UserDefaults.standard.value(forKey: Config.userDefaultKeys.incomingListInviteListUid) as? String,
            let incomingListInviteInviteUid = UserDefaults.standard.value(forKey: Config.userDefaultKeys.incomingListInviteInviteUid) as? String {
            let incomingShareInvite = IncomingShareInvite(listUid: incomingListInviteListUid, inviteUid: incomingListInviteInviteUid)
            coordinator?.showListInvitePopup(incomingShareInvite: incomingShareInvite)
        }
    }
    
    func middleBtnPressed() {
        coordinator?.gotoAddEvent()
    }
    
    func viewClosed() {
        coordinator?.finish()
    }
}
