//
//  StatsChartView.swift
//  Project_DH
//
//  Created by mac on 2024/9/1.
//

import SwiftUI
import Charts

struct StatsChartView: View {
    @State private var showingPopover = false
    @State private var selectedWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) ?? DateInterval()
    @State private var selectedMonth = Date()
    @Binding var user: User?
    @StateObject private var viewModel = StatsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            WeekSelectionView(selectedWeek: $selectedWeek, selectedMonth: $selectedMonth, showingPopover: $showingPopover, user: $user, viewModel: viewModel)
            .padding()
            
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Loading data...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack{
                        Text("Total Calories: \(viewModel.totalCalories)")
                            .font(.headline)
                        if isWeekView {
                            Text("Average Calories per day: \(viewModel.averageCalories)")
                                .font(.subheadline)
                        }
                        else {
                            Text("Average Calories per week: \(viewModel.averageCalories)")
                                .font(.subheadline)
                        }
                       
                    }
                    .padding()
                    .frame(width: 365)
                    .background(
                        Image("Cloud")
                            .resizable()
                            .scaledToFill()
                    )
                    .cornerRadius(15)
                    .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 5)
                    
                    PerformanceCardView(
                        weeklyData: viewModel.weeklyData,  // Pass your weekly data as [(String, Int)]
                        maxCalories: Int(user?.targetCalories ?? "5000") ?? 5000, // Handle the optional maxCalories
                        isWeekView: isWeekView
                    )
                    .padding()
                    
                    // MVP FOOD
                    TopCalorieFoodView(foodItem: $viewModel.topCalorieFood, user: $user)
                        .padding()
                }
                Spacer()
            } // End of Scroll View
            .navigationTitle("My Statistics")
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
                fetchDataForSelectedWeek()
                viewModel.fetchTopCalorieFoodForInterval(userId: user?.id, interval: selectedWeek)
            }
        } // End of NavigationStack
    }
    
    
    /// This function fetches data of food items for the selected week on current user
    /// - Parameters:
    ///     - none
    /// - Returns: none (will update the data in the viewModel)
    private func fetchDataForSelectedWeek() {
        guard let userId = user?.id else { return }
        viewModel.fetchCaloriesForWeek(userId: userId, weekInterval: selectedWeek)
    }
    
    /// This function format the date from MM/DD/YY to MM/DD for weekly data, DD for monthly data
    /// - Parameters:
    ///     - dataString: a string representing the date, for example 07/01/2024
    /// - Returns: dateString: a formatted date string
    private func formattedDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        // dateFormatter.dateFormat = "M/d/yy"
        dateFormatter.dateFormat = "yyyy/M/d"
        if let date = dateFormatter.date(from: dateString) {
            return isWeekView ? weekDateFormatter.string(from: date) : monthDateFormatter.string(from: date)
        } else {
            return dateString // Return the original if parsing fails
        }
    }
    
    /// This function define the date format for weekly view
    /// - Parameters:
    ///     - none
    /// - Returns: DateFormatter:  a date formatter for weekly view
    private var weekDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d" // Month/Day format
        return formatter
    }

    /// This function define the date format for monthly view
    /// - Parameters:
    ///     - none
    /// - Returns: DateFormatter:  a date formatter for monthly view
    private var monthDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }

    /// This function help to check whether the current view is weekly or monthly
    /// - Parameters:
    ///     - none
    /// - Returns: Bool:  true for weekly view, false for monthly view
    private var isWeekView: Bool {
        return viewModel.pickerMode == .week
    }
}

#Preview {
    StatsChartView(user: .constant(User(email: "adminjimmy@gmail.com", userName: "MockUserName", firstTimeUser: true)))
}
