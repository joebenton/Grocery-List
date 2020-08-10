//
//  EditListRequest.swift
//  Grocery List
//
//  Created by Joe Benton on 29/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct EditListRequest: Codable {
    let name: String
    let notes: String
    let vip: Bool
    let dueDate: Int?
    let updatedDate: Int
}
