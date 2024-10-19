//
//  DeleteAccountViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 10/17/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class DeleteAccountViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showConfirmation = false
    @Published var deletionScheduled = false
    @Published var currentUser: User?
    @Published var password: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupUser()
    }
    
    
    /// This function is called when setting up the user session.
    /// - Parameters: none
    /// - Returns: none
    private func setupUser() {
        UserServices.sharedUser.$currentUser
            .receive(on: DispatchQueue.main) // Ensure that updates happen on the main thread
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }
    

    func cancelDeletion() {
        self.showConfirmation = false
        self.isLoading = false
        self.errorMessage = ""
    }
}
