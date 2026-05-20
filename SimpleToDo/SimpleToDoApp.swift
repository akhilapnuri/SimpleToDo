//
//  SimpleToDoApp.swift
//  SimpleToDo
//
//  Created by Akhila Pasupunuri on 5/18/26.
//

import SwiftUI

@main
struct SimpleToDoApp: App {
    init() {
        // Request notification permission on app launch
        NotificationManager.shared.requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            LandingView()
        }
    }
}
