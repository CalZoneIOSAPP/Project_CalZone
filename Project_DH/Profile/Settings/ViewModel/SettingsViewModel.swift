//
//  SettingsViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/7/24.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var currentUser: User?
    // Triggers to show different pages.
    @Published var showChangePassword: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupUser()
    }
    
    
    /// This function is called when setting up the user session.
    /// - Parameters: none
    /// - Returns: none
    private func setupUser() {
        UserServices.sharedUser.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }.store(in: &cancellables)
    }
    
}

