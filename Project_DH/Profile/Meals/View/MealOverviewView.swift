//
//  MealOverviewView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/7/24.
//

import SwiftUI

struct MealOverviewView: View {
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Meal View")
            }
            .navigationTitle("Meals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.brandDarkGreen)
                            .imageScale(.large)
                    }
                }
            }
        } // End of NavigationStack
    }
}

#Preview {
    MealOverviewView()
}
