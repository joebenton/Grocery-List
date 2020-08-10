//
//  List.swift
//  Grocery List
//
//  Created by Joe Benton on 26/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct List {
    let id: String
    var name: String
    var notes: String
    var vip: Bool
    var dueDate: Date?
    let roles: Dictionary<String,String>
    var completed: Bool
    let itemsCount: Int
    let invitesCount: Int
    let viewAs: Role
}
