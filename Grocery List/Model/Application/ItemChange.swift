//
//  ItemChange.swift
//  Grocery List
//
//  Created by Joe Benton on 22/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

enum ItemChangeType: Int {
    case added = 0
    case removed = 1
    case checked = 2
    case unchecked = 3
    case edited = 4
}

struct ItemChange {
    let itemUids: Array<String>
    let type: ItemChangeType
    let changeDescription: String?
}
