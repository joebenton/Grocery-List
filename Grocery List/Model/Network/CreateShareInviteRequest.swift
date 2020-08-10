//
//  CreateShareInviteRequest.swift
//  Grocery List
//
//  Created by Joe Benton on 17/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct CreateShareInviteRequest: Codable {
    let name: String
    let createdDate: Int
    let status: String
    let listName: String
}

