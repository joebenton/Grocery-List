//
//  AppDelegate.swift
//  Grocery List
//
//  Created by Joe Benton on 18/06/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import Resolver
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!
    
    @Injected private var notificationService: NotificationService
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        styleApp()

        configureFirebase()
        
        setupLocalNotifications()
        
        //Configure Facebook Sign-in
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
           
        //Setup App Coordinator
        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = AppCoordinator(window: window!)
        appCoordinator.start()
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        notificationService.dismissDeliveredNotifications()
    }

}

extension AppDelegate {
    fileprivate func styleApp() {
        UINavigationBar.appearance().barTintColor = UIColor(named: "zenWhite")
        UINavigationBar.appearance().tintColor = UIColor(named: "zenBlue")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "zenBlack")!]
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "zenBlack")!,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ]
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    func configureFirebase() {
        FirebaseApp.configure()
    }
    
    fileprivate func setupLocalNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (status, error) in
            if let error = error {
                print(error)
            }
        }
        
        Messaging.messaging().delegate = self
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        appCoordinator.updateFirebaseRegistrationTokenToUser(token: fcmToken)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //List Reminder Local Notification
        let listPrefix = "listReminder_"
        if response.notification.request.content.categoryIdentifier.contains(listPrefix) {
            let categoryId = response.notification.request.content.categoryIdentifier
            if let listIdRange = categoryId.range(of: listPrefix) {
                let id = response.notification.request.identifier
                let title = response.notification.request.content.title
                let body = response.notification.request.content.body
                let listId = String(categoryId[listIdRange.upperBound...])
                let timestamp = Int(response.notification.date.timeIntervalSince1970)
                let openedListReminder = ListReminderOpened(id: id, title: title, body: body, listUid: listId, timestamp: timestamp)
                appCoordinator?.listReminderPushToList(openedListReminder: openedListReminder)
            }
        }
        
        //Activity Push Notification
        let userInfo = response.notification.request.content.userInfo
        if let listUid = userInfo["listUid"] as? String, let notificationUid = userInfo["notificationUid"] as? String {
            appCoordinator?.notificationReceivedPushToList(listId: listUid, notificationUid: notificationUid)
        }
        
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            if let link = dynamicLink.url {
                handleDynamicLink(link: link)
                return true
            }
        }
        
        //Opened url for Facebook Sign-in
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return true
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            guard let link = dynamiclink?.url else { return }
            self.handleDynamicLink(link: link)
        }
        return handled
    }
    
    fileprivate func handleDynamicLink(link: URL) {
        if let urlComponents = URLComponents(url: link, resolvingAgainstBaseURL: false) {
            let path = urlComponents.path
            switch path {
            case "/listInvite":
                if let queryItems = urlComponents.queryItems {
                    let listUid = queryItems.first { (queryItem) -> Bool in
                        return queryItem.name == "listUid"
                    }?.value
                    
                    let inviteUid = queryItems.first { (queryItem) -> Bool in
                        return queryItem.name == "inviteUid"
                    }?.value
                    
                    if let listUid = listUid, let inviteUid = inviteUid {
                        let incomingShareInvite = IncomingShareInvite(listUid: listUid, inviteUid: inviteUid)
                        appCoordinator.openedListInviteLink(incomingShareInvite: incomingShareInvite)
                    }
                }
            case "/__/auth/action":
                if let queryItems = urlComponents.queryItems {
                    let modeValue = queryItems.first { (queryItem) -> Bool in
                        return queryItem.name == "mode"
                    }?.value
                    guard let mode = modeValue else { return }
                    
                    switch mode {
                    case "resetPassword":
                        let oobCodeValue = queryItems.first { (queryItem) -> Bool in
                            return queryItem.name == "oobCode"
                        }?.value
                        guard let oobCode = oobCodeValue else { return }
                        
                        let continueUrlValue = queryItems.first { (queryItem) -> Bool in
                            return queryItem.name == "continueUrl"
                        }?.value
                        guard let continueUrl = continueUrlValue else { return }
                        
                        let continueUrlComponents = URLComponents(url: URL(string: continueUrl)!, resolvingAgainstBaseURL: false)
                        let emailValue = continueUrlComponents?.queryItems?.first { (queryItem) -> Bool in
                            return queryItem.name == "email"
                        }?.value
                        guard let email = emailValue else { return }
                        
                        self.appCoordinator?.deepLinkGotoPasswordReset(oobCode: oobCode, emailReference: email)
                    default: break
                    }
                }
            default: break
            }
        }
    }
}
