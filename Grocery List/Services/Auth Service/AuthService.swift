//
//  AuthService.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Firebase

class AuthService {
    
    let db = Firestore.firestore()
    
    init() {
    }

    func registerAccount(email: String, password: String, completion: @escaping (Result<UserRegisterResponse, DisplayableError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let errorMessage = error.localizedDescription
                completion(.failure(DisplayableError(message: errorMessage)))
                return
            }
            if let authResult = authResult {
                let userRegisterResponse = UserRegisterResponse(uid: authResult.user.uid)
                completion(.success(userRegisterResponse))
            } else {
                completion(.failure(DisplayableError.unknownError()))
            }
        }
    }

    func loginAccount(email: String, password: String, completion: @escaping (Result<UserLoginResponse, DisplayableError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let errorMessage = error.localizedDescription
                completion(.failure(DisplayableError(message: errorMessage)))
                return
            }
            if let authResult = authResult {
                let userLoginResponse = UserLoginResponse(uid: authResult.user.uid)
                completion(.success(userLoginResponse))
            } else {
                completion(.failure(DisplayableError.unknownError()))
            }
        }
    }

    func getUserUid() -> String? {
        if let currentUserId = Auth.auth().currentUser?.uid {
            return currentUserId
        } else {
            return nil
        }
    }

    func getUserEmail() -> String? {
        if let email = Auth.auth().currentUser?.email {
            return email
        } else {
            return nil
        }
    }
    
    func loginWithApple(nonce: String, appleToken: String, completion: @escaping (Result<UserLoginResponse, DisplayableError>) -> Void) {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: appleToken, rawNonce: nonce)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                let errorMessage = error.localizedDescription
                completion(.failure(DisplayableError(message: errorMessage)))
                return
            }
            if let authResult = authResult {
                let userLoginResponse = UserLoginResponse(uid: authResult.user.uid)
                completion(.success(userLoginResponse))
            } else {
                completion(.failure(DisplayableError.unknownError()))
            }
        }
    }
    
    func loginWithFacebook(accessToken: String, completion: @escaping (Result<UserLoginResponse, DisplayableError>) -> Void) {
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)

        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                let errorMessage = error.localizedDescription
                completion(.failure(DisplayableError(message: errorMessage)))
                return
            }
            if let authResult = authResult {
                let userLoginResponse = UserLoginResponse(uid: authResult.user.uid)
                completion(.success(userLoginResponse))
            } else {
                completion(.failure(DisplayableError.unknownError()))
            }
        }
    }
    
    func addAuthStateChangeListener(completion: @escaping (AuthStatus) -> Void) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user {
                completion(.loggedIn)
            } else {
                completion(.loggedOut)
            }
        }
    }

    func logoutUser(completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(true))
        } catch (let error) {
            completion(.failure(DisplayableError(message: error.localizedDescription)))
        }
    }

    func sendForgotPasswordEmail(email: String, completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        let actionCodeSettings =  ActionCodeSettings()
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        actionCodeSettings.url = URL(string: String(format: "https://grocerylist.page.link/resetPassword?email=%@", email))
        actionCodeSettings.dynamicLinkDomain = "grocerylist.page.link"

        Auth.auth().sendPasswordReset(withEmail: email, actionCodeSettings: actionCodeSettings) { (error) in
            if let error = error {
                let errorMessage = error.localizedDescription
                completion(.failure(DisplayableError(message: errorMessage)))
                return
            }
            completion(.success(true))
        }
    }

    func verifyChangePasswordResetCode(oobCode: String, completion: @escaping (Result<String, DisplayableError>) -> Void) {
        guard oobCode.count > 0 else {
            completion(.failure(DisplayableError(message: "Verify reset oob code invalid")))
            return
        }

        Auth.auth().verifyPasswordResetCode(oobCode) { (email, error) in
            if let error = error {
                let errorMessage = error.localizedDescription
                completion(.failure(DisplayableError(message: errorMessage)))
                return
            }
            if let email = email {
                completion(.success(email))
            } else {
                completion(.failure(DisplayableError(message: "Could not verify reset code")))
            }
        }
    }

    func changePasswordFromResetEmail(oobCode: String, newPassword: String, completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        guard oobCode.count > 0 else {
            completion(.failure(DisplayableError(message: "Reset password oob code invalid")))
            return
        }

        Auth.auth().confirmPasswordReset(withCode: oobCode, newPassword: newPassword) { (error) in
            if let error = error {
                let errorMessage = error.localizedDescription
                completion(.failure(DisplayableError(message: errorMessage)))
                return
            }
            completion(.success(true))
        }
    }

    func changePassword(oldPassword: String, newPassword: String, completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(DisplayableError(message: "User not logged in")))
            return
        }
        
        
        guard let isUserPasswordType = isUserPasswordType(), isUserPasswordType == true else {
            completion(.failure(DisplayableError(message: "User does not have email/password auth type")))
            return
        }
        
        guard let email = user.email else {
            completion(.failure(DisplayableError(message: "Email not found to reauthenticate")))
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)

        user.reauthenticate(with: credential) { (result, error) in
            if let error = error {
                print(error)
                completion(.failure(DisplayableError(message: "Error verifying existing password")))
            } else {
                Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error) in
                    if let error = error {
                        let errorMessage = error.localizedDescription
                        completion(.failure(DisplayableError(message: errorMessage)))
                        return
                    }
                    completion(.success(true))
                })
            }
        }
    }
    
    func isUserPasswordType() -> Bool? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        let userAuthTypePassword = user.providerData.contains { (userInfo) -> Bool in
            return userInfo.providerID == EmailAuthProviderID
        }
        return userAuthTypePassword
    }
    
    func getProfile(completion: @escaping (Result<Profile, DisplayableError>) -> Void) {
        guard let userUid = Auth.auth().currentUser?.uid else {
            completion(.failure(DisplayableError(message: "User not logged in")))
            return
        }
        
        db.collection("users").document(userUid).getDocument { (snapshot, error) in
            if let error = error {
                print("Error loading profile: \(error.localizedDescription)")
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                guard snapshot?.exists == true else {
                    completion(.success(Profile(userId: "", name: "", location: "", pictureUrl: "")))
                    return
                }
                
                guard let documentId = snapshot?.documentID, let data = snapshot?.data() else {
                    completion(.failure(DisplayableError(message: "Profile data not found")))
                    return
                }
                
                let profileResponse = ProfileResponse(documentId: documentId, documentData: data)
                
                let profile = Profile(userId: profileResponse.id, name: profileResponse.name, location: profileResponse.location, pictureUrl: profileResponse.pictureUrl)
                
                completion(.success(profile))
            }
        }
    }
    
    func updateProfile(profile: Profile, completion: @escaping (Result<UpdateProfileResponse, DisplayableError>) -> Void) {
        guard let userUid = Auth.auth().currentUser?.uid else {
            completion(.failure(DisplayableError(message: "User not logged in")))
            return
        }
        
        let updateProfileRequest = UpdateProfileRequest(name: profile.name, location: profile.location, pictureUrl: profile.pictureUrl)
        
        db.collection("users").document(userUid).setData(updateProfileRequest.dictionary, merge: true) { err in
            if let err = err {
                print("Error updating profile: \(err.localizedDescription) with data: \(updateProfileRequest.dictionary)")
                completion(.failure(DisplayableError(message: err.localizedDescription)))
            } else {
                completion(.success(UpdateProfileResponse()))
            }
        }
    }
    
    func getUsersProfile(userUid: String, completion: @escaping (Result<Profile, DisplayableError>) -> Void) {
        db.collection("users").document(userUid).getDocument { (snapshot, error) in
            if let error = error {
                print("Error loading users profile: \(error.localizedDescription)")
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                guard snapshot?.exists == true else {
                    completion(.success(Profile(userId: "", name: "", location: "", pictureUrl: "")))
                    return
                }
                
                guard let documentId = snapshot?.documentID, let data = snapshot?.data() else {
                    completion(.failure(DisplayableError(message: "Profile data not found")))
                    return
                }
                
                let profileResponse = ProfileResponse(documentId: documentId, documentData: data)
                
                let profile = Profile(userId: profileResponse.id, name: profileResponse.name, location: profileResponse.location, pictureUrl: profileResponse.pictureUrl)
                
                completion(.success(profile))
            }
        }
    }
    
    func saveFirebaseToken(token: String, completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        guard let userUid = Auth.auth().currentUser?.uid else {
            completion(.failure(DisplayableError(message: "User not logged in")))
            return
        }
        
        db.collection("users").document(userUid).setData(["token": token], merge: true) { error in
            if let error = error {
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func getNotifications(completion: @escaping (Result<Array<ActivityNotification>, DisplayableError>) -> Void) {
        guard let userUid = Auth.auth().currentUser?.uid else {
            completion(.failure(DisplayableError(message: "User not logged in")))
            return
        }
        
        db.collection("users").document(userUid).collection("notifications").order(by: "timestamp", descending: true).limit(to: 30).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error loading notifications: \(error.localizedDescription)")
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                var notificationsResponse = Array<NotificationResponse>()
                for document in snapshot!.documents {
                    notificationsResponse.append(NotificationResponse(documentId: document.documentID, documentData: document.data()))
                }
                
                let notifications = notificationsResponse.map { (notificationsResponse) -> ActivityNotification in
                    return ActivityNotification(id: notificationsResponse.id, type: .pushNotification, title: notificationsResponse.title, body: notificationsResponse.body, listUid: notificationsResponse.listUid, timestamp: notificationsResponse.timestamp, changeUid: notificationsResponse.changeUid, changeUserUid: notificationsResponse.changeUserUid, changeUserPicture: nil, opened: notificationsResponse.opened)
                }
                
                completion(.success(notifications))
            }
        }
    }
    
    func markNotificationOpened(userUid: String, notificationUid: String, completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        guard userUid.count > 0 else {
            completion(.failure(DisplayableError(message: "User UID not valid")))
            return
        }
        
        guard notificationUid.count > 0 else {
            completion(.failure(DisplayableError(message: "Notification UID not valid")))
            return
        }
        
        db.collection("users").document(userUid).collection("notifications").document(notificationUid).updateData(["opened": true]) { error in
            if let error = error {
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func deleteNotification(userUid: String, notificationUid: String, completion: @escaping (Result<Bool, DisplayableError>) -> Void) {
        guard userUid.count > 0 else {
            completion(.failure(DisplayableError(message: "User UID not valid")))
            return
        }
        
        guard notificationUid.count > 0 else {
            completion(.failure(DisplayableError(message: "Notification UID not valid")))
            return
        }
        
        db.collection("users").document(userUid).collection("notifications").document(notificationUid).delete() { error in
            if let error = error {
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func getUsersProfiles(userUids: Array<String>, completion: @escaping (Result<Array<Profile>, DisplayableError>) -> Void) {
        let filteredUserUids = userUids.filter { (userUid) -> Bool in
            return userUid.count > 0
        }
        
        guard filteredUserUids.count > 0 else {
            completion(.success([]))
            return
        }
        
        db.collection("users").whereField(FieldPath.documentID(), in: filteredUserUids).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error loading users profiles: \(error.localizedDescription)")
                completion(.failure(DisplayableError(message: error.localizedDescription)))
            } else {
                var profilesResponse = Array<ProfileResponse>()
                for document in snapshot!.documents {
                    profilesResponse.append(ProfileResponse(documentId: document.documentID, documentData: document.data()))
                }
                
                let profiles = profilesResponse.map { (profileResponse) -> Profile in
                    return Profile(userId: profileResponse.id, name: profileResponse.name, location: profileResponse.location, pictureUrl: profileResponse.pictureUrl)
                }
                
                completion(.success(profiles))
            }
        }
    }
}
