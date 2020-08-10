//
//  EditItemRequest.swift
//  Grocery List
//
//  Created by Joe Benton on 30/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct EditItemRequest: Codable {
    let name: String
    let unitType: Int
    let quantity: Int
    let checked: Bool
    let updatedDate: Int
}
