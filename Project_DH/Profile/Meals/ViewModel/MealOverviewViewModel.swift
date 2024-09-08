//
//  MealOverviewViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/8/24.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift


class MealOverviewViewModel: ObservableObject {
    @Published var dashboardViewModel = DashboardViewModel()
    @Published var profileViewModel = ProfileViewModel()
    @Published var testItem = false
    
    /// This function fetches all food items based on the current user's uid.
    /// - Parameters: none
    /// - Returns: none
    /// - Note: After calling the function, you can use allFoodItems to access the list of food items associated with the current user.
    @MainActor
    func fetchAllFoodItems() async throws {
        if let uid = dashboardViewModel.profileViewModel.currentUser?.uid {
            try await dashboardViewModel.fetchAllMeals(for: uid)
        } else {
            print("ERROR: Could not fetch meals. \nSource:MealOverviewViewModel/fetchAllFoodItems()")
            return
        }
    }
    
    func setItem() {
        testItem = true
    }
    
}
