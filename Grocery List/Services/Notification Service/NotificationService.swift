//
//  NotificationService.swift
//  Grocery List
//
//  Created by Joe Benton on 16/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation
import UserNotifications
import Resolver

class NotificationService: NSObject {
    let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()

    private lazy var dateComponents: (_ date: Date) -> DateComponents = { date in
        Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    }

    func dismissDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func dismissPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func removeAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
    }

    func askForPermissions(completionHandler: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if error != nil {
                print("there was an \(error.debugDescription) when registering notifications, it was granted:\(granted)")
                completionHandler(false)
            } else {
                completionHandler(granted)
            }
        }
    }
    
    func scheduleListReminderNotifcation(listId: String, listTitle: String, reminderDate: Date) {
        let notificationId = "\(listId)"
        let notificationTitle = "\(listTitle)"
        
        let notificationBody = "\(listTitle) is due today."
        
        let notificationCategoryId = "listReminder_\(listId)"
        
        if reminderDate > Date() {
            scheduleNotification(identifier: notificationId, title: notificationTitle, body: notificationBody, categoryId: notificationCategoryId, at: reminderDate)
        } else {
            print("not scheduling notification as \(reminderDate) is in past ")
        }
    }
    
    func removeNotificationsForList(listId: String, completionHandler: @escaping () -> Void) {
        let categoryId = "listReminder_\(listId)"
        notificationCenter.getPendingNotificationRequests { [weak self] (notificationRequests) in
            let listReminderNotifications = notificationRequests.filter { (notificationRequest) -> Bool in
                return notificationRequest.content.categoryIdentifier == categoryId
            }
            
            let listReminderNotificationsIds = listReminderNotifications.compactMap { (notificationRequest) -> String? in
                return notificationRequest.identifier
            }
            
            self?.notificationCenter.removePendingNotificationRequests(withIdentifiers: listReminderNotificationsIds)
            
            print("Removed notifications: \(listReminderNotificationsIds)")
            completionHandler()
        }
    }

    fileprivate func scheduleNotification(identifier: String = UUID().uuidString, title: String, body: String, categoryId: String, at date: Date) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.categoryIdentifier = categoryId
        content.sound = UNNotificationSound.default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents(date), repeats: false)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        notificationCenter.add(request)
        
        print("Scheduled notification: \(date)")
    }
}
