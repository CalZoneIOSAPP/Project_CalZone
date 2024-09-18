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
    @State private var animateView = false // State to control animation
    
    var body: some View {
        VStack {
            HStack {
                Text(textToPresent)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.black).opacity(0.7))
                    .padding(.leading, 8)
                    .opacity(animateView ? 1 : 0) // Animation applied
                    .offset(y: animateView ? 0 : -10) // Slide in animation
                    .animation(.easeInOut(duration: 0.5), value: animateView)
                Spacer()
            }
            
            HStack {
                if let foodItem = foodItem {
                    // Show MVP Food with animation
                    VStack(alignment: .leading, spacing: 8) {
                        Text(foodItem.foodName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        
                        Text("Calories: \(foodItem.calorieNumber)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        
                        Text("Consumed on: \(consumptionDate)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                    }
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .frame(width: 140, height: 140) // Match size to image
                    .opacity(animateView ? 1 : 0)
                    .offset(x: animateView ? 0 : -20) // Slide in from left
                    .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateView)
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
                        .frame(width: 140, height: 140)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .shadow(radius: 10)
                        .opacity(animateView ? 1 : 0)
                        .offset(x: animateView ? 0 : 20) // Slide in from right
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateView) // Delayed animation
                } else {
                    VStack {
                        Text("No dishes found this week...")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    Image("noMeal")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 140)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .opacity(0.6)
                }
            }
            .padding(.all, 10)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
        .onAppear {
            withAnimation {
                animateView = true // Start animation when view appears
            }
        }
    }
    
    /// Choose the right text to display
    private var textToPresent: String {
        return isWeek ? NSLocalizedString("Calorie Bomb of the Week", comment: "") : NSLocalizedString("Calorie Bomb of the Month", comment: "") 
    }
}

#Preview {
    struct Preview: View {
        @State var foodItem: FoodItem? = FoodItem(mealId: "1", calorieNumber: 2000, foodName: "Triple Cheese Pizza", imageURL: "https://example.com/pizza.jpg", percentage: 100)
        
        var body: some View {
            TopCalorieFoodView(foodItem: $foodItem, user: .constant(User(email: "adminjimmy@gmail.com")), isWeek: true)
        }
    }
    return Preview()
}
