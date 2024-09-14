//
//  MealSectionView.swift
//  Project_DH
//
//  Created by mac on 2024/7/31.
//

import SwiftUI
import Kingfisher


struct MealSectionView: View {
    @EnvironmentObject var control: ControllerModel
    @ObservedObject var viewModel = DashboardViewModel()
    var title: String
    @Binding var foodItems: [FoodItem]
    @Binding var calorieNum: Int
    @Binding var showEditPopup: Bool
    @Binding var selectedFoodItem: FoodItem?
    /// var selectedFoodItemId = ""
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.leading)
                .padding(.top, 20)
            
            List {
                ForEach(foodItems) { foodItem in
                    Button(action: {
                        // action here for selecting the food item
                        selectedFoodItem = foodItem
                        showEditPopup = true
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(foodItem.foodName)
                                    .font(.headline)
                                    .foregroundStyle(Color(.black).opacity(0.7))
                                    .lineLimit(2)
                                    .padding(.bottom, 4)
                                Text("Calories: \(foodItem.calorieNumber)")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(.black).opacity(0.7))
                            }
                            .padding(.trailing, 20)
                            
                            Spacer()
                            
                            // Food Percentage Eaten
                            Text("\(String(foodItem.percentageConsumed ?? 100))%")
                                .font(.subheadline)
                                .foregroundStyle(Color(.black).opacity(0.7))
                            
                            KFImage(URL(string: foodItem.imageURL))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                        }
                        .padding(.horizontal)
                        .frame(height: 80)
                    }
                    .padding(.vertical, 10)
                    .listRowInsets(EdgeInsets())
                    .swipeActions { // Swipe to delete
                        Button(role: .destructive) {
                            deleteFoodItem(foodItem: foodItem)
                        } label: {
                            Label(NSLocalizedString("Delete", comment: ""), systemImage: "trash.fill")
                        }
                        .tint(Color.brandRed)
                    }
                    .onDrag {
                        NSItemProvider(object: foodItem.id! as NSString)
                    }
                } // End of For each
                .onInsert(of: ["public.text"], perform: handleDrop)
                .listRowBackground(RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .padding(.vertical, 5))
                .listRowSeparator(.hidden)
            } // End of List View
            .frame(minHeight: CGFloat(foodItems.count) * 100 + 40) // Adjust height based on the number of items (each row + padding)
            .shadow(color: Color.black.opacity(0.15), radius: 5)
            .scrollContentBackground(.hidden)  // Hide default background
            .scrollDisabled(true) // Disable scrolling
            .padding(.top, -35)
            .padding(.bottom, 30)
        } // End of V Stack
        .background(LinearGradient(gradient: Gradient(colors: [Color.brandLightGreen, Color.brandTurquoise]), startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.4), radius: 5, x:0, y:2)
        .padding(.bottom, 40)
        .padding(.horizontal, 10)
        
    }
    
    
    /// This function handles the drop logic for food item
    /// - Parameters:
    ///     - index: The index of food item need to be drop
    ///     - itemProviders: used for indicating the item we are processing
    /// - Returns: A DateFormatter object.
    private func handleDrop(index: Int, itemProviders: [NSItemProvider]) {
        for provider in itemProviders {
            provider.loadObject(ofClass: NSString.self) { item, error in
                DispatchQueue.main.async {
                    if let foodItemId = item as? String {
                        Task {
                            print("I am moving food item to \(title)")
                            try await viewModel.moveFoodItem(to: title, foodItemId: foodItemId)
                        }
                    }
                }
            }
        }
    }
    
    
    /// This function classifies each fetched food item by calling the fetchFoodItems function.
    /// - Parameters:
    ///     - foodItem: The food item to delete.
    /// - Returns: none
    func deleteFoodItem(foodItem: FoodItem) {
        let imageUrl = foodItem.imageURL
        calorieNum -= foodItem.calorieNumber
        foodItems = viewModel.deleteFoodItem(foodItems: foodItems, item: foodItem)
        Task {
            do {
                try await ImageManipulation.deleteImageOnFirebase(imageURL: imageUrl)
            } catch {
                print("ERROR: Error deleting image. \nSource: MealSectionView/deleteFoodItem()")
            }
        }
        if foodItems.count == 0 {
            viewModel.deleteMeal(mealID: foodItem.mealId)
        }
        Task {
            try await viewModel.checkCalorieTarget()
        }
        
        control.refetchMeal = true
    }
    
    
}


#Preview {
    struct Preview: View {
            @State var calNum = 10
            @State var foodItems = [FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150", percentage: 100), FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150", percentage: 100),FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "https://via.placeholder.com/150", percentage: 100)]
            @State var showEditPopup = false
            @State var selectedFoodItem: FoodItem?

            var body: some View {
                MealSectionView(title: "Sample Meal", foodItems: $foodItems, calorieNum: $calNum, showEditPopup: $showEditPopup, selectedFoodItem: $selectedFoodItem)
            }
        }
        return Preview()
}
