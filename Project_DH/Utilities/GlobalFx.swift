//
//  GlobalFx.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/13/24.
//

import Foundation

struct GlobalFx {
    
    
    /// Sum up the calorie number of food items in a list of food items, and return the value..
    /// - Parameters:
    ///     - foodItems: The list of food items.]
    /// - Returns: The number of calories.
    @MainActor
    func getTotalCalories(for foodItems: [FoodItem]) async throws -> Int {
        var totalCal = 0
        for foodItem in foodItems {
            totalCal += foodItem.calorieNumber
        }
        return totalCal
    }
    
    
}
