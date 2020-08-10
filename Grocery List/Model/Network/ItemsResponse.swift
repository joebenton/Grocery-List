//
//  ItemsResponse.swift
//  Grocery List
//
//  Created by Joe Benton on 26/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct ItemsResponse: Codable {
    let id: String
    let name: String
    let unitType: Int
    let quantity: Int
    let checked: Bool
    
    init(documentId: String, documentData: Dictionary<String, Any>) {
        self.id = documentId
        
        self.name = documentData["name"] as? String ?? ""
        
        self.unitType = documentData["unitType"] as? Int ?? 0
        
        self.quantity = documentData["quantity"] as? Int ?? 0
                    
        self.checked = documentData["checked"] as? Bool ?? false
    }
}
