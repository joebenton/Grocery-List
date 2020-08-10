//
//  DynamicLinksService+Injection.swift
//  Grocery List
//
//  Created by Joe Benton on 17/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

extension Resolver {
    public static func registerDynamicLinksServices() {
        register { DynamicLinksService() }.scope(application)
    }
}
