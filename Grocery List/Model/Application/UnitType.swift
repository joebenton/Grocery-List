//
//  UnitType.swift
//  Grocery List
//
//  Created by Joe Benton on 26/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

enum UnitType: Int, CaseIterable {
    case pcs = 0
    case kg = 1
    case g = 2
    case ml = 3
}

extension UnitType: CustomStringConvertible {
    var description: String {
        switch self {
        case .pcs: return "pcs"
        case .kg: return "kg"
        case .g: return "g"
        case .ml: return "ml"
        }
    }
    
}
