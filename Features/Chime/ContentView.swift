import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm = ChimeViewModel()
    
    let days = ["S","M","T","W","T","F","S"]
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Days")) {
                    HStack {
                        ForEach(0..<7) { i in
                            Text(days[i])
                                .frame(width: 36, height: 36)
                                .background(vm.selectedDays.contains(i) ? Color.blue : Color.gray.opacity(0.3))
                                .clipShape(Circle())
                                .onTapGesture {
                                    toggle(i)
                                }
                        }
                    }
                }
                
                Section(header: Text("Active Hours")) {
                    DatePicker("From", selection: $vm.startTime, displayedComponents: .hourAndMinute)
                    DatePicker("To", selection: $vm.endTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Chime")) {
                    DatePicker("Time", selection: $vm.chimeTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Sound")) {
                    Picker("Sound", selection: $vm.selectedSound) {
                        ForEach(ChimeSound.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                }
                
                Section {
                    Toggle("Enable", isOn: $vm.isEnabled)
                }
            }
            .navigationTitle("Hourly Chime")
            .onChange(of: vm.isEnabled) { _, _ in vm.apply() }
            .onChange(of: vm.startTime) { _, _ in vm.apply() }
            .onChange(of: vm.endTime) { _, _ in vm.apply() }
            .onChange(of: vm.chimeTime) { _, _ in vm.apply() }
            .onChange(of: vm.selectedSound) { _, _ in vm.apply() }
        }
    }
    
    func toggle(_ i: Int) {
        if vm.selectedDays.contains(i) {
            vm.selectedDays.remove(i)
        } else {
            vm.selectedDays.insert(i)
        }
        vm.apply()
    }
}