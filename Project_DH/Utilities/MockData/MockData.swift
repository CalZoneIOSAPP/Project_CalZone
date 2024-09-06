//
//  MockData.swift
//  Project_Me
//
//  Created by mac on 2024/5/4.
//

import Foundation


/// This struct is for mock users.
struct MockData {
    
    static let mockUsers: [User] = [
        .init(
            uid: NSUUID().uuidString,
            firstName: "Jimmy",
            lastName: "Lyu",
            email: "bigsmartmovie@gmail.com",
            tel: "5087235805",
            userName: "Kinopio",
            profileImageUrl: "",
            firstTimeUser: true, description: "bigsmart",
            followerNum: 1,
            targetCalories: "1000",
            weight: 55.0,
            weightTarget: 60.0
            
        ),
        .init(
            uid: NSUUID().uuidString,
            firstName: "UZI",
            lastName: "Zhu",
            email: "bigsmart@gmail.com",
            userName: "RNGUZI",
            profileImageUrl: "",
            firstTimeUser: false, description: "REAL UZI",
            followerNum: 2
        )
    ]
    
}
