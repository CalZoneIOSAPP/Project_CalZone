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

    private var db = Firestore.firestore()

    /// Fetches calorie data for each day in the selected week for the given user.
    /// - Parameters:
    ///   - userId: The ID of the user.
    ///   - weekInterval: The DateInterval representing the selected week.
    func fetchCaloriesForWeek(userId: String, weekInterval: DateInterval) {
        isLoading = true
        let calendar = Calendar.current
        var currentDate = weekInterval.start
        
        weeklyData = [] // clear previous data
        totalCalories = 0
        averageCalories = 0
        
        // Sequentially fetch calories for each date in the week
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
    
    /// Fetches calorie data for each day in the selected month for the given user.
    /// - Parameters:
    ///   - userId: The ID of the user.
    ///   - monthStart: The start date of the month.
    func fetchCaloriesForMonth(userId: String, monthStart: Date) {
            isLoading = true
            let calendar = Calendar.current
            print("The MonthStart date is \(monthStart)")
            guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return }
            var currentDate = monthStart
            
            weeklyData = [] // clear previous data
            totalCalories = 0
            averageCalories = 0
            
            // Sequentially fetch calories for each date in the month
            func fetchNextDate() {
                guard currentDate < monthEnd else {
                    // End of the month, update the data
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
