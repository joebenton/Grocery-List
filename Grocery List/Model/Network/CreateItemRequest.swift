//
//  CreateItemRequest.swift
//  Grocery List
//
//  Created by Joe Benton on 26/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct CreateItemRequest: Codable {
    let userUid: String
    let name: String
    let unitType: Int
    let quantity: Int
    let checked: Bool
    let createdDate: Int
    
}
