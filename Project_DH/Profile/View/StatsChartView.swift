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
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            
            VStack {
                Chart {
                    // Example Data
                    let data = [("08-26", 400), ("08-27", 0), ("08-28", 700), ("08-29", 800), ("08-30", 200), ("08-31", 100), ("09-01", 700)]
                    ForEach(data, id: \.0) { entry in
                        LineMark(
                            x: .value("Date", entry.0),
                            y: .value("Calories", entry.1)
                        )
                        .foregroundStyle(.blue)
                        
                        BarMark(
                            x: .value("Date", entry.0),
                            y: .value("Calories", entry.1)
                        )
                        .foregroundStyle(.green)
                    }
                }
                .frame(height: 300)
                
                // Spacer() Uncomment this will pull the chart to the top
            }
            .navigationTitle("My Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.green)
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CalorieStatsView(showingPopover: $showingPopover)
                }
            })
            
        }
    }
}

#Preview {
    StatsChartView()
}
