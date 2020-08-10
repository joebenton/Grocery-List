//
//  UIViewController+Alert.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, onWindow: Bool = false) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertVC.addAction(okayAction)
        
        var vcToPresentAlert = self
        
        if onWindow {
            vcToPresentAlert = self.view.window?.rootViewController ?? self
        }
        
        alertVC.view.tintColor = UIColor(named: "zenBlack")
        
        vcToPresentAlert.present(alertVC, animated: true, completion: nil)
    }
}
