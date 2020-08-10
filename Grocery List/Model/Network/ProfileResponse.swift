//
//  ProfileResponse.swift
//  Grocery List
//
//  Created by Joe Benton on 09/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct ProfileResponse: Codable {
    let id: String
    let name: String
    let location: String
    let pictureUrl: String
    
    init(documentId: String, documentData: Dictionary<String, Any>) {
        self.id = documentId
        self.name = documentData["name"] as? String ?? ""
        self.location = documentData["location"] as? String ?? ""
        self.pictureUrl = documentData["pictureUrl"] as? String ?? ""
    }
}
