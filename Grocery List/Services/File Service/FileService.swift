//
//  FileService.swift
//  Grocery List
//
//  Created by Joe Benton on 24/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import Foundation

class FileService {
    
    func saveOpenedLocalNotification(openedListReminder: ListReminderOpened) {
        var updatedOpenedListReminders = getOpenedLocalNotifications()
        updatedOpenedListReminders.append(openedListReminder)
        
        let fullPath = getDocumentsDirectory().appendingPathComponent("openedListReminders.groceryList")

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: updatedOpenedListReminders, requiringSecureCoding: false)
            try data.write(to: fullPath)
        } catch {
            print("Couldn't write file")
        }
    }
    
    func getOpenedLocalNotifications() -> Array<ListReminderOpened> {
        let fullPath = getDocumentsDirectory().appendingPathComponent("openedListReminders.groceryList")
        guard FileManager.default.fileExists(atPath: fullPath.path) else { return [] }
        
        if let data = FileManager.default.contents(atPath: fullPath.path) {
            do {
                if let openedListReminders = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [ListReminderOpened] {
                    return openedListReminders
                }
            } catch {
                print("Couldn't read file.")
            }
        }
        return []
    }
    
    func deleteOpenedLocalNotification(notificationId: String) {
        var updatedOpenedListReminders = getOpenedLocalNotifications()
        
        updatedOpenedListReminders = updatedOpenedListReminders.filter { (existingNotification) -> Bool in
            return existingNotification.id != notificationId
        }
        
        let fullPath = getDocumentsDirectory().appendingPathComponent("openedListReminders.groceryList")

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: updatedOpenedListReminders, requiringSecureCoding: false)
            try data.write(to: fullPath)
        } catch {
            print("Couldn't write file")
        }
    }
    
    fileprivate func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
