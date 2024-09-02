//
//  CalorieStatsView.swift
//  Project_DH
//
//  Created by mac on 2024/9/1.
//

import SwiftUI

struct CalorieStatsView: View {
    @State private var selectedPeriodType: PeriodType = .weekly
    @State private var selectedWeek: DateInterval = DateInterval(start: Date().startOfWeek(), end: Date().endOfWeek())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @Binding var showingPopover: Bool

    var weeks: [DateInterval] {
        // Generate the weeks for the picker (past 4 weeks + current week)
        var weeks = [DateInterval]()
        for i in 0...4 {
            let weekStart = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: Date().startOfWeek())!
            let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart)!
            weeks.append(DateInterval(start: weekStart, end: weekEnd))
        }
        return weeks
    }

    var months: [Int] {
        // Generate the months for the picker (January to current month)
        let currentMonth = Calendar.current.component(.month, from: Date())
        return Array(1...currentMonth)
    }

    var body: some View {
        Button(action: {
            showingPopover.toggle()
        }) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.brandDarkGreen)
            }
        }
        .sheet(isPresented: $showingPopover) {
            VStack {
                PeriodPickerView(selectedPeriodType: $selectedPeriodType, selectedWeek: $selectedWeek, selectedMonth: $selectedMonth, weeks: weeks, months: months)
                
                HStack {
                    Button("Cancel") {
                        showingPopover = false
                    }
                    .frame(width: 70)
                    .padding(10)
                    .background(Color.brandRed)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer().frame(width: 20)

                    Button("Done") {
                        showingPopover = false
                    }
                    .frame(width: 70)
                    .padding(10)
                    .background(Color.brandDarkGreen)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top)
            }
            .presentationDetents([.height(500)])
        }
    }
}

extension Date {
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        return weekStart
    }

    func endOfWeek() -> Date {
        let calendar = Calendar.current
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: self.startOfWeek())!
        return weekEnd
    }
}

#Preview {
    CalorieStatsView(showingPopover: .constant(true))
}
