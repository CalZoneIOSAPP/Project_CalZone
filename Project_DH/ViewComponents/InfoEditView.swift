//
//  InfoEditView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/12/24.
//

import SwiftUI

struct InfoEditView: View {
    @StateObject var viewModel = DashboardViewModel()
    @Binding var showWindow: Bool
    
    var body: some View {
        VStack {
            Text(NSLocalizedString("What is your current weight?", comment: ""))
                .font(.headline)
                .foregroundStyle(.gray)
                .padding(.top, 20)
            
            Spacer()
            
            TextField(NSLocalizedString("Enter your new weight", comment: ""), text: $viewModel.weightToEdit)
                .padding(.vertical, 12)
                .padding(.horizontal, 15)
                .keyboardType(.decimalPad)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal, 25)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    showWindow = false
                } label: {
                    Text("Cancel")
                }
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 130, height: 45)
                .background(.brandRed)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 30)
                .shadow(radius: 3)
                
                Spacer()
                
                Button {
                    Task {
                        try await UserServices.sharedUser.updateDietaryOptions(with: Double(viewModel.weightToEdit), enumInfo: .weight)
                        try await UserServices.sharedUser.fetchCurrentUserData()
                        try await viewModel.profileViewModel.calculateAndSaveTargetCalories()
                    }
                    showWindow = false
                } label: {
                    Text("Save")
                }
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 130, height: 45)
                .background(.brandDarkGreen)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 30)
                .shadow(radius: 3)
                
                Spacer()
            }
            .frame(height: 50)
            .padding(.bottom, 20)
            
        } // VStack
        .frame(height: 250)
        .background(.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
}

#Preview {
    InfoEditView(showWindow: .constant(true))
}
