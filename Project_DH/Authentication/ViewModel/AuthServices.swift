//
//  AuthServices.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import AuthenticationServices
import FirebaseAuth


/// This class handles the actions for the currently selected user, or new users which are about to sign up. Functions take care of the authentication networking tasks.
class AuthServices {
    @Published var signInViewModel = SignInViewModel()
    @Published var userSession: FirebaseAuth.User?
    static let sharedAuth = AuthServices()
    
    init() {
        self.userSession = Auth.auth().currentUser // In charge of taking the user to either welcome view or main menu if they are signed in
        Task { try await UserServices.sharedUser.fetchCurrentUserData() } // Get user data
    }
    
    
    /// Check if there's a valid user session at app launch (Takes care of app deletion)
    /// - Parameters: none
    /// - Returns: none
    func checkUserSession() {
        // Check if it's the first launch after reinstallation
        if isFirstLaunchAfterReinstall() {
            // Force sign out and set the flag
            signOutUser()
            setFirstLaunchFlag()
        } else if let currentUser = Auth.auth().currentUser {
            // If a valid session exists, retain the session
            self.userSession = currentUser
        } else {
            // No session, ensure user is logged out and needs to sign in
            self.userSession = nil
        }
    }
    
    
    /// Function to sign out the firebase user session.
    /// - Parameters: none
    /// - Returns: none
    func signOutUser() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    
    /// Check if this is the first launch after reinstall
    /// - Parameters: none
    /// - Returns: Boolean value whether it is the first launch after reinstall.
    private func isFirstLaunchAfterReinstall() -> Bool {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
        return isFirstLaunch
    }
    
    
    /// Set the first launch flag, so when the user opens the app after first time, it will not automatically sign out Firebase user session.
    /// - Parameters: none
    /// - Returns: none
    private func setFirstLaunchFlag() {
        UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
    }
    
    
    /// Sign in using email and password. Async function.
    /// - Parameters:
    ///     - withEmail: The email address of the user.
    ///     - password: The password corresponding to this account.
    /// - Returns: none
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await UserServices.sharedUser.fetchCurrentUserData()
            print("NOTE: Logged in with email and password for user uid: \(result.user.uid)" )
        } catch {
            print("ERROR: Failed to sign in with email and password. \nSource: AuthServices/login() \n\(error.localizedDescription)")
        }
    }

    
    /// Sign in using credential which is used for Google and Apple Sign in.
    /// - Parameters:
    ///     - credential: credential which is used as input for the Firebase Authentication signIn function.
    /// - Returns: none
    @MainActor
    func login(credential: AuthCredential) async throws {
        do {
            let result = try await Auth.auth().signIn(with: credential)
            print("NOTE: Logged in with credential: \(result.user.uid)")
            self.userSession = result.user
            do {
                try await UserServices.sharedUser.fetchCurrentUserData()
            } catch {
                try await self.uploadUserAuthData(email: result.user.email!, userName: NSLocalizedString("Cool Person", comment: "") + " \(result.user.uid.lowercased().prefix(6))", id: result.user.uid, firstTimeUser: true, passwordSet: false)
                try await UserServices.sharedUser.fetchCurrentUserData()
                print("WARNING: Credential is provided, but failed to fetch user. Creating a new user object in the database. \nSource: AuthServices/login()")
            }
            print("NOTE: Logged in with user credential: \n\(result.user.uid)")
        } catch {
            // TODO: Make sure this is also true for Apple Sign In
            let result = try await Auth.auth().signIn(with: credential)
            try await self.uploadUserAuthData(email: result.user.email!, userName: NSLocalizedString("Cool Person", comment: "") + " \(result.user.uid.lowercased().prefix(6))", id: result.user.uid, firstTimeUser: true, passwordSet: false)
            try await UserServices.sharedUser.fetchCurrentUserData()
            print("ERROR: Failed to sign in with credential. \nSource: AuthServices/login() \n\(error.localizedDescription)")
        }
    }
    
    
    /// The function which handles the Google Sign in method. This function will call the login() function with credential as input.
    /// - Parameters:
    ///     - tokens: id and access tokens
    /// - Returns: none
    @MainActor
    func loginWithGoogle(tokens: GoogleSignInModel) async throws {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        try await login(credential: credential)
    }
    
    
    /// The function which handles the Apple Sign in method. This function will call the login() function with credential as input.
    /// - Parameters:
    ///     - credential: The credential for authentication. OAuthCredential with a nonce string
    /// - Returns: none
    @MainActor
    func loginWithApple(credential: AuthCredential) async throws {
        try await login(credential: credential)
    }
    
    
    /// This function is called when creating a new user through the RegistrationViewModel
    /// - Parameters:
    ///     - withEmail: the email address of the user
    ///     - password: the corresponding password for the user
    ///     - username: the username picked by the user
    /// - Returns: String of the error.
    @MainActor
    func createUser(withEmail email: String, password: String, username: String) async throws -> String {
        var err = " "
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            try await self.uploadUserAuthData(email: email, userName: username, id: result.user.uid, firstTimeUser: true, passwordSet: true)
            try await UserServices.sharedUser.fetchCurrentUserData()
            print("CREATED USER \(result.user.uid)" )
        } catch {
            err = error.localizedDescription
            print("ERROR: FAILED TO CREATE USER \nSource: AuthServices/createUser() \n\(err)") //automatically gives us the "error" object by swift
        }
        return err
    }
    
    
    /// This function signs out of current user session. The current user object should be nil after this function call.
    /// - Parameters: none
    /// - Returns: none
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            UserServices.sharedUser.reset() // Set currentUser object to nil
        } catch {
            print("ERROR: FAILED TO SIGN OUT \nSource: AuthServices/signOut \n\(error.localizedDescription)")
        }
    }
    
    /// This function sends an email to the user's registered email and prompts them with a link to reset the password.
    /// - Parameters:
    ///     - withEmail: The destination email address.
    /// - Returns: none
    @MainActor
    func resetPassword(with email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("SENT AN EMAIL TO THE ADDRESS: \(email)" )
        } catch {
            print("ERROR: FAILED TO SEND RESET EMAIL \nSource: AuthServices/resetPassword() \n\(error.localizedDescription)")
        }
    }
    
    
    /// This function will delete the user's credentials on Firebase Authentication.
    /// - Parameters:
    ///     - none
    /// - Returns:
    ///     - String: error message
    ///     - Bool: whether to show the alert
    ///     - Bool: whether to return to the sign in page
    @MainActor
    func deleteAccount(password: String? = nil) async throws -> (String, Bool, Bool) {
        var errorMessage = ""
        var showLoading = true
        var returnToSignIn = false
        
        guard let user = Auth.auth().currentUser else {
            errorMessage = NSLocalizedString("No user is logged in.", comment: "")
            showLoading = false
            return (errorMessage, showLoading, returnToSignIn)
        }

        guard let providerData = user.providerData.first else {
            errorMessage = NSLocalizedString("Unable to determine authentication provider.", comment: "")
            showLoading = false
            return (errorMessage, showLoading, returnToSignIn)
        }
        
        // Delete all user information on Firebase Database and Storage
        do {
            // Reauthenticate based on provider
            if providerData.providerID == EmailAuthProviderID {
                // Email/Password provider
                if let email = user.email, let password = password {
                    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                    do {
                        try await user.reauthenticate(with: credential)
                    } catch {
                        errorMessage = NSLocalizedString("Your password does not match your current account.", comment: "")
                        showLoading = false
                        return (errorMessage, showLoading, returnToSignIn)
                    }
                } else {
                    errorMessage = NSLocalizedString("You need to enter your CalBite account password to delete the account.", comment: "")
                    showLoading = false
                    return (errorMessage, showLoading, returnToSignIn)
                }
            } else if providerData.providerID == GoogleAuthProviderID {
                // Google Sign-In provider
                do {
                    try await signInViewModel.reauthenticateGoogle()
                } catch {
                    errorMessage = NSLocalizedString("Your google account credential does not match this account, please try again.", comment: "")
                    showLoading = false
                    return (errorMessage, showLoading, returnToSignIn)
                }
                
            } else if providerData.providerID == "apple.com" {
                // Apple Sign-In provider
                let authorization = try await signInViewModel.getASAuthorization()
                let _ = signInViewModel.nonce ?? "" // Fetch the nonce used during sign-in
                do {
                    try await signInViewModel.reauthenticateApple(authorization)
                } catch {
                    errorMessage = NSLocalizedString("Your google account credential does not match this account, please try again.", comment: "")
                    showLoading = false
                    return (errorMessage, showLoading, returnToSignIn)
                }
            }
            
            // After successful reauthentication, proceed to delete user information
            let mealServices = MealServices()
            try await mealServices.fetchMeals(for: user.uid)
            let meals = mealServices.meals // All meals of the user

            try await UserServices.sharedUser.deleteFirstLayerDocument(documentID: user.uid, collectionID: "usages")
            try await UserServices.sharedUser.deleteFirstLayerDocument(documentID: user.uid, collectionID: "subscriptions")
            try await UserServices.sharedUser.deleteDocumentsBasedOnFieldValue(collectionID: "chats", field: "owner", value: user.uid, subCollection: "message")
            try await UserServices.sharedUser.deleteDocumentsBasedOnFieldValue(collectionID: "meal", field: "userId", value: user.uid)
            try await UserServices.sharedUser.deleteImagesForFoodItems(meals: meals) // Deleting food pictures associated with the food items

            // Deleting all foodItems.
            for meal in meals {
                guard let mealId = meal.id else { continue }
                try await UserServices.sharedUser.deleteDocumentsBasedOnFieldValue(collectionID: "foodItems", field: "mealId", value: mealId)
            }

            // Deleting profile image
            if let profileImageUrl = UserServices.sharedUser.currentUser?.profileImageUrl {
                try await ImageManipulation.deleteImageOnFirebase(imageURL: profileImageUrl)
            }
            try await UserServices.sharedUser.deleteFirstLayerDocument(documentID: user.uid, collectionID: "user")

            // Deleting the User on Firebase Auth
            try await user.delete()

            // User successfully deleted, handle post-deletion logic
            returnToSignIn = true
            self.userSession = nil
            showLoading = true
            UserServices.sharedUser.reset() // Set currentUser object to nil
        } catch {
            // Handle errors (reauthentication or deletion errors)
            errorMessage = NSLocalizedString("Error deleting your account, please try again later or contact our support team.", comment: "")
            showLoading = false
        }
        
        return (errorMessage, showLoading, returnToSignIn)
    }
    
    
    /// This function will upload the user's credentials to Firebase Firestore.
    /// - Parameters:
    ///     - email: the email address of the user
    ///     - username: the username picked by the user
    ///     - id: the user's uid
    /// - Returns: none
    @MainActor // Same as Dispatchqueue.main.async
    private func uploadUserAuthData(email: String, userName: String?, id: String, firstTimeUser: Bool, passwordSet: Bool) async throws {
        let user = User(email: email, userName: userName!, profileImageUrl: nil, firstTimeUser: firstTimeUser, passwordSet: passwordSet)
        guard let encodeUser = try? Firestore.Encoder().encode(user) else { return }
        try await Firestore.firestore().collection(Collection().user).document(id).setData(encodeUser)
        UserServices.sharedUser.currentUser = user
    }
    
}
