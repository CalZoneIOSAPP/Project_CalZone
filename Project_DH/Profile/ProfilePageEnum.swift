//
//  ProfilePageData.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//


import SwiftUI


enum AllUserFields: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }

    case username
    case lastName
    case firstName
    case email
    case birthday
    case profileImageUrl
    case firstTimeUser
    case passwordSet
    case description
    case followerNum
    
    case gender
    case weight
    case weightTarget
    case height
    case bmi
    case activityLevel
    case achievementDate
    case targetCalories

}


enum popupPositivity: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case positive
    case negative
    case informative
    
    var colorBackground: Color {
        switch self {
        case .positive:
            return .brandLightGreen.opacity(0.5)
        case .negative:
            return .brandRed.opacity(0.5)
        case .informative:
            return .brandLightGreen.opacity(0.5)
        }
    }
    
    var colorForeground: Color {
        switch self {
        case .positive:
            return .brandDarkGreen
        case .negative:
            return .brandRed
        case .informative:
            return .brandDarkGreen
        }
    }
    
    var colorIcon: Color {
        switch self {
        case .positive:
            return .brandLightGreen
        case .negative:
            return .brandRed.opacity(0.8)
        case .informative:
            return .gray.opacity(0.8)
        }
    }
    
    var icon: Image {
        switch self {
        case .positive:
            return Image(systemName: "checkmark.circle.fill")
        case .negative:
            return Image(systemName: "xmark.circle.fill")
        case .informative:
            return Image(systemName: "info.circle.fill")
        }
    }
}


enum SettingsOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case changePassword
    case changeLanguage
    
    var title: String {
        switch self {
        case .changePassword:
            return NSLocalizedString("Change Password", comment: "")
        case .changeLanguage:
            return NSLocalizedString("Language", comment: "")
        }
    }
}


enum Language: String, CaseIterable {
    case system = "System Language"
    case english = "English"
    case chinese = "Chinese"
    
    var code: String {
        switch self {
        case .system: return "System"
        case .english: return "en"
        case .chinese: return "zh-Hans"
        }
    }
    
    var displayName: String {
        switch self {
        case .system: return NSLocalizedString("System Language", comment: "")
        case .english: return "English"
        case .chinese: return "简体中文"
        }
    }
}


enum PasswordChangeError: Error, LocalizedError {
    case passwordMismatch
    case userNotLoggedIn
    case passwordSameAsOld
    case reauthenticationFailed(String)
    case passwordChangeFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .passwordMismatch:
            return NSLocalizedString("New password and confirm password do not match.", comment: "")
        case .userNotLoggedIn:
            return NSLocalizedString("User not logged in.", comment: "")
        case .passwordSameAsOld:
            return NSLocalizedString("Your new password must be different from your current password.", comment: "")
        case .reauthenticationFailed(let message):
            return NSLocalizedString("Re-authentication failed:", comment: "") + "\(message)"
        case .passwordChangeFailed(let message):
            return NSLocalizedString("Password change failed: ", comment: "") + "\(message)"
        }
    }
}


enum ProfileOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case meals
    case myStatistics
    case friends
    case settings
    
    /// The title of the options for the profile page menu.
    var title: LocalizedStringKey {
        switch self {
        case .meals:
            return "Meals"
        case .myStatistics:
            return "My Statistics"
        case .friends:
            return "My Friends"
        case .settings:
            return "Settings"
        }
    }
    
}


enum AccountOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case username
    case lastName
    case firstName
    case email
    case birthday
    
    
    /// Title of each options in user info edit page.
    var title: String {
        switch self {
        case .username:
            return NSLocalizedString("Change Username", comment: "")
        case .email:
            return NSLocalizedString("Change Email", comment: "")
        case .firstName:
            return NSLocalizedString("Change First Name", comment: "")
        case .lastName:
            return NSLocalizedString("Change Last Name", comment: "")
        case .birthday:
            return NSLocalizedString("Change Birthday", comment: "")
        }
    }
    
    
    /// Do not localize.
    var firebaseFieldName: String {
        switch self {
        case .username:
            return "userName"
        case .lastName:
            return "lastName"
        case .firstName:
            return "firstName"
        case .email:
            return "email"
        case .birthday:
            return "birthday"
        }
    }
    
    
    /// Placeholder to show for each user info field.
    var placeholder: String {
        switch self {
        case .username:
            return NSLocalizedString("username", comment: "")
        case .lastName:
            return NSLocalizedString("last name", comment: "")
        case .firstName:
            return NSLocalizedString("first name", comment: "")
        case .email:
            return NSLocalizedString("email", comment: "")
        case .birthday:
            return NSLocalizedString("birthday", comment: "")
        }
    }
    
    
    /// Input style for each of the options.
    var inputStyle: inputStyles {
        switch self {
        case .username:
            return .fullText
        case .lastName:
            return .fullText
        case .firstName:
            return .fullText
        case .email:
            return .fullText
        case .birthday:
            return .pickerStyle
        }
    }
    
}


enum DietaryInfoOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case gender
    case weight
    case weightTarget
    case height
    case activityLevel
    case achievementDate
    case targetCalories

    
    /// Title of each options in user info edit page.
    var title: String {
        switch self {
        case .gender:
            return NSLocalizedString("Biological Gender", comment: "")
        case .weight:
            return NSLocalizedString("Body Weight", comment: "")
        case .weightTarget:
            return NSLocalizedString("Target Weight", comment: "")
        case .height:
            return NSLocalizedString("Height", comment: "")
        case .activityLevel:
            return NSLocalizedString("Activity Level", comment: "")
        case .achievementDate:
            return NSLocalizedString("Date of Achievement", comment: "")
        case .targetCalories:
            return NSLocalizedString("Target Calories", comment: "")
        }
    }
    
    
    /// Do not Localize!
    var firebaseFieldName: String {
        switch self {
        case .gender:
            return "gender"
        case .weight:
            return "weight"
        case .weightTarget:
            return "weightTarget"
        case .height:
            return "height"
        case .activityLevel:
            return "activityLevel"
        case .achievementDate:
            return "achievementDate"
        case .targetCalories:
            return "targetCalories"
        }
    }
    
    
    /// Placeholder to show for each user info field.
    var placeholder: String {
        switch self {
        case .gender:
            return NSLocalizedString("biological gender", comment: "")
        case .weight:
            return NSLocalizedString("body weight", comment: "")
        case .weightTarget:
            return NSLocalizedString("target body weight", comment: "")
        case .height:
            return NSLocalizedString("height", comment: "")
        case .activityLevel:
            return NSLocalizedString("activity level", comment: "")
        case .achievementDate:
            return NSLocalizedString("achievement date", comment: "")
        case .targetCalories:
            return NSLocalizedString("target calories", comment: "")

        }
    }
    
    
    /// Input style for each of the options.
    var inputStyle: inputStyles {
        switch self {
        case .gender:
            return .dropDown
        case .weight:
            return .decimalsPad
        case .weightTarget:
            return .decimalsPad
        case .height:
            return .decimalsPad
        case .activityLevel:
            return .dropDown
        case .achievementDate:
            return .pickerStyle
        case .targetCalories:
            return .numPad


        }
    }
    
    var options: dropDownOptions? {
        switch self {
        case .gender:
            return .gender
        case .activityLevel:
            return .activityLevel
        case .weight, .weightTarget, .height, .targetCalories, .achievementDate:
            return nil
        }
    }
    
}


enum inputStyles: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case fullText
    case numPad
    case decimalsPad
    case dropDown
    case pickerStyle
    
    
}


enum genderEnum: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case male
    case female

    
    /// Input style for each of the options.
    var genderStr: String {
        switch self {
        case .male:
            return NSLocalizedString("Male", comment: "")
        case .female:
            return NSLocalizedString("Female", comment: "")
        }
    }
    
}


enum dropDownOptions: Int, CaseIterable, Identifiable {
    var id: Int { return self.rawValue }
    
    case gender
    case activityLevel
    
    var options: [String] {
        switch self {
        case .gender:
            return [NSLocalizedString("male", comment: ""),
                    NSLocalizedString("female", comment: "")]
        case .activityLevel:
            return [NSLocalizedString("Sedentary", comment: ""),
                    NSLocalizedString("Slightly Active", comment: ""),
                    NSLocalizedString("Moderately Active", comment: ""),
                    NSLocalizedString("Very Active", comment: ""),
                    NSLocalizedString("Super Active", comment: "")]
        }
    }
    
    var maxWidth: CGFloat {
        switch self {
        case .gender:
            return 220
        case .activityLevel:
            return 280
        }
    }
    
}
