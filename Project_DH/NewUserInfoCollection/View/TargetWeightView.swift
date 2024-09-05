//
//  TargetWeightView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/4/24.
//

import SwiftUI

struct TargetWeightView: View {
    @EnvironmentObject var viewModel: InfoCollectionViewModel
//    @StateObject var viewModel = InfoCollectionViewModel() // For preview canvas only.
    @Environment(\.dismiss) private var dismiss
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Subtitle
                Text("完成评测，为你生成专属方案")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ProgressView(value: (4.0/6.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: .brandDarkGreen))
                    .padding(.horizontal)
                
                Spacer()
                
                // Target Weight Input Section
                VStack(spacing: 10) {
                    Text("你的目标体重是？")
                        .font(.title2)
                    
                    Image(.targetIcon)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    
                    // Target Weight Slider
                    HStack {
                        Text("30")
                            .foregroundColor(.gray)
                        Slider(value: $viewModel.targetWeight, in: 30...120, step: 0.1)
                            .tint(.brandDarkGreen)
                            .onChange(of: viewModel.targetWeight) { _, newValue in
                                viewModel.calculatePercentWeightChange()
                                viewModel.getPercentChangeString()
                            }
                        Text("120")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    Text(String(format: "%.1f 公斤", viewModel.targetWeight))
                        .font(.largeTitle)
                        .bold()
                }
                
                // Target Date Selection
                VStack(spacing: 5) {
                    Text("你想在哪一天到达目标体重?")
                        .font(.title2)
                        .foregroundColor(.black)
                    
                    // Date Picker (year, month, day)
                    HStack {
                        Picker(selection: $viewModel.targetYear, label: Text("")) {
                            ForEach(DateTools().getTodayYearComponent()...DateTools().getTodayYearComponent()+100, id: \.self) { year in
                                Text("\(year)年").tag(year)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Picker(selection: $viewModel.targetMonth, label: Text("")) {
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)月").tag(month)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .clipped()
                        
                        Picker(selection: $viewModel.targetDay, label: Text("")) {
                            ForEach(1...31, id: \.self) { day in
                                Text("\(day)日").tag(day)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: viewModel.targetMonth) { _, newValue in
                        viewModel.fixDate() // If the date selected is a past date, then return to the current day.
                    }
                    .onChange(of: viewModel.targetDay) { _, newValue in
                        viewModel.fixDate() // If the date selected is a past date, then return to the current day.
                    }
                    
                    
                }
                .padding()
                
                
                // Motivational Text Section
                VStack(spacing: 10) {
                    Text(viewModel.percentChanged == 0 ? "\(viewModel.weightStatus)" : "将\(viewModel.weightStatus) \(viewModel.percentChanged)%！相信您一定可以做到 💪，我们会陪您一起加油！")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                
                Spacer()
                
                NavigationLink(destination: BirthdaySelectionView(isShowing: $isShowing)) {
                    Text("下一步")
                        .font(.headline)
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
    TargetWeightView(isShowing: .constant(true))
}
