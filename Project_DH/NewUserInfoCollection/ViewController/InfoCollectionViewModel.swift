//
//  InfoCollectionViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/4/24.
//

import Foundation

class InfoCollectionViewModel: ObservableObject {
    // Gender Selection
    @Published var gender: String = ""
    // Weight Selection
    @Published var weight: Double = 0.0
    // Target Weight Selection
    @Published var targetWeight: Double = 0.0
    @Published var targetDurationWeeks: Int = 0
    // Height Selection
    @Published var height: Double = 0.0
    // Birthday Selection
    @Published var birthday: Date = Date()
    @Published var selectedYear = 2000
    @Published var selectedMonth = 1
    @Published var selectedDay = 1
    @Published var age: Int = 0
    // Select whether to save the info.
    @Published var calories: Int = 0
    @Published var saveSelected: Bool = false
    
    
    
    func calculateAge() {
        let calendar = Calendar.current
        // Get the current date
        let currentDate = Date()
        // Create a date from the selected year, month, and day
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = selectedDay
        guard let birthDate = calendar.date(from: components) else {
            print("ERROR: Invalid date components \nSource: InfoCollectionViewModel/calculateAge")
            return
        }
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
        age = ageComponents.year ?? 0
    }
    
    
    func turnValuesToDate() {
        
    }
    
    
    func saveInfoToUser() {
        
    }
    
    
    func calculateTargetCalories() {
        calculateAge()
        let weightDiff = targetWeight - weight
        var userBMR: Double
        let a = 5.0 * Double(age)
        let w = 10.0 * weight
        let h = 6.25 * height
        
        if gender == "male" {
            // BMR=10×weight (kg)+6.25×height (cm)−5×age (years)+5
            userBMR = w + h - a + 5.0
        } else {
            // BMR=10×weight (kg)+6.25×height (cm)−5×age (years)−161
            userBMR = w + h - a - 161.0
        }
        
        // 1 kg of body weight is roughly equivalent to 7700 calories
        let totalCaloriesToAdjust = weightDiff * 7700
        let calorieAdjustment = totalCaloriesToAdjust / (Double(targetDurationWeeks) * 7) // TODO: Weight
        
        
        calories = Int(userBMR + calorieAdjustment)
    }
    
}
