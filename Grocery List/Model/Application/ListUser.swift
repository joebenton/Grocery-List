//
//  ListUser.swift
//  Grocery List
//
//  Created by Joe Benton on 17/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

enum ListUserType {
    case pendingInvite(invite: ShareInvite)
    case user(user: User, acceptedInvite: ShareInvite?)
    
    var sortOrder: Int {
        switch self {
        case .user:
            return 0
        case .pendingInvite:
            return 1
        }
    }
}

struct ListUser {
    let type: ListUserType
}
