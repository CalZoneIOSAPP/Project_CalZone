//
//  Project_MeApp.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 4/27/24.


import SwiftUI
import Firebase
import GoogleSignIn
import TipKit

@main
struct Project_MeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    // Idle Time Tracking
    @Environment(\.scenePhase) var scenePhase
    @State private var timer: Timer?
    let idleThreshold: TimeInterval = 60 * 45 // 5 minutes idle time
    
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
                .onAppear {
                    requestNotificationPermission()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .background:
                        startBackgroundTimer()
                    case .active:
                        cancelBackgroundTimer()
                    default:
                        break
                    }
                }
                .environment(\.sizeCategory, .extraSmall) // global text size category
        }
    }
    
    
    ///  Starts the timer when the app is in the background.
    /// - Parameters: none
    /// - Returns: none
    func startBackgroundTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: idleThreshold, repeats: false) { _ in
            // Perform cleanup or logout logic here
            logoutAndCleanup()
        }
    }

    
    ///  When app becomes active, turn off the timer.
    /// - Parameters: none
    /// - Returns: none
    func cancelBackgroundTimer() {
        timer?.invalidate()
        timer = nil
    }

    
    ///  Exiting the application after inactivity.
    /// - Parameters: none
    /// - Returns: none
    func logoutAndCleanup() {
        exit(0)
    }
    
    
    ///  Initializing and setting up tips for the application.
    /// - Parameters: none
    /// - Returns: none
    private func setupTips() throws {
        try Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault),
        ])
    }
    
    
    /// This function prompts the user for push notification permissions.
    /// - Parameters: none
    /// - Returns: none
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
            if granted {
                NotificationTool.scheduleDailyNotifications()
            }
        }
    }
    
}
