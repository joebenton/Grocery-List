//
//  Codable+Dictionary.swift
//  Grocery List
//
//  Created by Joe Benton on 25/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

struct JSON {
    static let encoder = JSONEncoder()
}
extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSON.encoder.encode(self))) as? [String: Any] ?? [:]
    }
}
