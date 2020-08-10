//
//  CreateItemChangeRequest.swift
//  Grocery List
//
//  Created by Joe Benton on 22/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct CreateItemChangeRequest: Codable {
    let itemUids: Array<String>
    let userUid: String
    let type: Int
    let changeDescription: String?
    let timestamp: Int
}
