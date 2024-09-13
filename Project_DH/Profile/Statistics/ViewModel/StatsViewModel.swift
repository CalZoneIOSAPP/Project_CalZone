//
//  StatsViewModel.swift
//  Project_DH
//
//  Created by mac on 2024/9/3.
//

import SwiftUI
import Combine
import FirebaseFirestore

class StatsViewModel: ObservableObject {
    @Published var weeklyData: [(String, Int)] = []
    @Published var isLoading = true
    @Published var totalCalories = 0
    @Published var averageCalories = 0
    @Published var pickerMode: PickerMode = .week // Track if week or month is selected
    
    private var db = Firestore.firestore()

    
    /// Fetches calorie data for each day in the selected week for the given user.
    /// - Parameters:
    ///   - userId: The ID of the user.
    ///   - weekInterval: The DateInterval representing the selected week.
    func fetchCaloriesForWeek(userId: String, weekInterval: DateInterval) {
        isLoading = true
        pickerMode = .week
        let calendar = Calendar.current
        var currentDate = weekInterval.start
        
        weeklyData = [] // clear previous data
        totalCalories = 0
        averageCalories = 0
        
        /// This function sequentially fetch calories for each date in the week
        /// - Parameters:
        ///     - none
        /// - Returns: none (will update the data in this StatsViewModel)
        func fetchNextDate() {
            guard currentDate < weekInterval.end else {
                // End of the interval, update the data
                DispatchQueue.main.async {
                    self.averageCalories = self.totalCalories / (self.weeklyData.count > 0 ? self.weeklyData.count : 1)
                    self.isLoading = false
                }
                return
            }

            fetchCaloriesForDate(userId: userId, date: currentDate) { calories in
                let dateString = DateFormatter.localizedString(from: currentDate, dateStyle: .short, timeStyle: .none)
                DispatchQueue.main.async {
                    self.weeklyData.append((dateString, calories))
                    self.totalCalories += calories
                }
                
                // Move to the next day
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = nextDay
                    fetchNextDate()  // Fetch the next date in sequence
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        }
        
        fetchNextDate()  // Start fetching from the first day
    }
    
    
    /// Fetches calorie data for each day in the selected month for the given user. Will also do some post-processing to format weeklydata to something like: weeklyData = [("9/1", 1000), ("9/8", 1200), ("9/15", 1100), ("9/22", 1000), ("9/29", 700)]
    /// - Parameters:
    ///   - userId: The ID of the user.
    ///   - monthStart: The start date of the month.
    func fetchCaloriesForMonth(userId: String, monthStart: Date) {
        isLoading = true
        pickerMode = .month
        let calendar = Calendar.current
        guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return }
        var currentDate = monthStart

        weeklyData = [] // clear previous data
        totalCalories = 0
        averageCalories = 0
        
        var accumulatedCalories = 0
        var groupStartDate: Date? = nil
        var daysCount = 0

        /// This function sequentially fetch calories for each date in the week
        /// - Parameters:
        ///     - none
        /// - Returns: none (will update the data in this StatsViewModel)
        func fetchNextDate() {
            guard currentDate < monthEnd else {
                // If there are remaining days, add the final group
                if accumulatedCalories > 0 || daysCount > 0, let groupStart = groupStartDate {
                    let dateString = DateFormatter.localizedString(from: groupStart, dateStyle: .short, timeStyle: .none)
                    weeklyData.append((dateString, accumulatedCalories))
                }

                // Add an entry for the last days of the month with 0 calories if no data exists
                let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: monthEnd) ?? Date()
                if lastDayOfMonth > currentDate {
                    let lastDayString = DateFormatter.localizedString(from: lastDayOfMonth, dateStyle: .short, timeStyle: .none)
                    weeklyData.append((lastDayString, 0))  // Add the missing entry with 0 calories
                }

                // End of the month, update the data
                DispatchQueue.main.async {
                    self.averageCalories = self.totalCalories / (self.weeklyData.count > 0 ? self.weeklyData.count : 1)
                    self.isLoading = false
                }
                return
            }

            fetchCaloriesForDate(userId: userId, date: currentDate) { calories in
                _ = DateFormatter.localizedString(from: currentDate, dateStyle: .short, timeStyle: .none)
                accumulatedCalories += calories
                daysCount += 1
                if groupStartDate == nil {
                    groupStartDate = currentDate // Set the start date for the group
                }

                // Check if we have accumulated 7 days or reached the end of the month
                if daysCount == 7 || currentDate >= monthEnd {
                    DispatchQueue.main.async {
                        if let groupStart = groupStartDate {
                            let groupDateString = DateFormatter.localizedString(from: groupStart, dateStyle: .short, timeStyle: .none)
                            self.weeklyData.append((groupDateString, accumulatedCalories))
                        }
                        self.totalCalories += accumulatedCalories
                        // Reset for the next group
                        accumulatedCalories = 0
                        groupStartDate = nil
                        daysCount = 0
                    }
                }

                // Move to the next day
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = nextDay
                    fetchNextDate()  // Fetch the next date in sequence
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        }
        fetchNextDate()  // Start fetching from the first day
    }
    
    
    /// Fetches calorie data for a specific date for the given user.
    /// - Parameters:
    ///   - userId: The ID of the user.
    ///   - date: The date for which to fetch the data.
    ///   - completion: A closure that is called with the total calories for the day.
    private func fetchCaloriesForDate(userId: String, date: Date, completion: @escaping (Int) -> Void) {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

        let mealsQuery = db.collection("meal")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: dayStart)
            .whereField("date", isLessThan: dayEnd)

        mealsQuery.getDocuments { querySnapshot, error in
            if let error = error {
                print("ERROR: Failed to fetch meals for \(date): \(error.localizedDescription)")
                completion(0)
                return
            }

            guard let mealDocuments = querySnapshot?.documents, !mealDocuments.isEmpty else {
                completion(0) // No meals found, so calorie count is 0
                return
            }

            var totalCalories = 0
            let mealIds = mealDocuments.compactMap { $0.documentID }
            
            // Ensure mealIds is not empty before querying foodItems
            guard !mealIds.isEmpty else {
                completion(0)
                return
            }

            let foodItemsQuery = self.db.collection("foodItems")
                            .whereField("mealId", in: mealIds)
            
            foodItemsQuery.getDocuments { foodQuerySnapshot, error in
                if let error = error {
                    print("ERROR: Failed to fetch food items: \(error.localizedDescription)")
                    completion(0)
                    return
                }

                if let foodDocuments = foodQuerySnapshot?.documents {
                    for document in foodDocuments {
                        if let foodItem = try? document.data(as: FoodItem.self) {
                            totalCalories += foodItem.calorieNumber
                        }
                    }
                }
                completion(totalCalories)
            }
        }
    }
}
