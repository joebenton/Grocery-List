//
//  ShareLinkActivityItem.swift
//  Grocery List
//
//  Created by Joe Benton on 29/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import UIKit

class ShareLinkActivityItem: NSObject, UIActivityItemSource {

    let message:String
    let url: URL

    init(message: String, url: URL) {
        self.message = message
        self.url = url

        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return message
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let activityType = activityType else {
            return url
        }
        
        switch activityType {
        case .mail, .message:
            return message
        case .copyToPasteboard:
            return url
        default:
            return url
        }
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Grocery List Invite"
    }
}
