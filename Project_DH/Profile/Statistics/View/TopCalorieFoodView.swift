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
                        Text(NSLocalizedString("Calories: ", comment: "") + "\(foodItem.calorieNumber)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    .padding(.leading, 2)
                    KFImage(URL(string: foodItem.imageURL))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                } else {
                    VStack {
                        Text("No dishes found this week...")
                            .font(.headline)
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                    .padding(.leading, 2)
                    
                    Spacer()
                    
                    Image(systemName: "birthday.cake.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 120)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
        } // End of VStack
        .frame(maxHeight: 200)
        .padding(.horizontal)
    } // End of Body
    
    
    /// This function use to choose the right text to display
    /// - Parameters:
    ///     - none
    /// - Returns: String: the right text
    private var textToPresent: String {
        if isWeek {
           return "Calorie Bomb of the Week"
        }
        return "Calorie Bomb of the Month"
    }
}

#Preview {
    struct Preview: View {
        @State var foodItem: FoodItem? = FoodItem(mealId: "1", calorieNumber: 200, foodName: "Apple", imageURL: "Cloud", percentage: 100)
        
        var body: some View {
            TopCalorieFoodView(foodItem: $foodItem, user: .constant(User(email: "adminjimmy@gmail.com")), isWeek: false)
        }
    }
    return Preview()
}
