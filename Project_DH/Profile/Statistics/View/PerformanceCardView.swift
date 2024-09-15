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
    @State private var animateValues: [Bool] = Array(repeating: false, count: 7)
    @State private var showValue: Bool = false
    
    var isWeekView: Bool // Pass this to determine date format
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title of the card
            HStack {
                Text("Calorie Consumption")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color(.black).opacity(0.7))
                    .padding(.leading, 8)
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(0..<weeklyData.count, id: \.self) { index in
                    let data = weeklyData[index]

                    VStack {
                        GeometryReader { geometry in
                            let height = geometry.size.height
                            let fillHeight = min((CGFloat(data.calories) / CGFloat(maxCalories)) * height, height)
                            let columnColor: Color = data.calories > maxCalories ? Color(.brandRed) : Color(.brandGreen).opacity(0.8)
                            
                            VStack {
                                Spacer()
                                
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundStyle(Color(.brandLightGreen).opacity(0.2))
                                        .frame(width: 30, height: 150)
                                        .overlay(
                                            // Add a black rounded corner border to the Rectangle
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color(.gray).opacity(0.2), lineWidth: 1) // Black border with rounded corners
                                        )
                                    
                                    Rectangle()
                                        .fill(columnColor)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.gray.opacity(0.2)) // Gray background
                                        )
                                        .frame(height: animateValues[index] ? fillHeight : 0) // Animate height
                                        .frame(width: 29)
                                        .cornerRadius(4)
                                        .onTapGesture {
                                            selectedDay = data.day
                                            selectedCalories = data.calories
                                            showValue = true
                                            // Set a timer to hide the value after 2 seconds
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                withAnimation {
                                                    showValue = false
                                                }
                                            }
                                        }
                                        .onAppear {
                                            // Animate with delay based on index
                                            withAnimation(.easeInOut(duration: 0.8).delay(Double(index) * 0.1)) {
                                                animateValues[index] = true
                                            }
                                        }
                                        .overlay(
                                            // Show the calorie number in a RoundedRectangle if tapped
                                            Group {
                                                if selectedDay == data.day && showValue {
                                                    VStack {
                                                        Text("\(data.calories)")
                                                            .font(.caption)
                                                            .lineLimit(1)
                                                            .padding(5)
                                                            .frame(width: 50)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 10)
                                                                    .fill(Color.white)
                                                                    .shadow(radius: 3)
                                                            )
                                                            .offset(y: -40) // Adjust position above the bar
                                                            .transition(.opacity) // Add fade transition
                                                            
                                                    }
                                                   
                                                }
                                            }
                                        )
                                } // ZStack with Rectangular bars
                                
                                Text("\(formatDateString(data.day))") // Format the date
                                    .font(.caption)
                                    .bold()
                                    .frame(width: 50, alignment: .center)
                                    .lineLimit(1) // Ensure the date is shown on one line
                            }
                            .frame(height: height)
                        }
                        .frame(height: 150) // Fixed height for all bars
                        
                        
                    }
                    .frame(height: 200) // Fixed height for all bars
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
    }
    
    /// This function format the date from MM/DD/YY to MM/DD for weekly data, DD for monthly data
    /// - Parameters:
    ///     - dataString: a string representing the date, for example 07/01/2024
    /// - Returns: dateString: a formatted date string
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
    
    /// This function define the date format for weekly view
    /// - Parameters:
    ///     - none
    /// - Returns: DateFormatter:  a date formatter for weekly view
    private var weekDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
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
}

// Preview for testing
struct PerformanceCardView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceCardView(
            weeklyData: [
                ("9/1", 1500),
                ("9/2", 0),
                ("9/3", 2000),
                ("9/4", 2500),
                ("9/5", 1800),
                ("9/6", 100),
                ("9/7", 500),
            ],
            maxCalories: 2200,
            isWeekView: false // Change to false for monthly view
        )
    }
}
