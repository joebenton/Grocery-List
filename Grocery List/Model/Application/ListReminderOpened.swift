//
//  ListReminderOpened.swift
//  Grocery List
//
//  Created by Joe Benton on 24/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

class ListReminderOpened: NSObject, NSCoding {
    let id: String
    let title: String
    let body: String
    let listUid: String
    let timestamp: Int
    
    init(id: String, title: String, body: String, listUid: String, timestamp: Int) {
        self.id = id
        self.title = title
        self.body = body
        self.listUid = listUid
        self.timestamp = timestamp
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
        let title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        let body = aDecoder.decodeObject(forKey: "body") as? String ?? ""
        let listUid = aDecoder.decodeObject(forKey: "listUid") as? String ?? ""
        let timestamp = aDecoder.decodeInteger(forKey: "timestamp") 
        
        self.init(id: id, title: title, body: body, listUid: listUid, timestamp: timestamp)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(body, forKey: "body")
        aCoder.encode(listUid, forKey: "listUid")
        aCoder.encode(timestamp, forKey: "timestamp")
    }
}
