//
//  AppleSignInService+Injection.swift
//  Grocery List
//
//  Created by Joe Benton on 19/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

extension Resolver {
    public static func registerAppleSignInServices() {
        register { AppleSignInService() }.scope(application)
    }
}
