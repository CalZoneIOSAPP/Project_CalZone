//
//  MealOverviewView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/7/24.
//

import SwiftUI

struct MealOverviewView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = DashboardViewModel()
    var globalFx = GlobalFx()
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Text("Total Dishes: \(viewModel.allFoodItems.count)")
                                .font(.title3)
                                .foregroundStyle(Color(.black).opacity(0.7))
                                .bold()
                            Text("Total Calories: \(viewModel.totalCaloriesInFoodList) kCal")
                                .font(.headline)
                                .foregroundStyle(Color.black.opacity(0.7))
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(height: 100)
                    .background(
                        Image("Cloud")
                            .resizable()
                            .scaledToFill()
                    )
                    .cornerRadius(15)
                    .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 5)
                    .padding(.horizontal, 10)
                    
                    ScrollView {
                        if !viewModel.allFoodItems.isEmpty {
                            ForEach(viewModel.allFoodItems, id: \.id) { food in
                                FoodCard(imageURL: food.imageURL, title: food.foodName, user: viewModel.profileViewModel.currentUser ?? User.MOCK_USER, likeCount: 0)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        viewModel.selectedFoodItem = food
                                        viewModel.showEditPopup = true
                                    }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            
                        } else {
                            VStack {
                                Spacer()
                                
                                Text("Start by adding a meal...")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding()
                                
                                Image("noMeal")
                                    .resizable()
                                    .frame(width: 250, height: 250)
                                    .padding(.bottom, 30)
                                    .clipShape(Circle())
                                    .opacity(0.5)
                                
                                Spacer()
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .navigationTitle("Meals")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.brandDarkGreen)
                                    .imageScale(.large)
                            }
                        }
                    }
                }
                .blur(radius: viewModel.showEditPopup ? 3 : 0)
                .disabled(viewModel.showEditPopup)
                .onAppear {
                    viewModel.fetchAllItems = true
                    print("NOTE: Fetching in Meal Overview On Appear.")
                    Task {
                        if let uid = viewModel.profileViewModel.currentUser?.uid {
                            try await viewModel.fetchMeals(for: uid, with: false)
                        }
                    }
                }
                .onChange(of: viewModel.allFoodItems) { _, newValue in
                    Task {
                        try await viewModel.totalCaloriesInFoodList = globalFx.getTotalCalories(for: newValue)
                    }
                }
                .disabled(viewModel.showEditPopup)
                
            } // End of NavigationStack
           
            if viewModel.showEditPopup {
                FoodItemEditView(viewModel: viewModel, foodItem: $viewModel.selectedFoodItem, foodItemList: $viewModel.allFoodItems, isPresented: $viewModel.showEditPopup, calorieNum: $viewModel.sumCalories, allItems: true, deletable: true)
            }
        }
        
    }
}

#Preview {
    MealOverviewView()
}
