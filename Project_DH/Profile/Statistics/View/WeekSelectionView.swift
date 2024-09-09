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
                            }
                        } else if pickerMode == .month {
                            selectedMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: selectedMonth)) ?? Date()
                            if let uid = user?.uid {
                                viewModel.pickerMode = .month
                                viewModel.fetchCaloriesForMonth(userId: uid, monthStart: selectedMonth)
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
    
    private func formattedDate(_ date: Date, forPickerMode mode: PickerMode) -> String {
        let formatter = DateFormatter()
        if mode == .week {
            formatter.dateStyle = .medium // Original for week
        } else {
            formatter.dateFormat = "MM/yy" // Custom format for month
        }
        return formatter.string(from: date)
    }
}

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
