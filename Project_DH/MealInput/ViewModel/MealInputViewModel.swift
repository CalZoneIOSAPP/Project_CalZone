//
//  MediaInputViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/24/24.
//

import Foundation
import OpenAI
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import FirebaseStorage
import FirebaseFunctions


class MealInputViewModel: ObservableObject {
    @Published var calories: String?
    @Published var predictedCalories: String?
    @Published var image: UIImage?
    @Published var mealName = ""
    @Published var showMessageWindow = false
    @Published var isLoading = false
    @Published var imageChanged = false
    @Published var showInputError = false
    @Published var showUsageError = false
    @Published var showEstimationError = false
    @Published var sliderValue: Double = 100.0
    @Published var selectedMealType: MealType?
    @Published var selectedDate = Date()
    @Published var isProcessingMealInfo = false
    @Published var remainingEstimations = -1
    
    private let db = Firestore.firestore()
    private let functions = Functions.functions()
    
    
    /// This function retrieves the remaining usage of calorie estimation.
    /// - Parameters:
    ///     - user:  The user which the usage belongs to.
    /// - Returns: none
    /// - Note: If there is no usage for the user yet, then it will create it.
    @MainActor
    func getRemainingUsage(for user: User) async throws {
//        print("Getting remaining usage for: \(String(describing: user.uid))")
        guard let userId = user.uid else {
            return
        }
        
        let usageDocRef = db.collection("usages").document(userId)
        
        do {
            let document = try await usageDocRef.getDocument()
            var usage: Usage
            
            if document.exists {
                usage = try document.data(as: Usage.self)
            } else {
                print("NOTE: Usage document does not exist. Creating a new usage document.")
                usage = Usage(uid: userId, lastUsageTimestamp: Date(), maxCalorieAPIUsageNumRemaining: 5, maxAssistantTokenNumRemaining: 5000)

                // Upload the new Usage document to Firestore
                try usageDocRef.setData(from: usage)
                print("NOTE: New usage document successfully created")
            }
            
            let currentTimestamp = Date()
            let lastUsageTimestamp = usage.lastUsageTimestamp ?? Date.distantPast
            
            // Calculate the time interval between the last usage and now
            let timeInterval = currentTimestamp.timeIntervalSince(lastUsageTimestamp)
                
            // Check if 24 hours (86400 seconds) have passed
            if timeInterval >= 86400 {
                // Reset the usage counters
                usage.resetUsage(with: currentTimestamp)
                try usageDocRef.setData(from: usage)
            }
            remainingEstimations = usage.maxCalorieAPIUsageNumRemaining ?? 0
        } catch {
            print("ERROR: Error decoding usage document: \(error)")
        }
        
    }
    
    
    /// This function handles the logic for checking the available usage and then getting the meal info..
    /// - Parameters:
    ///     - user: the user which is making the request to get the meal info
    /// - Returns: none
    @MainActor
    func getMealInfo(for user: User) async throws {
        guard let userId = user.uid else {
//            print("Invalid user ID")
            return
        }

        let usageDocRef = db.collection("usages").document(userId)

        do {
            let document = try await usageDocRef.getDocument()
            var usage: Usage

            if document.exists {
                usage = try document.data(as: Usage.self) // No need for conditional binding
            } else {
                print("NOTE: Usage document does not exist. Creating a new usage document.")
                usage = Usage(uid: userId, lastUsageTimestamp: Date(), maxCalorieAPIUsageNumRemaining: 5, maxAssistantTokenNumRemaining: 5000)

                // Upload the new Usage document to Firestore
                try usageDocRef.setData(from: usage)
                print("NOTE: New usage document successfully created")
            }
            remainingEstimations = usage.maxCalorieAPIUsageNumRemaining ?? 0
            // Get the current timestamp
            let currentTimestamp = Date()
            let lastUsageTimestamp = usage.lastUsageTimestamp ?? Date.distantPast
            
            // Calculate the time interval between the last usage and now
            let timeInterval = currentTimestamp.timeIntervalSince(lastUsageTimestamp)
                
            // Check if 24 hours (86400 seconds) have passed
            if timeInterval >= 86400 {
                // Reset the usage counters
                usage.resetUsage(with: currentTimestamp)
                try usageDocRef.setData(from: usage)
            }

            // Now check remaining usage
            guard let remainingUses = usage.maxCalorieAPIUsageNumRemaining, remainingUses > 0 else {
                clearInputs()
                showUsageError = true
                return
            }

            // Get the meal information with predictions.
            await predictMealInfo(for: image!)

            // Decrement the remaining usage count if not showing error
            if showInputError == false && showEstimationError == false {
                usage.maxCalorieAPIUsageNumRemaining = remainingUses - 1
            }
            
            try usageDocRef.setData(from: usage)
            remainingEstimations = usage.maxCalorieAPIUsageNumRemaining ?? 0
        } catch {
            print("ERROR: Error decoding usage document: \(error)")
        }
    }
    
    
    /// This function handles the logic for checking the available usage and then getting the meal info for VIP users.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func getMealInfoVIP() async throws {
        do {
            await predictMealInfo(for: image!)
        }
    }
    
    
    /// This function handles the logic for requesting the food item information from the AI.
    /// - Parameters:
    ///     - for: the image of the food item
    /// - Returns: none
    @MainActor
    func predictMealInfo(for image: UIImage) async {
        isProcessingMealInfo = true
        do {
            print("NOTE: Prediction Started, please wait.")
            try await analyzeFoodImage(for: image)
        } catch {
            print("ERROR: Failed to predict meal info \n\(error.localizedDescription)\n")
        }
        isProcessingMealInfo = false
    }
    
    
    @MainActor
    func analyzeFoodImage(for image: UIImage) async throws {
        print("NOTE: Analyzing the food image...")

        // Step 1: Downsize the image
        let downsizedImg = ImageManipulation.downSizeImage(for: image)

        // Step 2: Upload the image and get the URL
        guard let imageUrl = try await FoodItemImageUploader.uploadImage(downsizedImg!) else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image to Firebase"])
        }

        // Step 3: Call the combined cloud function to analyze the image
        let result = try await functions.httpsCallable("analyzeFoodImage").call(["imageUrl": imageUrl])

        // Step 4: Handle the response
        if let data = result.data as? [String: Any],
           let isValid = data["valid"] as? Bool,
           let calories = data["calories"] as? String,
           let mealName = data["mealName"] as? String {
            
            // Step 5: Update the UI or variables based on the response
            await MainActor.run {
                // Validation result
                if isValid {
                    print("NOTE: Food is valid.")
                    imageChanged = true
                    print("CALORIES: \(calories as Any)")
                } else {
                    // clear input
                    print("NOTE: Food is invalid.")
                    clearInputs()
                    showInputError = true
                    return
                }

                // Calorie result
                let calorieString = "\(calories)"
                let calNum = extractNumber(from: calorieString)
                self.calories = calNum
                self.predictedCalories = calNum

                // Meal name result
                self.mealName = mealName
                print("NOTE: Predicted Meal Name: \(mealName)")
                
                if calories == "0" || !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: calories)) {
                    print("ERROR: Estimation error in analyzeFoodImage()")
                    self.calories = "0"
                    showEstimationError = true
                }
            }

        } else {
            throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response from the server"])
        }

        // Step 6: Clean up by deleting the image from Firebase
        try await ImageManipulation.deleteImageOnFirebase(imageURL: imageUrl)
    }

    
    
    /// This function saves the food item to Firebase.
    /// - Parameters:
    ///     - image: the image of the food item
    ///     - userId: the current user's id
    ///     - date: the date which the item will be saved to
    /// - Returns: none
    @MainActor
    func saveFoodItem(image: UIImage, userId: String, date: Date, completion: @escaping (Error?) -> Void) async throws {
        guard let imageUrl = try? await FoodItemImageUploader.uploadImage(image) else {
            print("ERROR: Failed to get imageURL! \nSource: saveFoodItem()\n")
            return
        }
        
        if selectedMealType == nil {
            selectedMealType = determineMealType()
        }
        
        let mealType = selectedMealType!
        print("NOTE: MealType is \(mealType). \nSource: MealInputViewModel/saveFoodItem()")
        checkForExistingMeal(userId: userId, mealType: mealType, date: date) { existingMeal in
            if let meal = existingMeal {
                self.createFoodItem(mealId: meal.id!, imageUrl: imageUrl, completion: completion)
                print("NOTE: Creating a new food item! \nSource: MealInputViewModel/saveFoodItem()")
            } else {
                self.createNewMeal(userId: userId, mealType: mealType, date: date) { newMealId in
                    if let mealId = newMealId {
                        self.createFoodItem(mealId: mealId, imageUrl: imageUrl, completion: completion)
                    } else {
                        completion(NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create meal"]))
                    }
                }
                print("NOTE: I am creating a new meal and food item!, \nSource: MealInputViewModel/saveFoodItem()")
            }
        }
        self.showMessageWindow = true
    }
    
    
    /// This function determines the meal type based on the current time.
    /// - Parameters: none
    /// - Returns: The string of the meal type.
    func determineMealType() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<10:
            return .breakfast
        case 11..<14:
            return .lunch
        case 17..<21:
            return .dinner
        default:
            return .snack
        }
    }
    
    
    /// This function checks if the  meal already exists for the current user and meal type. Ex.: If the user already have food items in breakfast, it means that the breakfast meal type already exists.
    /// - Parameters:
    ///     - userId: the current user's id
    ///     - mealType: the meal type to check for repetitiveness
    ///     - date: the date which the item will be checked against
    /// - Returns: none
    func checkForExistingMeal(userId: String, mealType: String, date: Date, completion: @escaping (Meal?) -> Void) {
        let calendar = Calendar.current
        let currentDate = date
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("meal")
            .whereField("userId", isEqualTo: userId)
            .whereField("mealType", isEqualTo: mealType)
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .whereField("date", isLessThan: endOfDay)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("ERROR: Failed to get documents: \(error) \nSource: MealInputViewModel/checkForExistingMeal()")
                    completion(nil)
                } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                    if let meal = try? documents.first?.data(as: Meal.self) {
                        completion(meal)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
    }
    
    
    /// This function creates a new meal on the Firebase.
    /// - Parameters:
    ///     - userId: the current user's id
    ///     - mealType: the meal type to create
    ///     - date: the date when you want your meal to be created
    /// - Returns: none
    func createNewMeal(userId: String, mealType: String, date: Date, completion: @escaping (String?) -> Void) {
        let meal = Meal(date: date, mealType: mealType, userId: userId)
//        print("Meal date is \(meal.date)")
//        print("Meal type is \(meal.mealType)")
        do {
            let newDocRef = try db.collection("meal").addDocument(from: meal)
            completion(newDocRef.documentID)
        } catch {
            print("ERROR: Failed to create new meal. \(error) \nSource: MealInputViewModel/createNewMeal()")
            completion(nil)
        }
    }
    
    
    /// This function creates a new food item on the Firebase.
    /// - Parameters:
    ///     - mealId: the meal id which this food item belongs to
    ///     - imageUrl: the food item's image url
    /// - Returns: none
    func createFoodItem(mealId: String, imageUrl: String, completion: @escaping (Error?) -> Void) {
        guard let calories = Int(self.calories ?? "0") else {
            completion(NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid calorie number"]))
            return
        }
        
        let foodItem = FoodItem(mealId: mealId, calorieNumber: Int(calories), foodName: self.mealName, imageURL: imageUrl, percentage: Int(self.sliderValue))
        do {
            let _ = try db.collection("foodItems").addDocument(from: foodItem)
            self.clearInputs()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    
    /// Calculate the calories based on the slider value picked by the user.
    /// - Parameters:none
    /// - Returns: none
    func calorieIntakePercentage() {
        self.calories = String(Int((Double(self.predictedCalories ?? "0") ?? 0) * self.sliderValue / 100))
    }
    
    
    /// This function is for clearing all user inputs on the MealInputView.
    /// - Parameters: none
    /// - Returns: none
    func clearInputs() {
        print("NOTE: Clearing Inputs")
        self.image = UIImage(resource: .addMeal)
        self.selectedDate = Date()
        self.imageChanged = false
        self.predictedCalories = nil
        self.sliderValue = 100.0
        self.calories = nil
        self.mealName = ""
        self.selectedMealType = nil
    }
    
    
}


