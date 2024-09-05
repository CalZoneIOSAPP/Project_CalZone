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
                    Text("恭喜，我们更了解您了！")
                        .font(.title2)
                    
                    Text("精确体重数据将用于计算你的BMI")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    Image(viewModel.gender == "male" ? "maleIcon" : "femaleIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .padding()
                        .background(.brandDarkGreen.opacity(0.2))
                        .clipShape(Circle())
                    Text(viewModel.gender == "male" ? "Male" : "Female")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                
                // BMI Result Section
                VStack(spacing: 15) {
                    Text("根据您的信息，我们为您计算出了推荐卡路里")
                        .font(.headline)
                    
                    // BMI Value
                    Text("\(viewModel.calories) kCal")
                        .font(.title2)
                        .foregroundColor(.brandDarkGreen)
                        .onAppear {
                            viewModel.calculateTargetCalories()
                        }
                    
                    Text("该卡路里只是推荐数量，根据您的日常体能消耗，将有所变动。您在进入APP后也可以自行更改")
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
                
                Text("是否保存您的信息？")
                    .font(.title2)
                    .foregroundColor(.brandDarkGreen)
                    
                
                // Gender Selection
                HStack(spacing: 50) {
                    VStack {
                        Button(action: {
                            viewModel.saveSelected = true
                        }) {
                            Text("保存(推荐)")
                                .foregroundColor(.brandDarkGreen)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.brandLightGreen)
                                .cornerRadius(10)
                                .opacity(viewModel.saveSelected ? 1 : 0.5)
                        }
                    }
                    VStack {
                        Button(action: {
                            viewModel.saveSelected = false
                        }) {
                            Text("不保存")
                                .foregroundColor(.brandDarkGreen)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.brandLightGreen)
                                .cornerRadius(10)
                                .opacity(viewModel.saveSelected ? 0.5 : 1)
                        }
                    }
                }
                .padding(.horizontal, 25)
                
                Text("不保存信息则无法享受完整的应用功能, 卡路里功能不受影响")
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
                    Text("开始美食之旅")
                        .foregroundColor(.brandDarkGreen)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.brandLightGreen)
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)
                .padding(.horizontal)
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
