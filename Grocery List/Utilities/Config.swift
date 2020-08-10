//
//  Config.swift
//  Grocery List
//
//  Created by Joe Benton on 19/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct Config {
    static let userDefaultKeys = UserDefaultKeys()
}

struct UserDefaultKeys {
    let appleSignInUserId = "appleSignInUserId"
    let reviewAppVersion = "reviewAppVersion"
    let reviewEventCount = "reviewEventCount"
    let incomingListInviteListUid = "incomingListInviteListUid"
    let incomingListInviteInviteUid = "incomingListInviteInviteUid"
}
