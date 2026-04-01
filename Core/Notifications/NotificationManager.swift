import Foundation
import UserNotifications

final class NotificationManager {
    
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, _ in
                print("Permission:", granted)
            }
    }
    
    func clear() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }
    
    func schedule(config: ChimeConfig, sound: ChimeSound) {
        
        clear()
        
        let dates = Scheduler.generateDates(config: config)
        
        for date in dates {
            
            let content = UNMutableNotificationContent()
            content.title = "⏰ Hourly Chime"
            
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            
            content.body = String(format: "It's %02d:%02d", hour, minute)
            
            switch sound {
            case .defaultSound:
                content.sound = .default
            case .casioDouble:
                content.sound = UNNotificationSound(
                    named: UNNotificationSoundName("casio_double_beep.caf")
                )
            }
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: date
                ),
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
        
        print("Scheduled:", dates.count)
    }
}