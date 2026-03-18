//
//  ContentView.swift
//  HourlyChime
//
//  Created by Artem Peshkov on 17/03/2026.
//

import SwiftUI
import UserNotifications

// MARK: - Sound Model

enum ChimeSound: String, CaseIterable {
    case defaultSound = "Default"
    case casioDouble = "Casio Double Beep"
}

// MARK: - Notification Manager

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            print("Permission:", granted)
        }
    }
    
    func clearAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func scheduleChimes(
        days: Set<Int>,
        startHour: Int,
        endHour: Int,
        chimeMinute: Int,
        sound: ChimeSound
    ) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let calendar = Calendar.current
        let now = Date()
        
        // Schedule next 2 days (safe vs iOS limit)
        for dayOffset in 0..<2 {
            for hour in startHour...endHour {
                
                var components = calendar.dateComponents([.year, .month, .day], from: now)
                components.day! += dayOffset
                components.hour = hour
                components.minute = chimeMinute
                
                guard let date = calendar.date(from: components) else { continue }
                
                let weekday = calendar.component(.weekday, from: date) - 1
                
                if !days.contains(weekday) { continue }
                if date < now { continue }
                
                let content = UNMutableNotificationContent()
                content.title = "⏰ Hourly Chime"
                content.body = String(format: "It's %02d:%02d", hour, chimeMinute)
                
                // Sound selection
                switch sound {
                    
                case .defaultSound:
                    content.sound = .default
                    
                case .casioDouble:
                    content.sound = UNNotificationSound(named: UNNotificationSoundName("casio_double_beep.caf"))
                }
                
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: components,
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: trigger
                )
                
                center.add(request)
            }
        }
    }
}

// MARK: - UI

struct ContentView: View {
    
    // MARK: - States
    @State private var isEnabled = false
    @State private var chimeTime = Date()
    @State private var startTime = Calendar.current.date(from: DateComponents(hour: 9)) ?? Date()
    @State private var endTime = Calendar.current.date(from: DateComponents(hour: 18)) ?? Date()
    @State private var selectedSound: ChimeSound = .defaultSound
    
    let days = ["S","M","T","W","T","F","S"]
    @State private var selectedDays: Set<Int> = [1,2,3,4,5]
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                
                // Days
                Section(header: Text("Days")) {
                    HStack(spacing: 10) {
                        ForEach(0..<7) { i in
                            let isSelected = selectedDays.contains(i)
                            Text(days[i])
                                .frame(width: 36, height: 36)
                                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .onTapGesture {
                                    toggleDay(i)
                                    saveState()
                                    reschedule()
                                }
                        }
                    }
                }
                
                // Active hours
                Section(header: Text("Active Hours")) {
                    DatePicker("From", selection: $startTime, displayedComponents: .hourAndMinute)
                        .onChange(of: startTime) { _, _ in
                            clampChimeTime()
                            saveState()
                            reschedule()
                        }
                    
                    DatePicker("To", selection: $endTime, displayedComponents: .hourAndMinute)
                        .onChange(of: endTime) { _, _ in
                            clampChimeTime()
                            saveState()
                            reschedule()
                        }
                }
                
                // Chime start time
                Section(header: Text("Chime Start Time")) {
                    DatePicker("Start At", selection: $chimeTime, displayedComponents: .hourAndMinute)
                        .onChange(of: chimeTime) { _, _ in
                            clampChimeTime()
                            saveState()
                            reschedule()
                        }
                }
                
                // Sound picker
                Section(header: Text("Sound")) {
                    Picker("Chime Sound", selection: $selectedSound) {
                        ForEach(ChimeSound.allCases, id: \.self) { sound in
                            Text(sound.rawValue)
                        }
                    }
                    .onChange(of: selectedSound) { _, _ in
                        saveState()
                        reschedule()
                    }
                }
                
                // Enable toggle
                Section {
                    Toggle("Enable Chime", isOn: $isEnabled)
                        .onChange(of: isEnabled) { _, newValue in
                            saveState()
                            if newValue {
                                reschedule()
                            } else {
                                NotificationManager.shared.clearAll()
                            }
                        }
                }
                
            }
            .navigationTitle("Hourly Chime")
            .onAppear { loadState() }
        }
    }
    
    // MARK: - Logic
    
    func toggleDay(_ index: Int) {
        if selectedDays.contains(index) {
            selectedDays.remove(index)
        } else {
            selectedDays.insert(index)
        }
    }
    
    // Clamp chime time to active hours
    func clampChimeTime() {
        let calendar = Calendar.current
        
        let startHour = calendar.component(.hour, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        
        let finalStart = min(startHour, endHour)
        let finalEnd = max(startHour, endHour)
        
        var components = calendar.dateComponents([.hour, .minute], from: chimeTime)
        guard let hour = components.hour else { return }
        
        if hour < finalStart {
            components.hour = finalStart
        } else if hour > finalEnd {
            components.hour = finalEnd
        }
        
        if let newDate = calendar.date(from: components) {
            chimeTime = newDate
        }
    }
    
    func reschedule() {
        guard isEnabled else { return }
        
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: startTime)
        let endHour = calendar.component(.hour, from: endTime)
        let chimeMinute = calendar.component(.minute, from: chimeTime)
        
        NotificationManager.shared.scheduleChimes(
            days: selectedDays,
            startHour: min(startHour, endHour),
            endHour: max(startHour, endHour),
            chimeMinute: chimeMinute,
            sound: selectedSound
        )
    }
    
    // MARK: - Persistence
    
    func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(Array(selectedDays), forKey: "selectedDays")
        defaults.set(startTime, forKey: "startTime")
        defaults.set(endTime, forKey: "endTime")
        defaults.set(chimeTime, forKey: "chimeTime")
        defaults.set(selectedSound.rawValue, forKey: "selectedSound")
        defaults.set(isEnabled, forKey: "isEnabled")
    }
    
    func loadState() {
        let defaults = UserDefaults.standard
        
        if let daysArray = defaults.array(forKey: "selectedDays") as? [Int] {
            selectedDays = Set(daysArray)
        }
        if let start = defaults.object(forKey: "startTime") as? Date {
            startTime = start
        }
        if let end = defaults.object(forKey: "endTime") as? Date {
            endTime = end
        }
        if let chime = defaults.object(forKey: "chimeTime") as? Date {
            chimeTime = chime
        }
        if let soundRaw = defaults.string(forKey: "selectedSound"),
           let sound = ChimeSound(rawValue: soundRaw) {
            selectedSound = sound
        }
        isEnabled = defaults.bool(forKey: "isEnabled")
        
        // Reschedule notifications on load
        if isEnabled { reschedule() }
    }
}
