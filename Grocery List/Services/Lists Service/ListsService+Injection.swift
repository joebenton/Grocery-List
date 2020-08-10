//
//  ListsService+Injection.swift
//  Grocery List
//
//  Created by Joe Benton on 25/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

extension Resolver {
    public static func registerListsServices() {
        register { ListsService() }.scope(application)
    }
}
