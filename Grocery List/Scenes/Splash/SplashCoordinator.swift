//
//  SplashCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

class SplashCoordinator: Coordinator {
    var window: UIWindow

    lazy var rootViewController: SplashViewController = {
        SplashViewController.instantiate()
    }()

    init(window: UIWindow) {
        self.window = window
    }

    override func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }
}
