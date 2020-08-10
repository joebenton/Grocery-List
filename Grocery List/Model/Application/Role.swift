//
//  Role.swift
//  Grocery List
//
//  Created by Joe Benton on 25/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

enum Role: String {
    case owner = "owner"
    case collaborator = "collaborator"
    
    var sortOrder: Int {
        switch self {
        case .owner:
            return 0
        case .collaborator:
            return 1
        }
    }
}

extension Role: CustomStringConvertible {
    var description: String {
        switch self {
        case .collaborator: return "Collaborator"
        case .owner: return "Owner"
        }
    }
}
