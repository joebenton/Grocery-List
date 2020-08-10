//
//  StoryboardBased.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

protocol StoryboardBased: class {
}

extension StoryboardBased where Self: UIViewController {
    
    static func instantiate() -> Self {
        let sceneStoryboard = UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
        let viewController = sceneStoryboard.instantiateInitialViewController()
        guard let typedViewController = viewController as? Self else {
          fatalError("The initialViewController of '\(sceneStoryboard)' is not of class '\(self)'")
        }
        return typedViewController
    }
    
}
