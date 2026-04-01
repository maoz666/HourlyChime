import Foundation

final class Persistence {
    
    static let shared = Persistence()
    
    private let d = UserDefaults.standard
    
    func save(
        days: Set<Int>,
        start: Date,
        end: Date,
        chime: Date,
        sound: ChimeSound,
        enabled: Bool
    ) {
        d.set(Array(days), forKey: "days")
        d.set(start, forKey: "start")
        d.set(end, forKey: "end")
        d.set(chime, forKey: "chime")
        d.set(sound.rawValue, forKey: "sound")
        d.set(enabled, forKey: "enabled")
    }
    
    func load() -> (
        days: Set<Int>,
        start: Date,
        end: Date,
        chime: Date,
        sound: ChimeSound,
        enabled: Bool
    ) {
        
        let days = Set(d.array(forKey: "days") as? [Int] ?? [1,2,3,4,5])
        
        let start = d.object(forKey: "start") as? Date ??
            Calendar.current.date(from: DateComponents(hour: 9))!
        
        let end = d.object(forKey: "end") as? Date ??
            Calendar.current.date(from: DateComponents(hour: 18))!
        
        let chime = d.object(forKey: "chime") as? Date ?? Date()
        
        let sound = ChimeSound(rawValue: d.string(forKey: "sound") ?? "") ?? .defaultSound
        
        let enabled = d.bool(forKey: "enabled")
        
        return (days, start, end, chime, sound, enabled)
    }
}