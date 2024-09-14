//
//  InfoCollectionViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/4/24.
//

import Foundation

class InfoCollectionViewModel: ObservableObject {
    @Published var dateTools = DateTools()
    @Published var profileViewModel = ProfileViewModel()
    // Gender Selection
    @Published var gender: String = NSLocalizedString("female", comment: "")
    // Weight Selection
    @Published var weight: CGFloat = 66.6
    // Target Weight Selection
    @Published var weightTarget: Double = 75.0
    @Published var targetYear = 2000
    @Published var targetMonth = 1
    @Published var targetDay = 1
    @Published var bmiValue: Double = 1.0
    @Published var bmiLevel: String = NSLocalizedString("Ideal", comment: "")
    @Published var percentChanged: Int = 0
    @Published var weightStatus: String = NSLocalizedString("Nice, you choose to keep as you are!", comment: "")
    // Height Selection
    @Published var height: Double = 175
    @Published var heightPicker: Int = 175
    // Birthday Selection
    @Published var birthday: Date = Date()
    @Published var selectedYear = 2000
    @Published var selectedMonth = 6
    @Published var selectedDay = 17
    @Published var age: Int = 0
    // Sport Status
    @Published var activityLevel: String = ""
    let activityLevelMap: [String: Double] = [
        NSLocalizedString("Sedentary", comment: ""): 1.2,
        NSLocalizedString("Slightly Active", comment: ""): 1.375,
        NSLocalizedString("Moderately Active", comment: ""): 1.55,
        NSLocalizedString("Very Active", comment: ""): 1.725,
        NSLocalizedString("Super Active", comment: "") : 1.9
    ]
    
    // Select whether to save the info.
    @Published var calories: Int = 0
    @Published var saveSelected: Bool = true
    
    var targetDurationWeeks: Int {
        let todayDate = Date()
        var components = DateComponents()
        components.year = targetYear
        components.month = targetMonth
        components.day = targetDay
        let calendar = Calendar.current
        guard let targetDate = calendar.date(from: components) else {
            return 0
        }
        
        let daysDifference = calendar.dateComponents([.day], from: todayDate, to: targetDate).day ?? 0
        
        let weeksDifference = daysDifference/7
        return weeksDifference
    }
    
    
    init() {
        targetYear = dateTools.getTodayYearComponent()
        targetMonth = dateTools.getTodayMonthComponent()
        targetDay = dateTools.getTodayDayComponent()
        calculateAge()
    }
    
    
    /// Calculate the age based on the InfoCollectionViewModel's selected year, month and day values.
    /// - Parameters: none
    /// - Returns: none
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
        birthday = dateTools.constructDate(year: selectedYear, month: selectedMonth, day: selectedDay)!
        age = ageComponents.year ?? 0
    }
    
    
    /// Saves the selected info to Firebase, this function is a wrapper which calls the uploadUserInitialLoginInfo() function in UserServices.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func saveInfoToUser() async throws{
        try await UserServices.sharedUser.uploadUserInitialLoginInfo(gender: gender, weight: weight, weightTarget: weightTarget, achievementDate: dateTools.constructDate(year: targetYear, month: targetMonth, day: targetDay)!, height: height, bmi: bmiValue, birthday: birthday, activityLevel: activityLevel, calories: calories)
    }
    
    
    /// Calculates the percentage of weight change based on the target weight and current user's weight. Overwrites the viewModel's percentChanged field.
    /// - Parameters: none
    /// - Returns: none
    func calculatePercentWeightChange() {
        percentChanged = Int((weightTarget-weight)/weight * 100)
    }
    
    
    /// Overwrites the viewModel's weightStatus field based on the value of percent weight change.
    /// - Parameters: none
    /// - Returns: none
    func getPercentChangeString() {
        if percentChanged > 0 {
            weightStatus = NSLocalizedString("gain weight", comment: "")
        } else if percentChanged < 0 {
            weightStatus = NSLocalizedString("loose weight", comment: "")
        } else {
            weightStatus = NSLocalizedString("Nice, you choose to keep as you are!", comment: "")
        }
    }
    
    
    /// Calculates the target calories based on the user input. It uses the Mifflin-St Jeor Equation.
    /// - Parameters: none
    /// - Returns: none
    func calculateTargetCalories() {
        calculateAge()
        let weightDiff = weightTarget - weight
        var userBMR: Double
        let a = 5.0 * Double(age)
        let w = 10.0 * weight
        let h = 6.25 * height
        
        if gender == NSLocalizedString("male", comment: "") {
            // BMR=10×weight (kg)+6.25×height (cm)−5×age (years)+5
            userBMR = w + h - a + 5.0
        } else {
            // BMR=10×weight (kg)+6.25×height (cm)−5×age (years)−161
            userBMR = w + h - a - 161.0
        }
        
        let userBMR_Motion = userBMR * activityLevelMap[activityLevel]!
        
        // 1 kg of body weight is roughly equivalent to 7700 calories
        let totalCaloriesToAdjust = weightDiff * 7700
        var calorieAdjustment: Double = 0
        
        // if the user selects unreasonable date, then defaults to 30 days
        if targetDurationWeeks <= 0 {
            calorieAdjustment = totalCaloriesToAdjust / 30
        } else {
            calorieAdjustment = totalCaloriesToAdjust / (Double(targetDurationWeeks) * 7)
        }
        calories = Int(userBMR_Motion + calorieAdjustment)
    }
    
    
    /// Calculates the BMI value  based on the user input.
    /// - Parameters: none
    /// - Returns: none
    func calculateBMI() {
        bmiValue = weight / pow((height/100.0), 2)
        bmiValue = Double(round(10 * bmiValue) / 10)
        
        if bmiValue <= 18.5 {
            bmiLevel = NSLocalizedString("Thin", comment: "")
        } else if bmiValue > 18.5 && bmiValue <= 25.0 {
            bmiLevel = NSLocalizedString("Ideal", comment: "")
        } else if bmiValue > 25.0 && bmiValue <= 30.0 {
            bmiLevel = NSLocalizedString("Overweight", comment: "")
        } else if bmiValue > 30.0 {
            bmiLevel = NSLocalizedString("Obese", comment: "")
        }
    }
    
    
    /// Revert back to the current date if the selected date is in the past.
    /// - Parameters: none
    /// - Returns: none
    func fixDate() {
        let date = dateTools.constructDate(year: targetYear, month: targetMonth, day: targetDay)
        if dateTools.isDateInPast(date!) {
            targetYear = dateTools.getTodayYearComponent()
            targetMonth = dateTools.getTodayMonthComponent()
            targetDay = dateTools.getTodayDayComponent()
        }
    }
    
    
}
