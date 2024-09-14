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
    @Published var firebaseFieldName: String?
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
    @Published var options: [String]?
    @Published var optionMaxWidth: CGFloat = 220
    
    private var cancellables = Set<AnyCancellable>()
    
    let activityLevelMap: [String: Double] = [
        NSLocalizedString("Sedentary", comment: ""): 1.2,
        NSLocalizedString("Slightly Active", comment: ""): 1.375,
        NSLocalizedString("Moderately Active", comment: ""): 1.55,
        NSLocalizedString("Very Active", comment: ""): 1.725,
        NSLocalizedString("Super Active", comment: "") : 1.9
    ]
    
    
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
            case .bmi:
                try await UserServices.sharedUser.updateDietaryOptions(with: doubleInfo!, enumInfo: .bmi)
            case .activityLevel:
                try await UserServices.sharedUser.updateDietaryOptions(with: optionStrInfo!, enumInfo: .activityLevel)
            case .achievementDate:
                try await UserServices.sharedUser.updateDietaryOptions(with: dateInfo!, enumInfo: .achievementDate)
            case .targetCalories:
                try await UserServices.sharedUser.updateDietaryOptions(with: strInfo!, enumInfo: .targetCalories)
            case .none:
                return
            }
        }
    }
    
    
    /// This function has the main logic for calculating target calories and checks when is it valid to do calculation. The target calorie number is saved to Firebase after the calculation.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func calculateAndSaveTargetCalories() async throws {
        if infoAvailableForCalorieCalculation(for: currentUser) {
            let calories = calculateTargetCalories(user: currentUser!)
            strToChange = String(calories)
            try await updateInfo(with: nil, with: .targetCalories, strInfo: String(calories), optionStrInfo: nil, dateInfo: nil, doubleInfo: nil)
        }
    }
    
    
    /// This function has the main logic for calculating BMI and checks when is it valid to do calculation. The BMI number is saved to Firebase after the calculation.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func calculateAndSaveBMI() async throws {
        if infoAvailableForBMICalculation(for: currentUser!) {
            let bmi = calculateBMI(weight: (currentUser?.weight!)!, height: (currentUser?.height!)!)
            try await updateInfo(with: nil, with: .bmi, strInfo: nil, optionStrInfo: nil, dateInfo: nil, doubleInfo: bmi)
        }
    }
    
    
    /// This function calculates the age with the given birthday date.
    /// - Parameters:
    ///     - date: The birthday date.
    /// - Returns: The age number.
    func calculateAge(date birthDate: Date) -> Int {
        let calendar = Calendar.current
        // Get the current date
        let currentDate = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
        return ageComponents.year ?? 0
    }
    
    
    /// This function calculates the number of weeks with a given Date from today's Date.
    /// - Parameters:
    ///     - date: The starting date.
    /// - Returns: Number of weeks.
    func weeksFromDate(date: Date) -> Int {
        let todayDate = Date()
        let calendar = Calendar.current
        let targetDate = date
        let daysDifference = calendar.dateComponents([.day], from: todayDate, to: targetDate).day ?? 0
        let weeksDifference = daysDifference/7
        return weeksDifference
    }
    
    
    /// This function calculates the number of days from today's Date.
    /// - Parameters:
    ///     - date: The starting date.
    /// - Returns: Number of days.
    func daysFromDate(date: Date) -> Int {
        let todayDate = Date()
        let calendar = Calendar.current
        let targetDate = date
        let days = calendar.dateComponents([.day], from: todayDate, to: targetDate).day ?? 0
        return days
    }
    
    
    /// This function holds the formula for calculating the users desired or suggested calorie number.
    /// - Parameters:
    ///     - user: Target user for calorie calculation.
    /// - Returns: Number of calories.
    func calculateTargetCalories(user: User) -> Int {
        let age = calculateAge(date: user.birthday!)
        let weightDiff = user.weightTarget! - user.weight!
        var userBMR: Double
        let a = 5.0 * Double(age)
        let w = 10.0 * user.weight!
        let h = 6.25 * user.height!
        
        if user.gender == NSLocalizedString("male", comment: "") {
            // BMR=10×weight (kg)+6.25×height (cm)−5×age (years)+5
            userBMR = w + h - a + 5.0
        } else {
            // BMR=10×weight (kg)+6.25×height (cm)−5×age (years)−161
            userBMR = w + h - a - 161.0
        }
        
        let userBMR_Motion = userBMR * activityLevelMap[user.activityLevel!]!
        
        // 1 kg of body weight is roughly equivalent to 7700 calories
        let totalCaloriesToAdjust = weightDiff * 7700
        var calorieAdjustment: Double = 0
        
        // if the user selects unreasonable date, then defaults to 30 days
        let weeks = weeksFromDate(date: user.achievementDate!)
        if weeks <= 0 {
            calorieAdjustment = totalCaloriesToAdjust / 30
        } else {
            calorieAdjustment = totalCaloriesToAdjust / (Double(weeks) * 7)
        }
        let calories = Int(userBMR_Motion + calorieAdjustment)
        return calories
    }
    
    
    /// Calculates the BMI value  based on the user input.
    /// - Parameters: 
    ///     - weight: The weight of the user in kg.
    ///     - height: The height of the user in cm.
    /// - Returns: none
    func calculateBMI(weight: Double, height: Double) -> Double {
        var bmiValue = 0.0
        bmiValue = weight / pow((height/100.0), 2)
        bmiValue = Double(round(10 * bmiValue) / 10)
        return bmiValue
    }
    
    
    /// This function decides whether the user meets all requirements to calculate the target calorie number.
    /// - Parameters:
    ///     - user: The user to check against.
    /// - Returns: If the user is eligible for calorie calculation.
    func infoAvailableForCalorieCalculation(for user: User?) -> Bool {
        if let user = user, let gender = user.gender, let height = user.height, let weight = user.weight, let weightTarget = user.weightTarget, let activityLevel = user.activityLevel, let _ = user.birthday, let _ = user.achievementDate {
            if gender == "" || height == 0.0 || weight == 0.0 || weightTarget == 0.0 || activityLevel == "" {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    
    func infoAvailableForBMICalculation(for user: User?) -> Bool {
        if let user = user, let height = user.height, let weight = user.weight {
            if height == 0.0 || weight == 0.0 {
                return false
            } else {
                return true
            }
        } else {
            return false
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
            if let weight = currentUser?.weight, weight > 0.0 {
                return String(weight)
            } else {
                return ""
            }
        case .weightTarget:
            if let weightTarget = currentUser?.weightTarget, weightTarget > 0.0 {
                return String(weightTarget)
            } else {
                return ""
            }
        case .height:
            if let height = currentUser?.height, height > 0.0 {
                return String(height)
            } else {
                return ""
            }
        case .bmi:
            if let bmi = currentUser?.bmi {
                return String(bmi)
            } else {
                return ""
            }
        case .activityLevel:
            if let activityLevel = currentUser?.activityLevel {
                return activityLevel
            } else {
                return ""
            }
        case .achievementDate:
            if let achievementDate = currentUser?.achievementDate {
                return DateTools().formattedDate(achievementDate)
            } else {
                return ""
            }
        case .targetCalories:
            if let calories = currentUser?.targetCalories, Double(calories) ?? 0.0 > 0.0 {
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
