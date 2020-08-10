//
//  AddNotificationRequest.swift
//  Grocery List
//
//  Created by Joe Benton on 30/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct AddNotificationRequest: Codable {
    let title: String
    let body: String
    let changeUid: String
    let changeUserUid: String
    let listUid: String
    let timestamp: Int
    let opened: Bool
}
