//
//  AppDelegate+Injection.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        registerAuthServices()
        registerAppleSignInServices()
        registerFacebookSignInServices()
        registerListsServices()
        registerReviewPromptServices()
        registerStorageServices()
        registerNotificationServices()
        registerDynamicLinksServices()
        registerFileServices()
    }
}
