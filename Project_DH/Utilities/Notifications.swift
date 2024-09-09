//
//  Notifications.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/9/24.
//

import Foundation
import UserNotifications

struct NotificationTool {
    
    /// This function sets up the daily push notifications.
    /// - Parameters: none
    /// - Returns: none
    static func scheduleDailyNotifications() {
        let center = UNUserNotificationCenter.current()

        // Schedule notification for 8:30 AM
        let morningNotificationContent = UNMutableNotificationContent()
        morningNotificationContent.title = "Good Morning from CalBite!"
        morningNotificationContent.body = "Are you ready to start a wonderful day? Don't forget to get breakfast!"
        morningNotificationContent.sound = UNNotificationSound.default

        var morningDateComponents = DateComponents()
        morningDateComponents.hour = 8
        morningDateComponents.minute = 30

        let morningTrigger = UNCalendarNotificationTrigger(dateMatching: morningDateComponents, repeats: true)
        let morningRequest = UNNotificationRequest(identifier: "morningNotification", content: morningNotificationContent, trigger: morningTrigger)
        center.add(morningRequest)

        // Schedule notification for 3:00 PM
        let afternoonNotificationContent = UNMutableNotificationContent()
        afternoonNotificationContent.title = "Take a break!"
        afternoonNotificationContent.body = "Time to have a short break from what you are doing, get a cup of tea or coffee."
        afternoonNotificationContent.sound = UNNotificationSound.default

        var afternoonDateComponents = DateComponents()
        afternoonDateComponents.hour = 15
        afternoonDateComponents.minute = 0

        let afternoonTrigger = UNCalendarNotificationTrigger(dateMatching: afternoonDateComponents, repeats: true)
        let afternoonRequest = UNNotificationRequest(identifier: "afternoonNotification", content: afternoonNotificationContent, trigger: afternoonTrigger)
        center.add(afternoonRequest)

        print("Notifications scheduled for 8:30 AM and 3:00 PM.")
    }
    
    
    /// This function sets up the push notifications to track for user's target completion.
    /// - Parameters: none
    /// - Returns: none
    static func scheduleAchievementNotification(for user: User) {
        guard let achievementDate = user.achievementDate else {
            print("No achievement date found for the user.")
            return
        }

        let center = UNUserNotificationCenter.current()
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Congratulations, you made it!"
        notificationContent.body = "You should meet your target by today. You can setup a new target or stay as you like!"
        notificationContent.sound = UNNotificationSound.default

        // Create a date matching trigger for the achievement date
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: achievementDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "achievementNotification", content: notificationContent, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for achievement date: \(achievementDate)")
            }
        }
    }
    
}
