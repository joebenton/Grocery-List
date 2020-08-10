//
//  CreateListRequest.swift
//  Grocery List
//
//  Created by Joe Benton on 25/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct CreateListRequest: Codable {
    let name: String
    let notes: String
    let vip: Bool
    let dueDate: Int?
    let createdDate: Int?
    let roles: Dictionary<String, String>
    let completed: Bool
}
