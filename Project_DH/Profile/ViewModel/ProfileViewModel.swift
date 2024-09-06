//
//  ProfilePageViewModel.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//

import Foundation
import Combine
import Firebase
import PhotosUI
import SwiftUI


/// Receive the user data from the UserService to this view model. We can then pass the user info into the profile view from this view model
class ProfileViewModel: ObservableObject {
    // Main view
    @Published var currentUser: User?
    @Published var profileImage: Image?
    @Published var userName = ""
    @Published var uiImage: UIImage?
    
    // Edit window
    @Published var showEditWindow = false
    @Published var curStateAccount: AccountOptions?
    @Published var curStateDietary: DietaryInfoOptions?
    @Published var editInfoWindowTitle: String = ""
    @Published var editInfoWindowPlaceHolder: String = ""
    @Published var processingSaving: Bool = false
    @Published var inputType: inputStyles = .fullText
    @Published var strToChange: String = ""
    @Published var optionSelection: String?
    @Published var dateToChange: Date = Date()
    @Published var changeDate: Bool = false // the trigger to control whether date info should be saved to firebase
    @Published var options: [String]?
    @Published var optionMaxWidth: CGFloat = 220
    
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
    
    
    /// This function calls the profile image update logic.
    /// - Parameters: none
    /// - Returns: none
    /// - Note: This function doesn't perform the update logic, it is an interface for the frontend to call.
    func updateProfilePhoto() async throws {
        try await updateProfileImage()
        print("UPDATE: USER PROFILE")
    }
    
    
    /// This function updates the profile username, and handles the logic for that.
    /// - Parameters: none
    /// - Returns: none
    /// - Note: This function doesn't perform the networking tasks, instead it calls the updateUserProfileImage function inside UserServices to do that.
    @MainActor
    private func updateProfileImage() async throws {
        guard let image = self.uiImage else { return }
        guard let imageUrl = try? await ImageUploader.uploadImage(image) else {
            print("ERROR: FAILED TO GET imageURL! \nSource: updateProfileImage() ")
            return
        }
        try await UserServices.sharedUser.updateUserProfileImage(with: imageUrl)
    }
    
    
    /// This function is an generic function which updates any user related information.
    /// - Parameters:
    ///     - with: the enum which is the AccountOptions
    ///     - strInfo: The information to update.
    /// - Returns: none
    @MainActor
    func updateInfo(with accountEnum: AccountOptions?, with dietaryEnum: DietaryInfoOptions?, strInfo: String?, optionStrInfo: String?, dateInfo: Date?, doubleInfo: Double?) async throws {
        guard strInfo != nil || dateInfo != nil || optionStrInfo != nil || doubleInfo != nil else { return }
        
        if accountEnum != nil {
            switch accountEnum {
            case .username:
                try await UserServices.sharedUser.updateAccountOptions(with: strInfo!, enumInfo: .username)
            case .lastName:
                try await UserServices.sharedUser.updateAccountOptions(with: strInfo!, enumInfo: .lastName)
            case .firstName:
                try await UserServices.sharedUser.updateAccountOptions(with: strInfo!, enumInfo: .firstName)
            case .email:
                try await UserServices.sharedUser.updateAccountOptions(with: strInfo!, enumInfo: .email)
            case .birthday:
                try await UserServices.sharedUser.updateAccountOptions(with: dateInfo!, enumInfo: .birthday)
            case .none:
                return
            }
        }
        
        if dietaryEnum != nil{
            switch dietaryEnum {
            case .gender:
                try await UserServices.sharedUser.updateDietaryOptions(with: optionStrInfo!, enumInfo: .gender)
            case .weight:
                try await UserServices.sharedUser.updateDietaryOptions(with: doubleInfo!, enumInfo: .weight)
            case .weightTarget:
                try await UserServices.sharedUser.updateDietaryOptions(with: doubleInfo!, enumInfo: .weightTarget)
            case .height:
                try await UserServices.sharedUser.updateDietaryOptions(with: doubleInfo!, enumInfo: .height)
            case .activityLevel:
                try await UserServices.sharedUser.updateDietaryOptions(with: optionStrInfo!, enumInfo: .activityLevel)
            case .targetCalories:
                try await UserServices.sharedUser.updateDietaryOptions(with: strInfo!, enumInfo: .targetCalories)
            case .none:
                return
            }
        }
        

    }
    
    
    /// This function displays the current user's account information.
    /// - Parameters:
    ///     - with: The enum of AccountOptions.
    /// - Returns: none
    func getUserDisplayStrInfo(with enumType: AccountOptions) -> String {
        switch enumType {
        case .username:
            return currentUser?.userName ?? ""
        case .lastName:
            return currentUser?.lastName ?? ""
        case .firstName:
            return currentUser?.firstName ?? ""
        case .email:
            return currentUser?.email ?? ""
        case .birthday:
            if let birthday = currentUser?.birthday {
                return DateTools().formattedDate(birthday)
            }
            return ""
        }
    }
    
    
    /// This function displays the current user's dietary information.
    /// - Parameters:
    ///     - with: The enum of DietaryInfoOptions.
    /// - Returns: none
    func getUserDietaryInfo(with enumType: DietaryInfoOptions) -> String {
        switch enumType {
        case .gender:
            if let gender = currentUser?.gender {
                return gender
            } else {
                return ""
            }
        case .weight:
            if let weight = currentUser?.weight {
                return String(weight)
            } else {
                return ""
            }
        case .weightTarget:
            if let weightTarget = currentUser?.weightTarget {
                return String(weightTarget)
            } else {
                return ""
            }
        case .height:
            if let height = currentUser?.height {
                return String(height)
            } else {
                return ""
            }
        case .activityLevel:
            if let activityLevel = currentUser?.activityLevel {
                return activityLevel
            } else {
                return ""
            }
        case .targetCalories:
            if let calories = currentUser?.targetCalories {
                return calories
            } else {
                return ""
            }
        }
    }
    
//    private func loadImage() async {
//        guard let item = selectedItem else { return }
//        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
//        guard let uiImage = UIImage(data: data) else { return }
//        self.profileImage = Image(uiImage: uiImage)
//    }
    
    
}
