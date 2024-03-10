//
//  MelaScanApp.swift
//  MelaScan
//
//  Created by Yoav Shkedy on 22/10/2023.
//

import SwiftUI

@main
struct MelaScanApp: App {
    // This will retrieve the value from UserDefaults. If the value isn't set yet, it defaults to false.
    @AppStorage("hasSeenWalkthrough") var hasSeenWalkthrough: Bool = false
    
    var body: some Scene {
        WindowGroup {
            // If the user has seen the walkthrough, we'll display the main ContentView. Otherwise, we'll display the walkthrough.
            if hasSeenWalkthrough {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
