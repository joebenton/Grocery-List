//
//  ReviewPromptService.swift
//  Grocery List
//
//  Created by Joe Benton on 09/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import StoreKit

class ReviewPromptService {

    func increaseEventCount() {
        var count = UserDefaults.standard.integer(forKey: Config.userDefaultKeys.reviewEventCount)
        count += 1
        UserDefaults.standard.set(count, forKey: Config.userDefaultKeys.reviewEventCount)
    }

    func showReviewPromptIfNeeded() {
        // Get the current bundle version for the app
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary") }

        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: Config.userDefaultKeys.reviewAppVersion)

        // Has the process been completed several times and the user has not already been prompted for this version?
        let count = UserDefaults.standard.integer(forKey: Config.userDefaultKeys.reviewEventCount)
        let eventCountTrigger = 2
        if count >= eventCountTrigger && currentVersion != lastVersionPromptedForReview {
            let twoSecondsFromNow = DispatchTime.now() + 2.0
            DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(currentVersion, forKey: Config.userDefaultKeys.reviewAppVersion)
            }
        }
    }
}
