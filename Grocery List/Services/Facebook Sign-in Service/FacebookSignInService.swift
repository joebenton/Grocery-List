//
//  FacebookSignInService.swift
//  Grocery List
//
//  Created by Joe Benton on 23/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FacebookSignInService {
    
    var fbLoginManager = LoginManager()
    
    func signInWithFacebook(showFrom: UIViewController, completion: @escaping ((Result<(String), DisplayableError>) -> Void)) {
        fbLoginManager.logIn(permissions: ["email", "public_profile"], viewController: showFrom) { (result) in
            switch result {
            case .cancelled:
                return
            case .failed(let error):
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            case .success(_, _, let accessToken):
                let accessTokenString = accessToken.tokenString
                completion(.success(accessTokenString))
            }
        }
    }
}
