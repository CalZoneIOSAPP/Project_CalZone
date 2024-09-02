//
//  WeeklyStatsView.swift
//  Project_DH
//
//  Created by mac on 2024/8/31.
//
import SwiftUI

enum PeriodType: String, CaseIterable {
    case weekly = "按周查看"
    case monthly = "按月查看"
}

struct PeriodPickerView: View {
    @Binding var selectedPeriodType: PeriodType
    @Binding var selectedWeek: DateInterval
    @Binding var selectedMonth: Int

    let weeks: [DateInterval]
    let months: [Int]

    var body: some View {
        VStack {
            Picker("Period Type", selection: $selectedPeriodType) {
                ForEach(PeriodType.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedPeriodType == .weekly {
                Picker("Week", selection: $selectedWeek) {
                    ForEach(weeks, id: \.self) { week in
                        Text(weekFormatted(week: week)).tag(week)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()
            } else {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(months, id: \.self) { month in
                        Text(monthFormatted(month: month)).tag(month)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()
            }
        }
    }

    private func weekFormatted(week: DateInterval) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: week.start)
        let end = formatter.string(from: week.end)
        return "\(start) - \(end)"
    }

    private func monthFormatted(month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let monthName = formatter.monthSymbols[month - 1]
        return monthName
    }
}

#Preview {
    PeriodPickerView(
        selectedPeriodType: .constant(.monthly),
        selectedWeek: .constant(DateInterval(start: Date().startOfWeek(), end: Date().endOfWeek())),
        selectedMonth: .constant(8),  // Assuming the 8th month (August) for preview
        weeks: [
            DateInterval(start: Date().startOfWeek(), end: Date().endOfWeek()),
            DateInterval(start: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date().startOfWeek())!, end: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date().endOfWeek())!),
            DateInterval(start: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date().startOfWeek())!, end: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date().endOfWeek())!)
        ],
        months: Array(1...12)
    )
}
