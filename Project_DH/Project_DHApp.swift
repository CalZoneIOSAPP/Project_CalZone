//
//  Project_MeApp.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 4/27/24.
//

import SwiftUI
import Firebase
import GoogleSignIn
import TipKit

@main
struct Project_MeApp: App {
    init() {
        FirebaseApp.configure()
        do {
            try setupTips()
        } catch {
            print("ERROR: Setting up tips. \nSource: Project_DHApp")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .preferredColorScheme(.light) // This sets the application to only show in light mode.
        }
    }
    
    
    ///  Initializing and setting up tips for the application.
    /// - Parameters: none
    /// - Returns: none
    private func setupTips() throws {
        try Tips.configure([.displayFrequency(.immediate), .datastoreLocation(.applicationDefault)])
    }
}
