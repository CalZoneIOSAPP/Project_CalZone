//
//  TopCalorieFoodView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/13/24.
//

import SwiftUI
import Kingfisher

struct TopCalorieFoodView: View {
    @Binding var foodItem: FoodItem?
    @Binding var user: User?
    @State var isWeek: Bool
    
    @State private var consumptionDate: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text(textToPresent)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color(.black).opacity(0.7))
                    .padding(.leading, 8)
                Spacer()
            }

            
            // MVP Food of the week
            HStack {
                if let foodItem = foodItem {
                    // Show MVP Food
                    VStack {
                        Text(foodItem.foodName)
                            .font(.headline)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                        Spacer()
                        
                        HStack {
                            Text(NSLocalizedString("Calories: ", comment: "") + "\(foodItem.calorieNumber)")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                            Spacer()
                        }
                        .padding(.bottom, 15)
                        
                        HStack {
                            Text(NSLocalizedString("Consumed on: ", comment: "") + "\n\(consumptionDate)")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .frame(width: 150)
                    .onAppear {
                        if let uid = user?.uid {
                            Task {
                                let topCalorieMeal = try await MealServices().fetchMeal(by: foodItem.mealId, for: uid)
                                consumptionDate = DateTools().formattedDate(topCalorieMeal?.date ?? Date())
                            }
                           
                        }
                        
                    }
                    
                    Spacer()
                    
                    KFImage(URL(string: foodItem.imageURL))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 200, maxHeight: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                } else {
                    VStack {
                        Text("No dishes found this week...")
                            .font(.headline)
                            .foregroundStyle(.gray)
                            .padding(.top, 10)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Image("noMeal")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(0.6)
                        .frame(maxWidth: 200, maxHeight: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.all, 10)
            .frame(maxHeight: 300)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
        } // End of VStack
        
        .padding(.horizontal)
    } // End of Body
    
    
    /// This function use to choose the right text to display
    /// - Parameters:
    ///     - none
    /// - Returns: String: the right text
    private var textToPresent: String {
        if isWeek {
           return NSLocalizedString("Calorie Bomb of the Week", comment: "")
        }
        return NSLocalizedString("Calorie Bomb of the Month", comment: "")
    }
}

#Preview {
    struct Preview: View {
        @State var foodItem: FoodItem? = FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple Apple Apple Apple", imageURL: "Cloud", percentage: 100)
        
        var body: some View {
            TopCalorieFoodView(foodItem: $foodItem, user: .constant(User(email: "adminjimmy@gmail.com")), isWeek: false)
        }
    }
    return Preview()
}
