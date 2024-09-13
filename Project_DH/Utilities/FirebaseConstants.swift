//
//  FirebaseConstants.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/11/24.
//

import Foundation


// MARK: This file documents all constants to access the fields on firebase firestore.
// TODO: This needs to be adjusted according to this project.

struct Collection {
    let user = "user"
    let chats = "chats"
    let threads = "threads"
}


struct Document {
    let message = "message"
    
}


struct DataConst {
    let model = "model"
}


struct UserConst {
    let firstName = "firstName"
    let lastName = "lastName"
    let email = "email"
    let userName = "userName"
    let profileImageUrl = "profileImageUrl"
    let description = "description"
    let followerNum = "followerNum"
}



// For Localization Purposes
// Use this in functions where it is trying to pull information from the Firebase.
// The default language is English. So when the received string is not English, it will map to one of the following.
struct DataMapping {
    
    let mealTypeMapping: [String: String] = [
        "早餐": NSLocalizedString("breakfast", comment: ""),
        "午餐": NSLocalizedString("lunch", comment: ""),
        "晚餐": NSLocalizedString("dinner", comment: ""),
        "点心/小吃": NSLocalizedString("snack", comment: "")
    ]
    
    let activityLevelMap: [String: String] = [
        "久坐" : NSLocalizedString("Sedentary", comment: ""),
        "稍微活跃" : NSLocalizedString("Slightly Active", comment: ""),
        "中度活跃" : NSLocalizedString("Moderately Active", comment: ""),
        "非常活跃" : NSLocalizedString("Very Active", comment: ""),
        "超级活跃" : NSLocalizedString("Super Active", comment: "")
    ]
    
    let genderMap: [String: String] = [
        "男性": NSLocalizedString("male", comment: ""),
        "女性": NSLocalizedString("female", comment: ""),
    ]
    
}
