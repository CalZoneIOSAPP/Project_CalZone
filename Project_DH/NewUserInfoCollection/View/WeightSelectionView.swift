//
//  TargetSetupView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/4/24.
//

import SwiftUI

struct WeightSelectionView: View {
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
                    .padding(.top)
                
                ProgressView(value: (3.0/6.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: .brandDarkGreen))
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                Spacer()
                
                // Weight Input Section
                VStack(spacing: 20) {
                    Text("你的体重是？")
                        .font(.title2)
                    
                    Text("精确体重数据将用于计算你的BMI")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                    
                    // Weight Slider
                    HStack {
                        Text("30")
                            .foregroundColor(.gray)
                        Slider(value: $viewModel.weight, in: 30...120, step: 0.1)
                            .tint(.brandDarkGreen)
                            .onChange(of: viewModel.weight) { _, newValue in
                                viewModel.calculateBMI()
                            }
                        Text("120")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    Text(String(format: "%.1f 公斤", viewModel.weight))
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.bottom, 30)
                
                // BMI Result Section
                VStack(spacing: 15) {
                    Text("你的BMI")
                        .font(.headline)
                    
                    // BMI Indicator
                    HStack {
                        Text("偏瘦")
                            .foregroundColor(viewModel.bmiLevel == "偏瘦" ? .brandDarkGreen : .gray)
                        Spacer()
                        Text("理想")
                            .foregroundColor(viewModel.bmiLevel == "理想" ? .brandDarkGreen : .gray)
                        Spacer()
                        Text("偏胖")
                            .foregroundColor(viewModel.bmiLevel == "偏胖" ? .brandDarkGreen : .gray)
                        Spacer()
                        Text("肥胖")
                            .foregroundColor(viewModel.bmiLevel == "肥胖" ? .brandDarkGreen : .gray)
                    }
                    .padding(.horizontal)
                    
                    // BMI Value
                    Text(LocalizedStringKey(String("\(viewModel.bmiValue) \(viewModel.bmiLevel)")))
                        .font(.title2)
                        .foregroundColor(viewModel.bmiLevel == "偏瘦" ? .brandBlue :
                                         viewModel.bmiLevel == "理想" ? .brandGreen:
                                         viewModel.bmiLevel == "偏胖" ? .brandOrange : .brandRed)
                    
                    Text("标准体重，进阶管理需注意提升代谢水平，可采取16:8饮食法，配合运动。")
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
                
                NavigationLink(destination: TargetWeightView(isShowing: $isShowing)) {
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
    WeightSelectionView(isShowing: .constant(true))
}
