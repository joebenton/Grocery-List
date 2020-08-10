//
//  SettingsViewModel.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

class SettingsViewModel: ViewModel {
    weak var coordinator: SettingsCoordinator?
    weak var viewController: SettingsViewController?

    @Injected private var authService: AuthService
    
    var settingsItems = Array<SettingsItem>()
    
    init(with coordinator: SettingsCoordinator) {
        self.coordinator = coordinator
    }
    
    func viewReady() {
        buildSettingsItems()
    }
    
    fileprivate func buildSettingsItems() {
        var settingsItems = [
            SettingsItem(type: .editAccount, accessory: .arrow),
            SettingsItem(type: .notificationSettings, accessory: .arrow),
            SettingsItem(type: .about, accessory: .arrow),
            SettingsItem(type: .support, accessory: .arrow),
            SettingsItem(type: .feedback, accessory: .arrow),
            SettingsItem(type: .logout, accessory: .none)
        ]
        
        if authService.isUserPasswordType() == true {
            settingsItems.insert(SettingsItem(type: .changePassword, accessory: .arrow), at: 1)
        }
        
        self.settingsItems = settingsItems
        viewController?.reloadTableView()
    }
    
    func didSelectItem(settingsItem: SettingsItem) {
        switch settingsItem.type {
        case .editAccount:
            coordinator?.gotoEditAccount()
        case .changePassword:
            coordinator?.gotoChangePassword()
        case .notificationSettings:
            coordinator?.gotoAppSettings()
        case .about:
            coordinator?.gotoSafariBrowserAbout()
        case .support:
            coordinator?.gotoSafariSupport()
        case .feedback:
            coordinator?.gotoSafariBrowserFeedback()
        case .logout:
            logout()
        }
    }
    
    fileprivate func logout() {
        viewController?.showLogoutAlert()
    }
    
    func logoutConfirmed() {
        viewController?.view.isUserInteractionEnabled = false
        authService.logoutUser { [weak self] result in
            DispatchQueue.main.async {
                self?.viewController?.view.isUserInteractionEnabled = true

                switch result {
                case .success:
                    self?.coordinator?.didLogout()
                case .failure(let error):
                    self?.viewController?.showAlert(title: "Logout", message: error.message)
                }
            }
        }
    }
}
