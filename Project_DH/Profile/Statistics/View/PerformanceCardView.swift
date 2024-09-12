//
//  PerformanceCardView.swift
//  Project_DH
//
//  Created by mac on 2024/9/11.
//


import SwiftUI

struct PerformanceCardView: View {
    let weeklyData: [(day: String, calories: Int)] // Use already formatted date strings
    let maxCalories: Int // Maximum calories for comparison
    
    @State private var selectedDay: String? = nil
    @State private var selectedCalories: Int? = nil
    
    var isWeekView: Bool // Pass this to determine date format
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title of the card
            Text("Performance")
                .font(.title2)
                .bold()
                .padding(.leading, 8)
            
            HStack(spacing: 8) {
                ForEach(weeklyData, id: \.day) { data in
                    VStack {
                        GeometryReader { geometry in
                            let height = geometry.size.height
                            let fillHeight = min((CGFloat(data.calories) / CGFloat(maxCalories)) * height, height)
                            let columnColor: Color = data.calories > maxCalories ? .red : .green
                            
                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(columnColor)
                                    .frame(height: fillHeight) // Dynamically adjust based on calories
                                    .cornerRadius(4)
                                    .onTapGesture {
                                        selectedDay = data.day
                                        selectedCalories = data.calories
                                    }
                            }
                            .frame(width: 30, height: height)
                        }
                        .frame(height: 100) // Fixed height for all bars
                        
                        // Weekday name under the column, centered
                        Text(formatDateString(data.day)) // Format the date
                            .font(.footnote)
                            .bold()
                            .frame(width: 30) // Same width as column to center it
                            .lineLimit(1) // Ensure the date is shown on one line
                            .minimumScaleFactor(0.7) // Scale down text if necessary
                            .offset(x: -6)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
            
        }
        .padding(.horizontal)
    }
    
    // Format the date string based on the view (weekly or monthly)
    private func formatDateString(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/M/d"
        if let date = dateFormatter.date(from: dateString) {
            // Format based on whether it's weekly or monthly view
            return isWeekView ? weekDateFormatter.string(from: date) : monthDateFormatter.string(from: date)
        } else {
            return dateString
        }
    }
    
    // Date format for weekly view (MM/dd)
    private var weekDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }
    
    // Date format for monthly view (dd)
    private var monthDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
}

// Preview for testing
struct PerformanceCardView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceCardView(
            weeklyData: [
                ("2024/9/1", 1500),
                ("2024/9/2", 1800),
                ("2024/9/3", 2200),
                ("2024/9/4", 2500),
                ("2024/9/5", 1800),
                ("2024/9/6", 1600),
                ("2024/9/7", 2000)
            ],
            maxCalories: 2200,
            isWeekView: true // Change to false for monthly view
        )
    }
}