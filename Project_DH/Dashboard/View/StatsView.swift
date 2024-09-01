//
//  WeeklyStatsView.swift
//  Project_DH
//
//  Created by mac on 2024/8/31.
//
import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel = StatsViewModel()

    var body: some View {
        VStack {
            // Picker for Weekly or Monthly
            Picker("View Type", selection: $viewModel.selectedViewType) {
                Text("Weekly").tag(StatsViewModel.ViewType.weekly)
                Text("Monthly").tag(StatsViewModel.ViewType.monthly)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Conditional Picker for Weeks or Months
            if viewModel.selectedViewType == .weekly {
                Picker("Select Week", selection: $viewModel.selectedPeriod) {
                    ForEach(viewModel.weeks, id: \.self) { week in
                        Text(week).tag(week)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()
            } else {
                Picker("Select Month", selection: $viewModel.selectedPeriod) {
                    ForEach(viewModel.months, id: \.self) { month in
                        Text(month).tag(month)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .padding()
            }

            // Button to Fetch Data
            Button(action: {
                viewModel.fetchCalorieData()
            }) {
                Text("Load Data")
            }
            .padding()

            // Placeholder for the chart (Replace with your chart view)
            Text("Chart Placeholder")
                .font(.largeTitle)
                .padding()
        }
    }
}

#Preview {
    StatsView(viewModel: StatsViewModel())
}
