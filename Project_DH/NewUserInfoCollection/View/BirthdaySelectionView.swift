//
//  BirthdaySelectionView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/4/24.
//

import SwiftUI

struct BirthdaySelectionView: View {
    @EnvironmentObject var viewModel: InfoCollectionViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Subtitle
                Text("完成评测，为你生成专属方案")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Progress bar
                ProgressView(value: (5.0/6.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: .brandDarkGreen))
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                
                // Birthday Section
                VStack(spacing: 20) {
                    Text("你的出生日期是?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    // Date Picker (year, month, day)
                    HStack {
                        Picker(selection: $viewModel.selectedYear, label: Text("")) {
                            ForEach(1997...2003, id: \.self) { year in
                                Text("\(year)年").tag(year)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .clipped()
                        
                        Picker(selection: $viewModel.selectedMonth, label: Text("")) {
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)月").tag(month)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .clipped()
                        
                        Picker(selection: $viewModel.selectedDay, label: Text("")) {
                            ForEach(1...31, id: \.self) { day in
                                Text("\(day)日").tag(day)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                    .onChange(of: viewModel.selectedYear, { _, newValue in
                        viewModel.calculateAge()
                    })
                    .onChange(of: viewModel.selectedMonth, { _, newValue in
                        viewModel.calculateAge()
                    })
                    .onChange(of: viewModel.selectedDay, { _, newValue in
                        viewModel.calculateAge()
                    })
                    .pickerStyle(WheelPickerStyle())
                }
                .padding()
                
                // Age and Description
                VStack {
                    Text("\(viewModel.age) 岁")
                        .font(.largeTitle)
                        .foregroundColor(.brandGreen)
                    
                    Text("基础代谢高、身体活动水平高，拥有体重管理的先天优势！")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
                
                NavigationLink(destination: ActivityLevelView(isShowing: $isShowing)) {
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
    BirthdaySelectionView(isShowing: .constant(true))
}
