//
//  LanguageSettingsViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/10/24.
//

import Foundation
import UIKit
import SwiftUI


class LanguageSettingsViewModel: ObservableObject {
    @Published var currentLanguage: Language = .system
    @Published var selectedLanguage: Language? = nil
    
    init() {
        let savedLanguageCode = UserDefaults.standard.string(forKey: "appLanguage") ?? "System"
        self.currentLanguage = Language.allCases.first(where: { $0.code == savedLanguageCode }) ?? .system
        applyLanguage(currentLanguage)
    }
    
    func changeLanguage(to language: Language) {
        self.currentLanguage = language
        UserDefaults.standard.set(language.code, forKey: "appLanguage")
        applyLanguage(language)
//        reloadRootView()
    }
    
    private func applyLanguage(_ language: Language) {
        if language == .system {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([language.code], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
    }
    
    private func reloadRootView() {
        // Find the active scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        // Update the root view for all windows in the scene
        if let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: LaunchScreenView().environmentObject(self))
            window.makeKeyAndVisible()
        }
    }
}
