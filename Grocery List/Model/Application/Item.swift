//
//  Item.swift
//  Grocery List
//
//  Created by Joe Benton on 26/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct Item {
    let id: String
    var name: String
    var unitType: UnitType
    var quantity: Int
    var checked: Bool
}
