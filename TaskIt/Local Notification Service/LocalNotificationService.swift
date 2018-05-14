

import UserNotifications

class LocalNotifications {
        
    func addLocalNotification(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        
        let currentate = Date()
        let elapsedTime = date.timeIntervalSince(currentate)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: elapsedTime, repeats: false)
        
        let request = UNNotificationRequest(identifier: "sprint ended", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
