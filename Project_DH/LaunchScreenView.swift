//
//  LaunchScreenView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/1/24.
//

import SwiftUI


struct LaunchScreenView: View {
    @State private var showPopup = false // Control popup visibility
    @State private var proceedToApp = false // Control navigation to the main app

    var body: some View {
        ZStack {
            if proceedToApp {
                AppEntryView() // Main app view
            } else {
                LaunchScreenContentView()
                    .onAppear {
                        delayAndCheckLaunchConditions()
                    }
                    .popup(isPresented: $showPopup) {
                        // This closure will be executed when the popup is dismissed
                        proceedToApp = true
                    }
            }
        }
    }

    // Function to delay for a certain time before checking the launch conditions
    private func delayAndCheckLaunchConditions() {
        let delayDuration = 2.0 // Delay duration in seconds

        DispatchQueue.main.asyncAfter(deadline: .now() + delayDuration) {
            checkLaunchConditionsAndShowPopup()
        }
    }

    // Function to check if the user has agreed to the terms and if it's the first launch
    private func checkLaunchConditionsAndShowPopup() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "isFirstLaunch")
        let hasAgreed = UserDefaults.standard.bool(forKey: "hasAgreed")
        
        if !hasAgreed {
            // Show the popup if the user has not agreed yet
            showPopup = true
        } else {
            // Proceed directly to the app if the user has already agreed
            proceedToApp = true
        }
        
        // Mark the first launch
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
        }
    }
}


struct LaunchScreenContentView: View {
    var body: some View {
        VStack {
            VStack {
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 100)
            }
        }
        .frame(minHeight: 2000)
    }
}


#Preview {
    LaunchScreenView()
}
