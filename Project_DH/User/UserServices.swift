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
        let user = try snapshot.data(as: User.self)
        self.currentUser = user
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
    @MainActor
    func updateUserProfileImage(with imageUrl: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData([
            "profileImageUrl": imageUrl
        ])
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
        try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["userName": userName])
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
        switch enumInfo {
        case .username:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["userName": infoToChange])
            self.currentUser?.userName = infoToChange as? String
        case .lastName:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["lastName": infoToChange])
            self.currentUser?.lastName = infoToChange as? String
        case .firstName:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["firstName": infoToChange])
            self.currentUser?.firstName = infoToChange as? String
        case .email:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["email": infoToChange])
            self.currentUser?.email = infoToChange as! String
        case .birthday:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["birthday": infoToChange])
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
        switch enumInfo {
        case .gender:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["gender": infoToChange])
            self.currentUser?.gender = infoToChange as? String
        case .weight:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["weight": infoToChange])
            self.currentUser?.weight = infoToChange as? Double
        case .weightTarget:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["weightTarget": infoToChange])
            self.currentUser?.weightTarget = infoToChange as? Double
        case .height:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["height": infoToChange])
            self.currentUser?.height = infoToChange as? Double
        case .activityLevel:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["activityLevel": infoToChange])
            self.currentUser?.activityLevel = infoToChange as? String
        case .achievementDate:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["achievementDate": infoToChange])
            self.currentUser?.achievementDate = infoToChange as? Date
        case .targetCalories:
            try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["targetCalories": infoToChange])
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
        try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData([
            field: FieldValue.delete()
        ])
        try await UserServices.sharedUser.fetchCurrentUserData()
    }
    
    
    /// Sets the status of first time login to false for the current user on Firebase.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func updateFirstTimeLogin() async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["firstTimeUser" : false])
        self.currentUser?.firstTimeUser = false
    }
    
    
    /// Sets the status of whether the password for the account is setup.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func updatePasswordSet() async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData(["passwordSet" : true])
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
    func uploadUserInitialLoginInfo(gender: String, weight: Double, weightTarget: Double, bmi: Double, birthday: Date, activityLevel: String, calories: Int) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await Firestore.firestore().collection(Collection().user).document(currentUid).updateData([
            "gender" : gender,
            "weight" : weight,
            "weightTarget" : weightTarget,
            "bmi" : bmi,
            "birthday" : birthday,
            "activityLevel" : activityLevel,
            "targetCalories" : String(calories)
        ])
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
            return PopupMessage(message: "Your new password and the confirmation do not match.", title: "Oops!")
        }
        // Get the current user
        guard let user = Auth.auth().currentUser else {
            return PopupMessage(message: "You are not logged in yet.", title: "Oops!")
        }
        if let oldPassword = oldPassword {
            // Ensure new password is different from the old password
            guard oldPassword != newPassword else {
                return PopupMessage(message: "New password is the same as the current password.", title: "Oops!")
            }
            // Re-authenticate with email and password
            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: oldPassword)
            do {
                do {
                    try await user.reauthenticate(with: credential)
                } catch {
                    return PopupMessage(message: "Your original password is incorrect.", title: "Apologies...")
                }
                try await user.updatePassword(to: newPassword)
                try await updatePasswordSet()
                return PopupMessage(message: "Successfully changed your password.", title: "Success")
            } catch {
                return PopupMessage(message: "Failed to change your password due to internal authentication error.", title: "Apologies...")
            }
        } else {
            // Re-authenticate if the user signed in with Google or Apple
            if user.providerData.first(where: { $0.providerID == "google.com" }) != nil {
                // Re-authenticate Google users
                do {
                    try await signInViewModel.reauthenticateGoogle() // Re-authenticate with Google
                } catch {
                    return PopupMessage(message: "Re-authentication failed for Google user.", title: "Apologies...")
                }
            } else if user.providerData.first(where: { $0.providerID == "apple.com" }) != nil {
                // Re-authenticate Apple users
                do {
                    let authorization = try await signInViewModel.getASAuthorization()
                    try await signInViewModel.reauthenticateApple(authorization) // Re-authenticate with Apple
                } catch {
                    return PopupMessage(message: "Re-authentication failed for Apple user.", title: "Apologies...")
                }
            }
            // After successful re-authentication, update the password
            do {
                try await user.updatePassword(to: newPassword)
                try await updatePasswordSet()
                return PopupMessage(message: "Successfully changed your password.", title: "Success")
            } catch {
                return PopupMessage(message: "Failed to change your password due to internal authentication error.", title: "Apologies...")
            }
        }
    }

    


    
    
}
