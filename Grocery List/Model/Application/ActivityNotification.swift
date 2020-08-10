//
//  ActivityNotification.swift
//  Grocery List
//
//  Created by Joe Benton on 23/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

enum ActivityNotificationType {
    case pushNotification
    case localNotificationListReminder
}

struct ActivityNotification {
    let id: String
    let type: ActivityNotificationType
    let title: String
    let body: String
    let listUid: String
    let timestamp: Int
    let changeUid: String
    let changeUserUid: String
    var changeUserPicture: String?
    let opened: Bool
}
