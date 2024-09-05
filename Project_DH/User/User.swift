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
    var firstTimeUser: Bool?
    
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
    var activityLevel: String?
    
}


// Mock user
extension User {
    static let MOCK_USER = User(email: "123@gmail.com", userName: "MockUserName", firstTimeUser: true)
    
}



struct Usage: Codable, Identifiable, Hashable {
    // per day usage limit
    @DocumentID var uid: String?
    
    var lastUsageTimestamp: Date?
    
    var maxCalorieAPIUsageNumRemaining: Int? = 10 // The number of times user can estimate calories.
    var maxAssistantTokenNumRemaining: Int? = 10000 // The number of tokens available when user is using AI Assistant. (Not implemented yet. No need for now.)
    
    var id: String { // Use this to work with instead of the uid
        return uid ?? NSUUID().uuidString
    }
    
    
    /// Reseting the usage limits.
    /// - Parameters:
    ///     - currentTimestamp: The current timestamp as a new starting point  of 24 hours.
    /// - Returns: none
    mutating func resetUsage(with currentTimestamp: Date) {
        maxCalorieAPIUsageNumRemaining = 10
        maxAssistantTokenNumRemaining = 10000
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
