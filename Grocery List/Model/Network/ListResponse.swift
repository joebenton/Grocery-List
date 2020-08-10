//
//  ListResponse.swift
//  Grocery List
//
//  Created by Joe Benton on 26/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct ListResponse: Codable {
    let id: String
    let name: String
    let notes: String
    let vip: Bool
    let dueDate: Int?
    let roles: Dictionary<String, String>
    let completed: Bool
    let itemsCount: Int
    let invitesCount: Int
    
    init(documentId: String, documentData: Dictionary<String, Any>) {
        self.id = documentId
        
        self.name = documentData["name"] as? String ?? ""
        
        self.notes = documentData["notes"] as? String ?? ""
                
        self.vip = documentData["vip"] as? Bool ?? false
        
        self.dueDate = documentData["dueDate"] as? Int
                
        self.roles = documentData["roles"] as? Dictionary<String,String> ?? [:]
        
        self.completed = documentData["completed"] as? Bool ?? false
        
        self.itemsCount = documentData["itemsCount"] as? Int ?? 0
        
        self.invitesCount = documentData["invitesCount"] as? Int ?? 0
    }
}
