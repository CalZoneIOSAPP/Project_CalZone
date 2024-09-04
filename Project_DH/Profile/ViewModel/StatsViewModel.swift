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
        
        print("the start date of weekInterval in viewmodel is \(currentDate)")
        print("the whole weekInterval is \(weekInterval)")
        
        // var fetchedData: [(String, Int)] = []
        // var fetchedData: [(String, Int)] = []

        
        // Sequentially fetch calories for each date in the week
        func fetchNextDate() {
            guard currentDate < weekInterval.end else {
                // End of the interval, update the data
                DispatchQueue.main.async {
                    // self.weeklyData = fetchedData
                    // self.weeklyData = fetchedData
                    self.isLoading = false
                }
                return
            }

            fetchCaloriesForDate(userId: userId, date: currentDate) { calories in
                let dateString = DateFormatter.localizedString(from: currentDate, dateStyle: .short, timeStyle: .none)
                print("I have dateString \(dateString), and date \(currentDate), and found calories \(calories)")
                DispatchQueue.main.async {
                    self.weeklyData.append((dateString, calories))
                    self.totalCalories += calories
                    print("Current weeklyData: \(self.weeklyData)")
                }
                
                // Move to the next day
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = nextDay
                    fetchNextDate()  // Fetch the next date in sequence
                } else {
                    DispatchQueue.main.async {
                        // self.weeklyData = fetchedData
                        // self.weeklyData = fetchedData
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
        
        print("I am fetching calories data from \(dayStart) to \(dayEnd)")

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
                // print("No meals found for \(date)")
                completion(0) // No meals found, so calorie count is 0
                return
            }

            var totalCalories = 0
            let mealIds = mealDocuments.compactMap { $0.documentID }
            
            // Ensure mealIds is not empty before querying foodItems
            guard !mealIds.isEmpty else {
                // print("No mealIds found for \(date), setting calories to 0")
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
                            print("I get the foodItem \(foodItem.foodName) with \(foodItem.calorieNumber)")
                        }
                    }
                }

                completion(totalCalories)
            }
        }
    }
}
