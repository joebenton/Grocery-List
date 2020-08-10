//
//  UpdateProfileRequest.swift
//  Grocery List
//
//  Created by Joe Benton on 09/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct UpdateProfileRequest: Codable {
    let name: String
    let location: String
    let pictureUrl: String
}
