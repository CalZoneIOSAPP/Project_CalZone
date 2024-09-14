//
//  CollectionDoneView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/4/24.
//

import SwiftUI

struct CollectionDoneView: View {
    @EnvironmentObject var viewModel: InfoCollectionViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 20) {
                    Text("Congratulations, we know you better!")
                        .font(.title2)
                    
                    Text("Accurate height data will be used to calculate your BMI")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    Image(viewModel.gender == NSLocalizedString("male", comment: "") ? "maleIcon" : "femaleIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .padding()
                        .background(.brandDarkGreen.opacity(0.2))
                        .clipShape(Circle())
                    Text(viewModel.gender == NSLocalizedString("male", comment: "") ? NSLocalizedString("Male", comment: "") : NSLocalizedString("Female", comment: ""))
                        .font(.title3)
                        .foregroundColor(.black)
                }
                
                // BMI Result Section
                VStack(spacing: 15) {
                    Text("Based on your information, we calculated the recommended calorie number.")
                        .font(.headline)
                    
                    // BMI Value
                    Text("\(viewModel.calories) kCal")
                        .font(.title2)
                        .foregroundColor(.brandDarkGreen)
                        .onAppear {
                            viewModel.calculateTargetCalories()
                        }
                    
                    Text("This calorie recommendation will vary depending on your daily energy consumption. You can also change it after entering the application.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .frame(maxHeight: 300)
                
                Text("Do you wish to save your personal information?")
                    .font(.title2)
                    .foregroundColor(.brandDarkGreen)
                    
                
                // Gender Selection
                HStack(spacing: 50) {
                    VStack {
                        Button(action: {
                            viewModel.saveSelected = true
                        }) {
                            Text("Save (Recommended)")
                                .foregroundColor(.brandDarkGreen)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.brandLightGreen)
                                .cornerRadius(12)
                                .opacity(viewModel.saveSelected ? 1 : 0.5)
                        }
                    }
                    VStack {
                        Button(action: {
                            viewModel.saveSelected = false
                        }) {
                            Text("Don't Save")
                                .foregroundColor(.brandDarkGreen)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.brandLightGreen)
                                .cornerRadius(12)
                                .opacity(viewModel.saveSelected ? 0.5 : 1)
                        }
                    }
                }
                .padding(.horizontal, 25)
                
                Text("You will not be able to enjoy the full functionality of the app unless you save your data.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                
                Spacer()
                
                // Next Button
                Button(action: {
                    isShowing = false
                    Task {
                        try await UserServices.sharedUser.updateFirstTimeLogin()
                        if viewModel.saveSelected {
                            try await viewModel.saveInfoToUser()
                        }
                    }
                }) {
                    Text("Start Your Journey")
                        .foregroundColor(.brandDarkGreen)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.brandLightGreen)
                        .cornerRadius(12)
                }
                .padding(.bottom, 30)
                .padding(.horizontal, 40)
            }
            .background(.brandBackgroundGreen)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(.brandDarkGreen)
                        }
                    }
                }
            } // End of toolbar
        } // NavigationStack
    }
}

#Preview {
    CollectionDoneView(isShowing: .constant(true))
}
