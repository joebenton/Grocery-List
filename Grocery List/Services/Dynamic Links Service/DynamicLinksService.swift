//
//  DynamicLinksService.swift.swift
//  Grocery List
//
//  Created by Joe Benton on 17/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Firebase

class DynamicLinksService {
    func generateListInviteLink(listUid: String, inviteUid: String, completion: @escaping (Result<URL, DisplayableError>) -> Void) {
        let link = URL(string: "http://www.grocerylist.com/listInvite?listUid=\(listUid)&inviteUid=\(inviteUid)")!
        let domain = "https://grocerylist.page.link"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: domain)
        
        let iosParameters = DynamicLinkIOSParameters(bundleID: "com.joebenton.GroceryList")
        iosParameters.appStoreID = ""
        linkBuilder?.iOSParameters = iosParameters
        
        let otherPlatformParameters = DynamicLinkOtherPlatformParameters()
        otherPlatformParameters.fallbackUrl = URL(string: "http://www.grocerylist.com")
        linkBuilder?.otherPlatformParameters = otherPlatformParameters
        
        let normalUrl = linkBuilder?.url ?? link
        
        linkBuilder?.shorten(completion: { (shortenedUrl, warnings, error) in
            if let error = error {
                completion(.failure(DisplayableError(message: error.localizedDescription)))
                return
            }
            let url = shortenedUrl ?? normalUrl
            print(url)
            completion(.success(url))
        })
    }
}
