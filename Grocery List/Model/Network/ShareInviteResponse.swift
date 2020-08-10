//
//  ShareInviteResponse.swift
//  Grocery List
//
//  Created by Joe Benton on 17/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct ShareInviteResponse: Codable {
    let id: String
    let name: String
    let link: String
    let status: String
    let listName: String
    let acceptedBy: String?
    
    init(documentId: String, documentData: Dictionary<String, Any>) {
        self.id = documentId
        
        self.name = documentData["name"] as? String ?? ""
                
        self.link = documentData["link"] as? String ?? ""
        
        self.status = documentData["status"] as? String ?? ""
        
        self.listName = documentData["listName"] as? String ?? ""
        
        self.acceptedBy = documentData["acceptedBy"] as? String
    }
}
