//
//  Scheduler 2.swift
//  HourlyChime
//
//  Created by Artem Peshkov on 01/04/2026.
//


import Foundation

final class Scheduler {
    
    static let maxNotifications = 64
    
    static func generateDates(config: ChimeConfig) -> [Date] {
        
        let calendar = Calendar.current
        let now = Date()
        
        var result: [Date] = []
        var dayOffset = 0
        
        while result.count < maxNotifications {
            
            for hour in config.startHour...config.endHour {
                
                var comp = calendar.dateComponents([.year, .month, .day], from: now)
                comp.day! += dayOffset
                comp.hour = hour
                comp.minute = config.minute
                
                guard let date = calendar.date(from: comp) else { continue }
                
                let weekday = calendar.component(.weekday, from: date) - 1
                
                if !config.days.contains(weekday) { continue }
                if date <= now { continue }
                
                result.append(date)
                
                if result.count >= maxNotifications { break }
            }
            
            dayOffset += 1
            if dayOffset > 30 { break } // safety
        }
        
        return result
    }
}