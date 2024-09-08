//
//  FoodItemEditView.swift
//  Project_DH
//
//  Created by mac on 2024/8/8.
//
// FoodItemEditView.swift
import SwiftUI
import Kingfisher

struct FoodItemEditView: View {
    @Binding var foodItem: FoodItem?
    @Binding var foodItemList: [FoodItem]
    @Binding var isPresented: Bool
    @Binding var calorieNum: Int
    var allItems: Bool
    var deletable: Bool
    @ObservedObject var viewModel: DashboardViewModel
    @State private var originalFoodName: String = ""
    @State private var originalCalorieNumber: Int = 0
    @State private var originalCalorieSum: Int = 0
    
    
    var body: some View {
        ZStack {
            // Background overlay to detect taps outside the card
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if let foodItem = foodItem {
                        // Reset to original values
                        foodItem.foodName = originalFoodName
                        foodItem.calorieNumber = originalCalorieNumber
                        calorieNum = originalCalorieSum
                    }
                    isPresented = false
                }

            // Card view
            if let foodItem = foodItem {
                VStack {
                    
                    KFImage(URL(string: foodItem.imageURL))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    TextField("Food Name", text: Binding(
                        get: { foodItem.foodName },
                        set: { foodItem.foodName = $0 }
                    ))
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundStyle(Color(.black).opacity(0.6))
                    .padding()

                    VStack() {
                        HStack {
                            Text("Calories:")
                            Spacer()
                            TextField("", value: Binding(
                                get: { foodItem.calorieNumber },
                                set: { newValue in
                                    viewModel.wholeFoodItem = false
                                    let difference = newValue - foodItem.calorieNumber
                                    calorieNum += difference
                                    foodItem.calorieNumber = newValue
                                }
                            ), formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                        }
                        .foregroundStyle(Color(.black).opacity(0.6))
                        
                        Toggle("Set as 100% finished:", isOn: $viewModel.wholeFoodItem)
                            .toggleStyle(SwitchToggleStyle(tint: .brandDarkGreen))
                            .foregroundStyle(Color(.black).opacity(0.6))
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                    
                    if deletable {
                        Button {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            deleteFoodItemFoodItemEditView(foodItemList: foodItemList, foodItem: foodItem)
                            isPresented = false
                        } label: {
                            Text("Delete Food")
                                .font(.headline)
                            
                        }
                        .frame(maxWidth: 200, minHeight: 40)
                        .background(Color(.brandRed).opacity(0.3))
                        .foregroundColor(Color(.brandRed))
                        .cornerRadius(8)
                    }

                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        isPresented = false
                        Task {
                            foodItem.percentageConsumed = calcNewPercentage(for: Double(originalCalorieNumber))
                            await viewModel.updateFoodItem(foodItem)
                            if allItems {
                                try await viewModel.fetchMeals(for: viewModel.profileViewModel.currentUser?.uid ?? "", with: false)
                            } else {
                                try await viewModel.fetchMeals(for: viewModel.profileViewModel.currentUser?.uid ?? "", with: true, on: viewModel.selectedDate)
                            }
                            viewModel.wholeFoodItem = false
                        }
                    } label: {
                        Text("Save")
                            .font(.headline)
                    }
                    .frame(maxWidth: 200, minHeight: 40)
                    .background(Color(.brandLightGreen).opacity(0.3))
                    .foregroundColor(.brandDarkGreen)
                    .cornerRadius(8)
                    .padding(.bottom, 5)
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 8)
                .frame(maxWidth: 300)
                .onAppear {
                    // Store the original values when the view appears
                    originalFoodName = foodItem.foodName
                    originalCalorieNumber = foodItem.calorieNumber
                    originalCalorieSum = calorieNum
                }
                .onTapGesture {
                    // Prevent tap propagation to the background
                }
            }
        }// End of ZStack
        .dismissKeyboardOnTap()
    }
    
    
    /// Calculates the new percentage of the consumed food item.
    /// - Parameters: 
    ///     - for calNum:  The original calorie number of the food item before modification.
    /// - Returns: The percentage calculated.
    func calcNewPercentage(for calNum: Double) -> Int {
        guard let foodItem = foodItem, foodItem.percentageConsumed != 0 else {
            return 0 // Return 0 or any appropriate default value if percentageConsumed is 0 or foodItem is nil.
        }
        let originalCalories = Double(calNum) / (Double(foodItem.percentageConsumed!)/100)
        let percentage = Double(foodItem.calorieNumber) / originalCalories * 100
        if percentage > 100 || viewModel.wholeFoodItem {
            return 100
        }
        return Int(round(percentage))
    }
    
    
    /// This function classifies each fetched food item by calling the fetchFoodItems function.
    /// - Parameters:
    ///     - foodItem: The food item to delete.
    /// - Returns: none
    func deleteFoodItemFoodItemEditView(foodItemList: [FoodItem], foodItem: FoodItem) {
        let imageUrl = foodItem.imageURL
        viewModel.allFoodItems = viewModel.deleteFoodItem(foodItems: foodItemList, item: foodItem)
        
        Task {
            do {
                try await ImageManipulation.deleteImageOnFirebase(imageURL: imageUrl)
            } catch {
                print("ERROR: Error deleting image. \nSource: MealSectionView/deleteFoodItem()")
            }
        }
        
        // Check if this was the only item with the same mealId
        let remainingItemsWithSameMealId = foodItemList.filter { $0.mealId == foodItem.mealId }
        if remainingItemsWithSameMealId.isEmpty {
            print("NOTE: Deleting the meal, because there is no more food items.")
            viewModel.deleteMeal(mealID: foodItem.mealId)
        }
    }
    
    
}

#Preview {
    struct Preview: View {
        @State var foodItem: FoodItem? = FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150", percentage: 100)
        @State var foodItemList: [FoodItem] = [FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150", percentage: 100), FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150", percentage: 100)]
        @State var isPresented = true
        @State var calorieNum = 100
        var viewModel = DashboardViewModel()


        var body: some View {
            FoodItemEditView(foodItem: $foodItem, foodItemList: $foodItemList, isPresented: $isPresented, calorieNum: $calorieNum, allItems: false, deletable: true, viewModel: viewModel)
        }
    }
    return Preview()
}
