//
//  User.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/11/24.
//

import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore
import Firebase


// TODO: MAKE SURE TO EDIT THIS DATA MODEL ACCORDING OUR NEEDS
/// The data model for creating a user of this application.
struct User: Codable, Identifiable, Hashable {
    
    @DocumentID var uid: String? // Assign the Document Id on the firestore to the uid variable.
    
    // Major Information
    var firstName: String?
    var lastName: String?
    var email: String
    var tel: String?
    var userName: String?
    var profileImageUrl: String?
    var address: String?
    
    //Authentication
    var firstTimeUser: Bool?
    var passwordSet: Bool?
    var id: String { // Use this to work with instead of the uid
        return uid ?? NSUUID().uuidString
    }
    
    // Other Information
    var description: String?
    var followerNum: Int?
    
    // Personal Information
    var birthday: Date?
    var gender: String?
    var targetCalories: String?
    var bmi: Double?
    var weight: Double?
    var weightTarget: Double?
    var height: Double?
    var activityLevel: String?
    var achievementDate: Date?
    
    
    
    /// The function returns whether the user is trying to lose weight based on the current and target weight values.
    /// - Parameters: none
    /// - Returns: If the user is trying to lose weight.
    func loseWeight() -> Bool {
        if let weight = weight, let weightTarget = weightTarget {
            if weight > weightTarget {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    
    /// The function returns whether the user is trying to keep weight based on the current and target weight values.
    /// - Parameters: none
    /// - Returns: If the user is trying to lose weight.
    func keepWeight() -> Bool {
        if let weight = weight, let weightTarget = weightTarget {
            if weight == weightTarget {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
}


// Mock user
extension User {
    static let MOCK_USER = User(uid: NSUUID().uuidString,
                                firstName: "Jimmy",
                                lastName: "Lyu",
                                email: "bigsmartmovie@gmail.com",
                                tel: "5087235805",
                                userName: "Kinopio",
                                firstTimeUser: true, description: "bigsmart",
                                followerNum: 1,
                                targetCalories: "1000",
                                weight: 55.0,
                                weightTarget: 60.0,
                                height: 175.0
                            )
}



struct Usage: Codable, Identifiable, Hashable {
    // per day usage limit
    @DocumentID var uid: String?
    
    var lastUsageTimestamp: Date?
    
    var maxCalorieAPIUsageNumRemaining: Int? = 5 // The number of times user can estimate calories.
    var maxAssistantTokenNumRemaining: Int? = 5000 // The number of tokens available when user is using AI Assistant. (Not implemented yet. No need for now.)
    
    var id: String { // Use this to work with instead of the uid
        return uid ?? NSUUID().uuidString
    }
    
    
    /// Reseting the usage limits.
    /// - Parameters:
    ///     - currentTimestamp: The current timestamp as a new starting point  of 24 hours.
    /// - Returns: none
    mutating func resetUsage(with currentTimestamp: Date) {
        maxCalorieAPIUsageNumRemaining = 5
        maxAssistantTokenNumRemaining = 5000
        lastUsageTimestamp = currentTimestamp
    }
    
}


struct Membership: Codable, Identifiable, Hashable {
    // per day usage limit
    @DocumentID var uid: String?
    
    var timeRemaining: Date?
    var type: String?
    
    var id: String { // Use this to work with instead of the uid
        return uid ?? NSUUID().uuidString
    }
    
}
