//
//  DisplayableError.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct DisplayableError: Error {
    let message: String
}

extension DisplayableError {
    static func unknownError() -> Self {
        return DisplayableError(message: "Unknown error")
    }
}
