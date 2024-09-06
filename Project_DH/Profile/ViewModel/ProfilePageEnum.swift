//
//  ProfilePageData.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/10/24.
//


import SwiftUI


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
    case password
    case birthday
    
    
    /// Title of each options in user info edit page.
    var title: String {
        switch self {
        case .username:
            return "Change Username"
        case .email:
            return "Change Email"
        case .password:
            return "Change Password"
        case .firstName:
            return "Change First Name"
        case .lastName:
            return "Change Last Name"
        case .birthday:
            return "Change Birthday"
        }
    }
    
    
    /// Placeholder to show for each user info field.
    var placeholder: String {
        switch self {
        case .username:
            return "username"
        case .lastName:
            return "last name"
        case .firstName:
            return "first name"
        case .email:
            return "email"
        case .password:
            return "password"
        case .birthday:
            return "birthday"
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
        case .password:
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
    case targetCalories
    
    /// Title of each options in user info edit page.
    var title: String {
        switch self {
        case .gender:
            return "Biological Gender"
        case .weight:
            return "Body Weight"
        case .weightTarget:
            return "Target Weight"
        case .height:
            return "Height"
        case .targetCalories:
            return "Target Calories"
        }
    }
    
    /// Placeholder to show for each user info field.
    var placeholder: String {
        switch self {
        case .gender:
            return "biological gender"
        case .weight:
            return "body weight"
        case .weightTarget:
            return "target body weight"
        case .height:
            return "height"
        case .targetCalories:
            return "target calories"
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
        case .targetCalories:
            return .numPad
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
            return "Male"
        case .female:
            return "Female"
        }
    }
    
}
