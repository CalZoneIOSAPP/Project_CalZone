//
//  RegisterViewModel.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import Foundation


/// The viewmodel for Register View.
class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var privacy = false
    @Published var conditions = false
    
    @Published var alertItem: AlertItem?
    @Published var showLoadingScreen = true
    
    @Published var processingRegistration = false
    
    @Published var createUserError: String = " "
    
    // TODO: CREATE LOCAL USER OBJECT
//    @Published var User
    
    
    // MARK: Creating a new user with Firebase Auth
    /// This function triggers for user creation which was requested on the front end. Calls the corresponding function within the AuthServices.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func createUser() async throws {
        guard isValidForm else { return }
        let err = try await AuthServices.sharedAuth.createUser(withEmail: email, password: password, username: username)
        if err.contains("The email address is already in use by another account.") {
            createUserError = NSLocalizedString("The email address is already in use by another account.", comment: "")
        }
    }
    
    
    /// Checks whether the sign up form is correctly filled.
    /// - Parameters: none
    /// - Returns: Boolean value which checks for registration form.
    var isValidForm: Bool {
        // check if we have all values in the profile forms
        guard !username.isEmpty && !email.isEmpty && !password.isEmpty else {
            DispatchQueue.main.async {
                self.alertItem = AlertContent.invalidForm
            }
            return false
        }
        // check if email string is valid: isValidEmail is a method which extends String
        guard email.isValidEmailFormat else {
            DispatchQueue.main.async {
                self.alertItem = AlertContent.invalidEmail
            }
            return false
        }

        guard password.count >= 6 else {
            DispatchQueue.main.async {
                self.alertItem = AlertContent.invalidPassword
            }
            return false
        }

        return true
    }

    
    
}

