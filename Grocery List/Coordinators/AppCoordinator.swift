//
//  AppCoordinator.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import Resolver
import FirebaseInstanceID

class AppCoordinator: Coordinator {
    let window: UIWindow
    
    @Injected var authService: AuthService
    @Injected private var appleSignInService: AppleSignInService
    @Injected private var fileService: FileService
    
    var splashCoordinator: SplashCoordinator?
    var welcomeCoordinator: WelcomeCoordinator?
    var tabBarCoordinator: MainTabCoordinator?
    
    var receivedNotificationPushToList: String? = nil
    
    init(window: UIWindow) {
        self.window = window
        super.init()
    }

    override func start() {
        showSplash()
        addAuthListener()
        validateAppleSignedInUser()
    }
    
    fileprivate func addAuthListener() {
        authService.addAuthStateChangeListener { [weak self] result in
            self?.closeSplashCoordinator()
            self?.closeCurrentCoordinator()

            switch result {
            case .loggedIn:
                self?.showMainTab()
                self?.getNotificationToken()
            case .loggedOut:
                self?.showWelcome()
            }
        }
    }
    
    fileprivate func showSplash() {
        //Show splash while auth listener loads state
        splashCoordinator = SplashCoordinator(window: window)
        addChildCoordinator(splashCoordinator!)
        splashCoordinator?.start()
    }
    
    fileprivate func showWelcome() {
        welcomeCoordinator = WelcomeCoordinator(window: window)
        addChildCoordinator(welcomeCoordinator!)
        welcomeCoordinator?.start()
    }
    
    fileprivate func showMainTab() {
        tabBarCoordinator = MainTabCoordinator(window: window)
        addChildCoordinator(tabBarCoordinator!)
        tabBarCoordinator?.start()
        
        if let receivedNotificationPushToList = receivedNotificationPushToList {
            tabBarCoordinator?.notificationReceivedPushToList(listId: receivedNotificationPushToList)
            self.receivedNotificationPushToList = nil
        }
    }
    
    fileprivate func closeSplashCoordinator() {
        if let splashCoordinator = splashCoordinator {
            splashCoordinator.finish()
            self.splashCoordinator = nil
        }
    }
    
    fileprivate func closeCurrentCoordinator() {
        if let welcomeCoordinator = self.welcomeCoordinator {
            welcomeCoordinator.finish()
            self.welcomeCoordinator = nil
        }

        if let tabBarCoordinator = self.tabBarCoordinator {
            tabBarCoordinator.finish()
            self.tabBarCoordinator = nil
        }
    }
    
    func validateAppleSignedInUser() {
        guard let appleSignedInUserId = UserDefaults.standard.value(forKey: Config.userDefaultKeys.appleSignInUserId) as? String else { return }
        appleSignInService.validateSignedInWithApple(userID: appleSignedInUserId) { (result) in
            if case .failure = result {
                self.authService.logoutUser { (logoutResult) in
                    UserDefaults.standard.removeObject(forKey: Config.userDefaultKeys.appleSignInUserId)
                }
            }
        }
    }
    
    func notificationReceivedPushToList(listId: String, notificationUid: String) {
        if let userUid = authService.getUserUid() {
            authService.markNotificationOpened(userUid: userUid, notificationUid: notificationUid) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        print(error.message)
                    }
                }
            }
        }
        
        if listId.count > 0 {
            if let tabBarCoordinator = tabBarCoordinator {
                tabBarCoordinator.notificationReceivedPushToList(listId: listId)
            } else {
                receivedNotificationPushToList = listId
            }
        }
    }
    
    func listReminderPushToList(openedListReminder: ListReminderOpened) {
        fileService.saveOpenedLocalNotification(openedListReminder: openedListReminder)
        
        if let tabBarCoordinator = tabBarCoordinator {
            tabBarCoordinator.notificationReceivedPushToList(listId: openedListReminder.listUid)
        } else {
            receivedNotificationPushToList = openedListReminder.listUid
        }
    }
    
    func openedListInviteLink(incomingShareInvite: IncomingShareInvite) {
        if let tabBarCoordinator = tabBarCoordinator {
            tabBarCoordinator.showListInvitePopup(incomingShareInvite: incomingShareInvite)
        } else {
            UserDefaults.standard.set(incomingShareInvite.listUid, forKey: Config.userDefaultKeys.incomingListInviteListUid)
            UserDefaults.standard.set(incomingShareInvite.inviteUid, forKey: Config.userDefaultKeys.incomingListInviteInviteUid)
            welcomeCoordinator?.showInviteBanner()
        }
    }
    
    fileprivate func getNotificationToken() {
        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            self.updateFirebaseRegistrationTokenToUser(token: result.token)
          }
        }
    }
    
    func updateFirebaseRegistrationTokenToUser(token: String) {
        print("Saving Token: \(token)")
        if let _ = authService.getUserUid() {
            authService.saveFirebaseToken(token: token) { (result) in
                switch result {
                case .success: break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func deepLinkGotoPasswordReset(oobCode: String, emailReference: String) {
        welcomeCoordinator?.deepLinkGotoPasswordReset(oobCode: oobCode, emailReference: emailReference)
    }
}
