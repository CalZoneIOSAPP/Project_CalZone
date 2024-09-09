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
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading data...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.totalCalories == 0 {
                    Text("No data available for the selected period.")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Total Calories: \(viewModel.totalCalories)")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    Text("Average Calories per day: \(viewModel.averageCalories)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                    
                    Chart {
                        ForEach(viewModel.weeklyData, id: \.0) { entry in
                            LineMark(
                                x: .value("Date", formattedDate(entry.0)),
                                y: .value("Calories", entry.1)
                            )
                            .foregroundStyle(.blue)
                            
                            BarMark(
                                x: .value("Date", formattedDate(entry.0)),
                                y: .value("Calories", entry.1)
                            )
                            .foregroundStyle(.green)
                            .annotation(position: .top) {
                                if entry.1 > 0 {
                                    Text("\(entry.1)")
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    .frame(height: 300)
                    .padding()
                }
                // Spacer() Uncomment this will pull the chart to the top
            }
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
                ToolbarItem(placement: .topBarTrailing) {
                    WeekSelectionView(selectedWeek: $selectedWeek, selectedMonth: $selectedMonth, showingPopover: $showingPopover, user: $user, viewModel: viewModel)
                }
            }
            .onAppear {
                fetchDataForSelectedWeek()
            }
        } // End of NavigationStack
    }
    
    
    private func fetchDataForSelectedWeek() {
        guard let userId = user?.id else { return }
        viewModel.fetchCaloriesForWeek(userId: userId, weekInterval: selectedWeek)
    }
    
    
    // Format the date using the "MM/dd" format
    private func formattedDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        if let date = dateFormatter.date(from: dateString) {
            return isWeekView ? weekDateFormatter.string(from: date) : monthDateFormatter.string(from: date)
        } else {
            return dateString // Return the original if parsing fails
        }
    }
    
    // Date format for weekly view (MM/dd)
    private var weekDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd" // Month/Day format
        
        return formatter
    }

    // Date format for monthly view (dd)
    private var monthDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd" // Day format
        return formatter
    }

    // Helper to check whether the current view is weekly or monthly
    private var isWeekView: Bool {
        return viewModel.pickerMode == .week
    }
}

#Preview {
    StatsChartView(user: .constant(User(email: "adminjimmy@gmail.com", userName: "MockUserName", firstTimeUser: true)))
}
