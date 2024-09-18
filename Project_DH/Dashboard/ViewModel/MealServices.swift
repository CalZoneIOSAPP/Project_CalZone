//
//  MealServices.swift
//  Project_DH
//
//  Created by mac on 2024/7/26.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class MealServices: ObservableObject {
    
    @Published var meals = [Meal]()
    private var db = Firestore.firestore()
    
    
    /// This function fetches all meals for a given user.
    /// - Parameters:
    ///     - for: user's id
    ///     - on: the meals are fetched on this date
    /// - Returns: none
    /// - Note: If you want to fetch all meals, set the date to nil or do not give a date.
    @MainActor
    func fetchMeals(for userId: String?, on date: Date? = nil) async throws {
        guard let userId = userId else { return }
        
        var query: Query = db.collection("meal")
            .whereField("userId", isEqualTo: userId)
        
        if let date = date {
            // If a date is provided, filter meals for that specific day
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            query = query
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
                .whereField("date", isLessThan: Timestamp(date: endOfDay))
        } else {
            query = query.order(by: "date", descending: true)
        }
        
        let querySnapshot = try await query.getDocuments()
        
        self.meals = querySnapshot.documents.compactMap { document in
            var meal = try? document.data(as: Meal.self)
            
            if let mealType = meal?.mealType {
                // Check if the mealType exists in the mapping, if so, localize it
                meal?.mealType = DataMapping().mealTypeMapping[mealType] ?? mealType
            }
            
            return meal
        }

    }
    
    
    /// This function fetches the specific meal.
    /// - Parameters:
    ///     - mealId: The id of the meal.
    ///     - userId: The id of the user.
    /// - Returns: The fetched meal.
    @MainActor
    func fetchMeal(by mealId: String, for userId: String?) async throws -> Meal? {
        guard let userId = userId else { return nil }
        
        let query: Query = db.collection("meal")
            .whereField("userId", isEqualTo: userId)
            .whereField("mealId", isEqualTo: mealId)
        
        let querySnapshot = try await query.getDocuments()
        
        // Since mealId is unique, we expect at most one document.
        if let document = querySnapshot.documents.first {
            return try? document.data(as: Meal.self)
        } else {
            return nil // No meal found with this mealId
        }
    }
    
    
    /// This function is for loading mock data of meals.
    /// - Parameters: none
    /// - Returns: none
    func loadMockData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        meals = [
            Meal(id: "1", date: formatter.date(from: "2024/07/26 08:00")!, mealType: .breakfast, userId: "user1"),
            Meal(id: "2", date: formatter.date(from: "2024/07/26 12:00")!, mealType: .lunch, userId: "user1"),
            Meal(id: "3", date: formatter.date(from: "2024/07/26 19:00")!, mealType: .dinner, userId: "user1"),
            Meal(id: "4", date: formatter.date(from: "2024/07/27 08:00")!, mealType: .breakfast, userId: "user2"),
            Meal(id: "5", date: formatter.date(from: "2024/07/27 12:00")!, mealType: .lunch, userId: "user2"),
            Meal(id: "6", date: formatter.date(from: "2024/07/27 19:00")!, mealType: .dinner, userId: "user2")
        ]
    }
}
