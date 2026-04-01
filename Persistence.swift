import Foundation

class Persistence {
    
    static let shared = Persistence()
    
    private let defaults = UserDefaults.standard
    
    func save(
        days: Set<Int>,
        startTime: Date,
        endTime: Date,
        chimeTime: Date,
        sound: ChimeSound,
        isEnabled: Bool
    ) {
        defaults.set(Array(days), forKey: "selectedDays")
        defaults.set(startTime, forKey: "startTime")
        defaults.set(endTime, forKey: "endTime")
        defaults.set(chimeTime, forKey: "chimeTime")
        defaults.set(sound.rawValue, forKey: "selectedSound")
        defaults.set(isEnabled, forKey: "isEnabled")
    }
    
    func load() -> (
        days: Set<Int>,
        start: Date,
        end: Date,
        chime: Date,
        sound: ChimeSound,
        enabled: Bool
    ) {
        
        let days = Set(defaults.array(forKey: "selectedDays") as? [Int] ?? [1,2,3,4,5])
        
        let start = defaults.object(forKey: "startTime") as? Date ??
            Calendar.current.date(from: DateComponents(hour: 9))!
        
        let end = defaults.object(forKey: "endTime") as? Date ??
            Calendar.current.date(from: DateComponents(hour: 18))!
        
        let chime = defaults.object(forKey: "chimeTime") as? Date ?? Date()
        
        let soundRaw = defaults.string(forKey: "selectedSound") ?? "Default"
        let sound = ChimeSound(rawValue: soundRaw) ?? .defaultSound
        
        let enabled = defaults.bool(forKey: "isEnabled")
        
        return (days, start, end, chime, sound, enabled)
    }
}