//
//  HourlyChimeApp.swift
//  HourlyChime
//
//  Created by Artem Peshkov on 17/03/2026.
//

import SwiftUI

@main
struct HourlyChimeApp: App {
    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
