//
//  SettingsItem.swift
//  Grocery List
//
//  Created by Joe Benton on 08/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct SettingsItem {
    let type: SettingsItemType
    let accessory: SettingsItemAccessory
}

enum SettingsItemType: String {
    case editAccount = "Edit Account Profile"
    case changePassword = "Change Password"
    case notificationSettings = "Notification Settings"
    case about = "About"
    case support = "Get Support"
    case feedback = "Send Feedback"
    case logout = "Logout"
}

enum SettingsItemAccessory {
    case arrow
    case text(text: String)
    case none
}
