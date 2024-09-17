//
//  UserService.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/11/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

/// Takes care of all network tasks of user services with firebase.
class UserServices {

    @Published var currentUser: User?
    @Published var signInViewModel = SignInViewModel()
    
    static let sharedUser = UserServices() // Use this user service object across the application.
    
    
    /// This function fetches all information about the current user. The current user is determined by the Firebase Authentication's current user's uid.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func fetchCurrentUserData() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return } // TODO: ENDED HERE
        let snapshot = try await Firestore.firestore().collection(Collection().user).document(uid).getDocument()
        var user = try snapshot.data(as: User.self)
        
        if let gender = user.gender {
            // Check if the mealType exists in the mapping, if so, localize it
            user.gender = DataMapping().genderMap[gender] ?? gender
        }
        
        if let activityLevel = user.activityLevel {
            user.activityLevel = DataMapping().activityLevelMap[activityLevel] ?? activityLevel
        }
        
        self.currentUser = user
        if let curUser = self.currentUser {
            NotificationTool.scheduleAchievementNotification(for: curUser)
        }
        print("SUCCESS: USER DATA FETCHED \nSource: fetchCurrentUserData() \nUser ID: \(String(describing: user.uid))")
    }
    
    
    /// This function fetches all users in the database except for the current user.
    /// - Parameters:none
    /// - Returns: A list of users.
    func fetchUsers() async throws -> [User]{
        guard let currentUid = Auth.auth().currentUser?.uid else { return []}
        let snapshot = try await Firestore.firestore().collection(Collection().user).getDocuments()
        let users = snapshot.documents.compactMap({ try? $0.data(as: User.self)})
        return users.filter({$0.id != currentUid}) // Do not include the current logged in user
    }
    
    
    /// A function which fetches any user in the application with an uid, not just the current user.
    /// - Parameters:
    ///     - with: The uid of the user which you tries to fetch.
    /// - Returns: User
    static func fetchUser(with uid: String) async throws -> User {
        let snapshot = try await Firestore.firestore().collection(Collection().user).document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    
    /// This function sets the current user to nil.
    /// - Parameters: none
    /// - Returns: none
    func reset() {
        self.currentUser = nil
    }
    
    
    // TODO: Need a more general function for uploading more various user data
    /// This function updates the user's profile image. It saves the image url on Firebase, and sets the image on the application.
    /// - Parameters:
    ///     - with: The image url to save to Firebase.
    /// - Returns: none
    func updateUserProfileImage(with imageUrl: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        // Use Firestore updates in a Task to ensure they run on a background thread
        try await Task {
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData([
                "profileImageUrl": imageUrl
            ])
        }.value

        // Since self.currentUser is updated on the main actor, keep it isolated here
        self.currentUser?.profileImageUrl = imageUrl
    }
    
    
    // TODO: Need a more general function for uploading more various user data
    /// This function updates the username. It saves the username string on Firebase, and sets the username in the application.
    /// - Parameters:
    ///     - with: The username which you want to save.
    /// - Returns: none
    @MainActor
    func updateUserName(with userName: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Perform the Firestore update with explicit return type for the continuation
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["userName": userName]) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }

        // Ensure this UI update is safely within the main actor context
        self.currentUser?.userName = userName
    }
    
    
    /// The generic function to update user's  account information to Firebase.
    /// - Parameters:
    ///     - with: The information to change.
    ///     - enumInfo: The AccountOptions enum option.
    /// - Returns: none
    @MainActor
    func updateAccountOptions<T>(with infoToChange: T, enumInfo: AccountOptions) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        // Perform the Firestore update off the main actor
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let dataToUpdate: [String: Any]

            switch enumInfo {
            case .username:
                guard let newUsername = infoToChange as? String else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for username", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["userName": newUsername]
            case .lastName:
                guard let newLastName = infoToChange as? String else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for lastName", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["lastName": newLastName]
            case .firstName:
                guard let newFirstName = infoToChange as? String else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for firstName", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["firstName": newFirstName]
            case .email:
                guard let newEmail = infoToChange as? String else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for email", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["email": newEmail]
            case .birthday:
                guard let newBirthday = infoToChange as? Date else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for birthday", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["birthday": newBirthday]
            }

            // Update Firestore
            Firestore.firestore().collection(Collection().user).document(currentUid).updateData(dataToUpdate) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }

        // Update local currentUser safely on the main actor
        switch enumInfo {
        case .username:
            self.currentUser?.userName = infoToChange as? String
        case .lastName:
            self.currentUser?.lastName = infoToChange as? String
        case .firstName:
            self.currentUser?.firstName = infoToChange as? String
        case .email:
            self.currentUser?.email = infoToChange as! String
        case .birthday:
            self.currentUser?.birthday = infoToChange as? Date
        }
    }

    
    
    /// The generic function to update user's dietary information to Firebase.
    /// - Parameters:
    ///     - with: The dietary information to change
    ///     - enumInfo: The DietaryInfoOptions enum option.
    /// - Returns: none
    @MainActor
    func updateDietaryOptions<T>(with infoToChange: T, enumInfo: DietaryInfoOptions) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Perform the Firestore update off the main actor
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let dataToUpdate: [String: Any]

            switch enumInfo {
            case .gender:
                guard let newGender = infoToChange as? String else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for gender", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["gender": newGender]
            case .weight:
                guard let newWeight = infoToChange as? Double else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for weight", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["weight": newWeight]
            case .weightTarget:
                guard let newWeightTarget = infoToChange as? Double else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for weightTarget", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["weightTarget": newWeightTarget]
            case .height:
                guard let newHeight = infoToChange as? Double else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for height", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["height": newHeight]
            case .bmi:
                guard let newBmi = infoToChange as? Double else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for bmi", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["bmi": newBmi]
            case .activityLevel:
                guard let newActivityLevel = infoToChange as? String else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for activityLevel", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["activityLevel": newActivityLevel]
            case .achievementDate:
                guard let newAchievementDate = infoToChange as? Date else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for achievementDate", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["achievementDate": newAchievementDate]
            case .targetCalories:
                guard let newTargetCalories = infoToChange as? String else {
                    continuation.resume(throwing: NSError(domain: "Invalid type for targetCalories", code: 0, userInfo: nil))
                    return
                }
                dataToUpdate = ["targetCalories": newTargetCalories]
            }

            // Update Firestore
            Firestore.firestore().collection(Collection().user).document(currentUid).updateData(dataToUpdate) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }

        // Update local currentUser safely on the main actor
        switch enumInfo {
        case .gender:
            self.currentUser?.gender = infoToChange as? String
        case .weight:
            self.currentUser?.weight = infoToChange as? Double
        case .weightTarget:
            self.currentUser?.weightTarget = infoToChange as? Double
        case .height:
            self.currentUser?.height = infoToChange as? Double
        case .bmi:
            self.currentUser?.bmi = infoToChange as? Double
        case .activityLevel:
            self.currentUser?.activityLevel = infoToChange as? String
        case .achievementDate:
            self.currentUser?.achievementDate = infoToChange as? Date
        case .targetCalories:
            self.currentUser?.targetCalories = infoToChange as? String
        }
    }

    
    
    /// This function deletes a field value from Firebase Firestore with a given field name.
    /// - Parameters:
    ///     - field: The field name where the corresponding value will be deleted.
    /// - Returns: none
    @MainActor
    func deleteFieldValue(field: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Perform Firestore delete operation
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Firestore.firestore().collection(Collection().user).document(currentUid).updateData([
                field: FieldValue.delete()
            ]) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }

        // Fetch updated user data
        try await UserServices.sharedUser.fetchCurrentUserData()
    }
    
    
    /// Sets the status of first time login to false for the current user on Firebase.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func updateFirstTimeLogin() async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        // Perform Firestore update off the main thread
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["firstTimeUser": false]) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }

        // Update local currentUser
        self.currentUser?.firstTimeUser = false
    }

    
    /// Sets the status of whether the password for the account is setup.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func updatePasswordSet() async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Perform Firestore operation in a Task to ensure it's not on the main actor
        try await Task.detached {
            try await Firestore.firestore()
                .collection(Collection().user)
                .document(currentUid)
                .updateData(["passwordSet": true])
        }.value
        
        // Update UI-related state on the main actor
        self.currentUser?.firstTimeUser = true
    }
    
    
    /// The generic function to update user's dietary information onto Firebase.
    /// - Parameters:
    ///     - gender:  Gender of the user.
    ///     - weight: User's current weight.
    ///     - weightTarget: User's target weight.
    ///     - bmi: User's BMI value.
    ///     - birthday: User's birthday.
    ///     - activityLevel: The level of daily activity.
    ///     - calories: User's target calorie number.
    /// - Returns: none
    @MainActor
    func uploadUserInitialLoginInfo(
        gender: String,
        weight: Double,
        weightTarget: Double,
        achievementDate: Date,
        height: Double,
        bmi: Double,
        birthday: Date,
        activityLevel: String,
        calories: Int
    ) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Perform Firestore operation in a detached task to avoid sending non-Sendable types in the main actor
        try await Task.detached {
            // Convert Date objects to Firestore-compatible types, such as Timestamp
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData([
                "gender": gender,
                "weight": weight,
                "weightTarget": weightTarget,
                "achievementDate": Timestamp(date: achievementDate),  // Ensure Date compatibility
                "height": height,
                "bmi": bmi,
                "birthday": Timestamp(date: birthday),  // Ensure Date compatibility
                "activityLevel": activityLevel,
                "targetCalories": String(calories)  // Ensure numeric data is serialized correctly
            ])
        }.value
        
        // Fetch the user data on the main actor after the Firestore operation completes
        try await UserServices.sharedUser.fetchCurrentUserData()
    }

    
    
    /// This function updates the users password. If the user does not have a password yet, it will set the password. If the user has a password, then changes it.
    /// - Parameters:
    ///     - oldPassword: The original password.
    ///     - newPassword: The new password.
    ///     - confirmPassword:  The confirmed password string.
    /// - Returns: The confirmation message.
    @MainActor
    func changePassword(oldPassword: String?, newPassword: String, confirmPassword: String) async throws -> PopupMessage {
        // Check if new password and confirm password match
        guard newPassword == confirmPassword else {
            return PopupMessage(message: NSLocalizedString("Your new password and the confirmation do not match.", comment: ""), title: NSLocalizedString("Oops!", comment: ""))
        }
        // Get the current user
        guard let user = Auth.auth().currentUser else {
            return PopupMessage(message: NSLocalizedString("You are not logged in yet.", comment: ""), title: NSLocalizedString("Oops!", comment: ""))
        }
        if let oldPassword = oldPassword {
            // Ensure new password is different from the old password
            guard oldPassword != newPassword else {
                return PopupMessage(message: NSLocalizedString("New password is the same as the current password.", comment: ""), title: NSLocalizedString("Oops!", comment: ""))
            }
            // Re-authenticate with email and password
            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: oldPassword)
            do {
                do {
                    try await user.reauthenticate(with: credential)
                } catch {
                    return PopupMessage(message: NSLocalizedString("Your original password is incorrect.", comment: ""), title: NSLocalizedString("Apologies...", comment: ""))
                }
                try await user.updatePassword(to: newPassword)
                try await updatePasswordSet()
                try await UserServices.sharedUser.fetchCurrentUserData()
                return PopupMessage(message: NSLocalizedString("Successfully changed your password.", comment: ""), title: NSLocalizedString("Success", comment: ""))
            } catch {
                return PopupMessage(message: NSLocalizedString("Failed to change your password due to internal authentication error.", comment: ""), title: NSLocalizedString("Apologies...", comment: ""))
            }
        } else {
            // Re-authenticate if the user signed in with Google or Apple
            if user.providerData.first(where: { $0.providerID == "google.com" }) != nil {
                // Re-authenticate Google users
                do {
                    try await signInViewModel.reauthenticateGoogle() // Re-authenticate with Google
                } catch {
                    return PopupMessage(message: NSLocalizedString("Re-authentication failed for Google user.", comment: ""), title: NSLocalizedString("Apologies...", comment: ""))
                }
            } else if user.providerData.first(where: { $0.providerID == "apple.com" }) != nil {
                print("APPLE REAUTH")
                // Re-authenticate Apple users
                do {
                    print("BEFORE AUTHORIZATION")
                    let authorization = try await signInViewModel.getASAuthorization()
                    print("AFTER AUTHORIZATION: \(authorization)")
                    let nonce = signInViewModel.nonce ?? "" // Fetch the nonce used during sign-in
                    print("NONCE: \(nonce)")
                    try await signInViewModel.reauthenticateApple(authorization)
                    print("Reached here")
                } catch {
                    return PopupMessage(message: NSLocalizedString("Re-authentication failed for Apple user.", comment: ""), title: NSLocalizedString("Apologies...", comment: ""))
                }
            }
            // After successful re-authentication, update the password
            do {
                print("BEFORE PASS CHANGE")
                try await user.updatePassword(to: newPassword)
                try await updatePasswordSet()
                try await UserServices.sharedUser.fetchCurrentUserData()
                return PopupMessage(message: NSLocalizedString("Successfully changed your password.", comment: ""), title: NSLocalizedString("Success", comment: ""))
            } catch {
                return PopupMessage(message: NSLocalizedString("Failed to change your password due to internal authentication error.", comment: ""), title: NSLocalizedString("Apologies...", comment: ""))
            }
        }
    }

    


    
    
}
