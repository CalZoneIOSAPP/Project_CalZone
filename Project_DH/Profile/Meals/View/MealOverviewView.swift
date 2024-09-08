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
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    if !viewModel.allFoodItems.isEmpty {
                        LazyVStack {
                            ForEach(viewModel.allFoodItems, id: \.id) { food in
                                FoodCard(imageURL: food.imageURL, title: food.foodName, user: viewModel.profileViewModel.currentUser ?? User.MOCK_USER, likeCount: 0)
                                    .onTapGesture {
                                        viewModel.selectedFoodItem = food
                                        viewModel.showEditPopup = true
                                    }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)

                        }
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
                .onAppear {
                    viewModel.fetchAllItems = true
                    print("NOTE: Fetching in Meal Overview On Appear.")
                    Task {
                        if let uid = viewModel.profileViewModel.currentUser?.uid {
                            try await viewModel.fetchMeals(for: uid, with: false)
                        }
                    }
                }
            } // End of NavigationStack
           
            if viewModel.showEditPopup {
                FoodItemEditView(foodItem: $viewModel.selectedFoodItem, foodItemList: $viewModel.allFoodItems, isPresented: $viewModel.showEditPopup, calorieNum: $viewModel.sumCalories, allItems: true, deletable: true, viewModel: viewModel)
            }
        }
        
    }
}

#Preview {
    MealOverviewView()
}
