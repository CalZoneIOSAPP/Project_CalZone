//
//  StatsCalendarView.swift
//  Project_DH
//
//  Created by mac on 2024/9/3.
//

import SwiftUI

struct WeekSelectionView: View {
    @Binding var selectedWeek: DateInterval
    @Binding var showingPopover: Bool
    @Binding var user: User?
    @ObservedObject var viewModel = StatsViewModel()

    var body: some View {
        Button(action: {
            showingPopover.toggle()
        }) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.brandDarkGreen)
                Text("Week of \(formattedDate(selectedWeek.start))")
                // Text("Week of \(formattedDate(selectedWeek.start)) - \(formattedDate(selectedWeek.end))")
            }
        }
        .sheet(isPresented: $showingPopover) {
            VStack {
                WeekPicker(selectedWeek: $selectedWeek)
                
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
                        print("selected week start from \(formattedDate(selectedWeek.start))")
                        print("selected week End from \(formattedDate(selectedWeek.end))")
                        if let uid = user?.uid {
                            viewModel.fetchCaloriesForWeek(userId: uid, weekInterval: selectedWeek)
                        }
                        print("data I shown on the chart is \(viewModel.weeklyData)")
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
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct WeekPicker: View {
    @Binding var selectedWeek: DateInterval

    var body: some View {
        DatePicker(
            "Select Week",
            selection: $selectedWeek.start,
            in: ...Date(),
            displayedComponents: [.date]
        )
        .datePickerStyle(GraphicalDatePickerStyle())
        .onChange(of: selectedWeek.start) { newStartDate in
            selectedWeek = Calendar.current.dateInterval(of: .weekOfYear, for: newStartDate) ?? DateInterval()
        }
        .padding()
    }
}

#Preview {
    WeekSelectionView(selectedWeek: .constant(DateInterval()), showingPopover: .constant(true), user: .constant(User(email: "adminjimmy@gmail.com")))
}
