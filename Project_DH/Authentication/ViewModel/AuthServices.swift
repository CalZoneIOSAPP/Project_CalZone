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
            print("LOGGED IN USER WITH EMAIL AND PASSWORD \n\(result.user.uid)" )
        } catch {
            print("ERROR: FAILED TO SIGN IN WITH EMAIL AND PASSWORD! \nSource: AuthServices/login() \n\(error)")
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
            print("LOGIN WITH CREDENTIAL: \nGOT RESULT: \(result.user.uid)")
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
    /// - Returns: none
    @MainActor
    func createUser(withEmail email: String, password: String, username: String) async throws {
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            try await self.uploadUserAuthData(email: email, userName: username, id: result.user.uid, firstTimeUser: true, passwordSet: true)
            try await UserServices.sharedUser.fetchCurrentUserData()
            print("CREATED USER \(result.user.uid)" )
        } catch {
            print("ERROR: FAILED TO CREATE USER \nSource: AuthServices/createUser() \n\(error.localizedDescription)") //automatically gives us the "error" object by swift
        }
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
    func resetPassword(with email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("SENT AN EMAIL TO THE ADDRESS: \(email)" )
        } catch {
            print("ERROR: FAILED TO SEND RESET EMAIL \nSource: AuthServices/resetPassword() \n\(error.localizedDescription)")
        }
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
