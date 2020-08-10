//
//  NotificationResponse.swift
//  Grocery List
//
//  Created by Joe Benton on 23/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct NotificationResponse: Codable {
    let id: String
    let title: String
    let body: String
    let changeUid: String
    let changeUserUid: String
    let listUid: String
    let timestamp: Int
    let opened: Bool
    
    init(documentId: String, documentData: Dictionary<String, Any>) {
        self.id = documentId
        
        self.title = documentData["title"] as? String ?? ""
                
        self.body = documentData["body"] as? String ?? ""
        
        self.changeUid = documentData["changeUid"] as? String ?? ""
        
        self.changeUserUid = documentData["changeUserUid"] as? String ?? ""
        
        self.listUid = documentData["listUid"] as? String ?? ""
        
        self.timestamp = documentData["timestamp"] as? Int ?? 0
        
        self.opened = documentData["opened"] as? Bool ?? false
    }
}
