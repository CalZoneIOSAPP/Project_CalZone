//
//  TopCalorieFoodView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/13/24.
//

import SwiftUI

struct TopCalorieFoodView: View {
    var foodItem: FoodItem?
    
    var body: some View {
        VStack {
            HStack {
                Text("Calorie Bomb of the Week")
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
                    Image(systemName: "birthday.cake.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 120)
                    
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
        }
        .frame(maxHeight: 200)
        .padding(.horizontal)
    }
}

#Preview {
    TopCalorieFoodView()
}
