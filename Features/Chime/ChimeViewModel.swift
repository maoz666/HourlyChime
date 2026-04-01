import Foundation

final class ChimeViewModel: ObservableObject {
    
    @Published var isEnabled = false
    @Published var chimeTime = Date()
    @Published var startTime = Date()
    @Published var endTime = Date()
    @Published var selectedSound: ChimeSound = .defaultSound
    @Published var selectedDays: Set<Int> = []
    
    init() {
        load()
    }
    
    func apply() {
        
        Persistence.shared.save(
            days: selectedDays,
            start: startTime,
            end: endTime,
            chime: chimeTime,
            sound: selectedSound,
            enabled: isEnabled
        )
        
        guard isEnabled else {
            NotificationManager.shared.clear()
            return
        }
        
        let calendar = Calendar.current
        
        let config = ChimeConfig(
            days: selectedDays,
            startHour: min(
                calendar.component(.hour, from: startTime),
                calendar.component(.hour, from: endTime)
            ),
            endHour: max(
                calendar.component(.hour, from: startTime),
                calendar.component(.hour, from: endTime)
            ),
            minute: calendar.component(.minute, from: chimeTime)
        )
        
        NotificationManager.shared.schedule(config: config, sound: selectedSound)
    }
    
    private func load() {
        let data = Persistence.shared.load()
        
        selectedDays = data.days
        startTime = data.start
        endTime = data.end
        chimeTime = data.chime
        selectedSound = data.sound
        isEnabled = data.enabled
        
        if isEnabled {
            apply()
        }
    }
}