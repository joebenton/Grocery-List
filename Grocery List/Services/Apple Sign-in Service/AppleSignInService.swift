//
//  AppleSignInService.swift
//  Grocery List
//
//  Created by Joe Benton on 19/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import CryptoKit
import AuthenticationServices

class AppleSignInService: NSObject {

    fileprivate var currentNonce: String?
    
    var showFrom: ASAuthorizationControllerPresentationContextProviding?
    var completionHandler: ((Result<(String, String), DisplayableError>) -> Void)?
    
    func signInWithApple(showFrom: ASAuthorizationControllerPresentationContextProviding, completion: @escaping ((Result<(String, String), DisplayableError>) -> Void)) {
        self.completionHandler = completion
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = showFrom
        authorizationController.performRequests()
    }
    
    func validateSignedInWithApple(userID: String, completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { (state, error) in
            switch state {
            case .authorized:
                completion(.success(true))
            default:
                completion(.failure(DisplayableError(message: "Not logged in via Apple Sign-in")))
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    print("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

extension AppleSignInService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
              print("Invalid state: A login callback was received, but no login request was sent.")
                completionHandler?(.failure(DisplayableError.unknownError()))
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
              print("Unable to fetch identity token")
                completionHandler?(.failure(DisplayableError.unknownError()))
              return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                  print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                completionHandler?(.failure(DisplayableError.unknownError()))
              return
            }

            UserDefaults.standard.setValue(appleIDCredential.user, forKey: Config.userDefaultKeys.appleSignInUserId)
            
            completionHandler?(.success((nonce, idTokenString)))
            completionHandler = nil
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let errorCode = (error as NSError).code
        if errorCode != 1000 && errorCode != 1001 {
            print("Sign in with Apple errored: \(error)")
            completionHandler?(.failure(DisplayableError(message: error.localizedDescription)))
        }
    }
}
