//
//  StatsCalendarView.swift
//  Project_DH
//
//  Created by mac on 2024/9/3.
//

import SwiftUI

enum PickerMode {
    case week
    case month
}

struct WeekSelectionView: View {
    @Binding var selectedWeek: DateInterval
    @Binding var selectedMonth: Date
    @Binding var showingPopover: Bool
    @Binding var user: User?
    @ObservedObject var viewModel = StatsViewModel()
    
    @State private var pickerMode: PickerMode = .week

    var body: some View {
        Button(action: {
            showingPopover.toggle()
        }) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.brandDarkGreen)
                if pickerMode == .week {
                    Text("Week of \(formattedDate(selectedWeek.start, forPickerMode: .week))")
                } else {
                    Text("Month of \(formattedDate(selectedMonth, forPickerMode: .month))")
                }
            }
        }
        .sheet(isPresented: $showingPopover) {
            VStack{
                Picker("Select Mode", selection: $pickerMode) {
                    Text("Week").tag(PickerMode.week)
                    Text("Month").tag(PickerMode.month)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if pickerMode == .week {
                    WeekPicker(selectedWeek: $selectedWeek)
                } else {
                    MonthYearPickerView(selectedMonth: $selectedMonth)
                        .frame(minHeight: 365)
                }
                
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

                    Button(action: {
                        // Your closure code goes here
                        if pickerMode == .week {
                            if let uid = user?.uid {
                                viewModel.pickerMode = .week
                                viewModel.fetchCaloriesForWeek(userId: uid, weekInterval: selectedWeek)
                                viewModel.fetchTopCalorieFoodForInterval(userId: uid, interval: selectedWeek)
                            }
                        } else if pickerMode == .month {
                            selectedMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: selectedMonth)) ?? Date()
                            if let uid = user?.uid {
                                viewModel.pickerMode = .month
                                viewModel.fetchCaloriesForMonth(userId: uid, monthStart: selectedMonth)
                                if let monthInterval = dateIntervalForMonth(selectedMonth: selectedMonth) {
                                    viewModel.fetchTopCalorieFoodForInterval(userId: uid, interval: monthInterval)
                                }
                            }
                        }
                        showingPopover = false
                    }) {
                        Text("Done")
                            .frame(width: 70)
                            .padding(10)
                            .background(Color.brandDarkGreen)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.top)
            }
            .presentationDetents([.height(500)])
        }
    }
    
    
    /// This function format the date for the text shown aside of the calendar icon
    /// - Parameters:
    ///     - date: the date of the first day on selected week or month
    ///     - mode:   either it is monthly or weekly picker
    /// - Returns: string:  a formatted date string
    private func formattedDate(_ date: Date, forPickerMode mode: PickerMode) -> String {
        let formatter = DateFormatter()
        if mode == .week {
            formatter.dateStyle = .medium // Original for week
        } else {
            formatter.dateFormat = "MM/yy" // Custom format for month
        }
        return formatter.string(from: date)
    }
    
    
    /// This function generates the date interval for the month
    /// - Parameters:
    ///     - date: the date of the first day on selected month
    /// - Returns: DateInterval: DateInterval for that month
    private func dateIntervalForMonth(selectedMonth: Date) -> DateInterval? {
        let calendar = Calendar.current
        // Step 1: Get the start date of the month
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else {
            return nil
        }
        // Step 2: Get the end date of the month (last second of the last day)
        guard let range = calendar.range(of: .day, in: .month, for: startOfMonth),
              let endOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth) else {
            return nil
        }
        // Step 3: Create a DateInterval from the start to the end of the month
        let dateInterval = DateInterval(start: startOfMonth, end: endOfMonth)

        return dateInterval
    }
}


// A view for week picker only in StatsChartView Only
struct WeekPicker: View {
    @Binding var selectedWeek: DateInterval

    var body: some View {
        ScrollView {
            DatePicker(
                "Select Week",
                selection: $selectedWeek.start,
                in: ...Date(),
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .frame(minHeight: 100)
            .onChange(of: selectedWeek.start) { _, newStartDate in
                selectedWeek = Calendar.current.dateInterval(of: .weekOfYear, for: newStartDate) ?? DateInterval()
            }
        }
        .scrollIndicators(.hidden)
    }
}


#Preview {
    WeekSelectionView(
        selectedWeek: .constant(DateInterval()),
        selectedMonth: .constant(Date()),
        showingPopover: .constant(true),
        user: .constant(User(email: "adminjimmy@gmail.com"))
    )
}
