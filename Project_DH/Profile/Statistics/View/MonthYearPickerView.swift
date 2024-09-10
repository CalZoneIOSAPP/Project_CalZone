//
//  MonthYearPickerView.swift
//  Project_DH
//
//  Created by mac on 2024/9/5.
//

import SwiftUI

struct MonthYearPickerView: UIViewRepresentable {
    @Binding var selectedMonth: Date

    // The list of months and years to display in the picker
    let months = Calendar.current.monthSymbols
    let currentYear = Calendar.current.component(.year, from: Date())
    let yearRange = Array(2000...2099) // Customize the range as needed

    // Create a Coordinator to manage picker interaction
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        let parent: MonthYearPickerView

        init(_ parent: MonthYearPickerView) {
            self.parent = parent
        }

        /// This function managers the components for the library
        /// - Parameters:
        ///     - pickerView: the selected UIPickerView
        /// - Returns: Indicator for month or year. One for months, one for years
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2
        }

        /// This function managers the pickerView of the picker, the library will handle this
        /// - Parameters:
        ///     - pickerView: the selected UIPickerView
        ///     - numberOfRowsInComponent: the number of
        /// - Returns: Indicator for month or year. One for months, one for years
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return component == 0 ? parent.months.count : parent.yearRange.count
        }

        /// This function managers the pickerView of the picker, the library will handle this
        /// - Parameters:
        ///     - pickerView: the selected UIPickerView
        ///     - titleForRow: the index of the row
        ///     - numberOfRowsInComponent: the number of
        /// - Returns: show months and year range
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return component == 0 ? parent.months[row] : "\(parent.yearRange[row])"
        }

        /// This function help updates the selected date when the user changes the picker value
        /// - Parameters:
        ///     - pickerView: the selected UIPickerView
        ///     - didSelectRow: the index of the row selected
        /// - Returns: none
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let selectedMonthRow = pickerView.selectedRow(inComponent: 0)
            let selectedYearRow = pickerView.selectedRow(inComponent: 1)

            let selectedMonth = selectedMonthRow + 1 // Since month is 1-based
            let selectedYear = parent.yearRange[selectedYearRow]

            // Set the selected date to the first day of the selected month
            let components = DateComponents(year: selectedYear, month: selectedMonth)
            if let date = Calendar.current.date(from: components) {
                parent.selectedMonth = date
            }
        }
    }

    /// This function manages the coordinate of the picker
    /// - Parameters:
    ///     - none
    /// - Returns: Coordinator
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    /// This function manages the UI view of the monthly picker, it is called inside of UIViewRepresentable library
    /// - Parameters:
    ///     - context: some Context
    /// - Returns: picker of the monthly UI
    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator

        // Set the default selected month and year based on the current selectedMonth
        let month = Calendar.current.component(.month, from: selectedMonth) - 1 // 0-based index
        let year = Calendar.current.component(.year, from: selectedMonth)

        if let yearIndex = yearRange.firstIndex(of: year) {
            picker.selectRow(month, inComponent: 0, animated: false)
            picker.selectRow(yearIndex, inComponent: 1, animated: false)
        }

        return picker
    }

    /// This function handle picker updates, no need for updates in this function as the picker will manage itself, but don't delete this function
    /// - Parameters:
    ///     - uiView: UIPickerView
    ///     - context: some context
    func updateUIView(_ uiView: UIPickerView, context: Context) {
    }
}

#Preview {
    MonthYearPickerView(selectedMonth: .constant(Date()))
}
