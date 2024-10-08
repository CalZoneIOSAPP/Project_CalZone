//
//  DateTools.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 8/22/24.
//

import Foundation
import SwiftUI


struct DateTools {
    /// Produce a DateFormatter object, with adjusted date and time style.
    /// - Parameters:
    ///     - none
    /// - Returns: A DateFormatter object.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()


    /// A function used to format date.
    /// - Parameters:
    ///     - _date: The date object.
    /// - Returns: String of the formatted date.
    func formattedDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    
    /// Returns the year component of  today's date.
    /// - Parameters:
    ///     - none
    /// - Returns: The number of year value.
    func getTodayYearComponent() -> Int {
        return Calendar.current.component(.year, from: Date())
    }
    
    
    /// Returns the month component of  today's date.
    /// - Parameters:
    ///     - none
    /// - Returns: The number of month value.
    func getTodayMonthComponent() -> Int {
        return Calendar.current.component(.month, from: Date())
    }
    
    
    /// Returns the day component of  today's date.
    /// - Parameters:
    ///     - none
    /// - Returns: The number of day value.
    func getTodayDayComponent() -> Int {
        return Calendar.current.component(.day, from: Date())
    }
    
    
    /// Checking if the specified date is in the past compared to the current date.
    /// - Parameters:
    ///     - date: The date to compare against.
    /// - Returns: If the date is in the past.
    func isDateInPast(_ date: Date) -> Bool {
        return date < Date()
    }
    
    
    /// Constructs a date object based on the year, month and day value.
    /// - Parameters:
    ///     - year: The numerical value of the year.
    ///     - month: The numerical value of the month.
    ///     - day: The numerical value of the day.
    /// - Returns: The date object of the requested date components.
    func constructDate(year: Int, month: Int, day: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        // Use the current calendar to create the date
        let calendar = Calendar.current
        var updatedCalendar = calendar
        updatedCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        return calendar.date(from: dateComponents)
    }
    
    
    /// Checks if the given day is today.
    /// - Parameters:
    ///     - date: The given date to compare.
    /// - Returns: If the date given is today's date.
    func isToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        
        // Extract only the year, month, and day components from the current and selected date
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        // Compare the components
        return todayComponents == selectedComponents
    }
    
    
}

