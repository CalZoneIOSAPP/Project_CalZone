//
//  StatsViewModel.swift
//  Project_DH
//
//  Created by mac on 2024/8/31.
//

import SwiftUI
import Combine
import Charts

// ViewModel to handle the fetching and processing of calorie data
class StatsViewModel: ObservableObject {
    @Published var selectedViewType: ViewType = .weekly {
        didSet {
            fetchPeriods()
        }
    }
    
    @Published var selectedPeriod: String = ""
    @Published var weeks: [String] = []
    @Published var months: [String] = []
    
    private var currentWeek: Int {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: Date())
        return weekOfYear
    }
    
    private var currentMonth: Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        return month
    }

    enum ViewType {
        case weekly, monthly
    }
    
    func fetchPeriods() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        switch selectedViewType {
        case .weekly:
            weeks = ["Week \(currentWeek - 1)", "Week \(currentWeek)"]
            selectedPeriod = "Week \(currentWeek)"
        case .monthly:
            months = (1...currentMonth).map { "Month \($0)" }
            selectedPeriod = "Month \(currentMonth)"
        }
    }

    func fetchCalorieData() {
        // Fetch and process the data for the selected period
    }
}

// Data model for the calorie data points
struct CalorieDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let calories: Int
}

