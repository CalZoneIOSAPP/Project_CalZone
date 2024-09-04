//
//  TargetWeightView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/4/24.
//

import SwiftUI

struct TargetWeightView: View {
    @EnvironmentObject var viewModel: InfoCollectionViewModel
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Subtitle
                Text("完成评测，为你生成专属方案")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ProgressView(value: 0.6)
                    .progressViewStyle(LinearProgressViewStyle(tint: .brandDarkGreen))
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                Spacer()
                
                // Target Weight Input Section
                VStack(spacing: 20) {
                    Text("你的目标体重是？")
                        .font(.title2)
                        .padding(.bottom, 20)
                    
                    Image(.targetIcon)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                    
                    // Target Weight Slider
                    HStack {
                        Text("40")
                            .foregroundColor(.gray)
                        Slider(value: $viewModel.targetWeight, in: 40...90, step: 0.1)
                        Text("90")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    Text(String(format: "%.1f 公斤", viewModel.targetWeight))
                        .font(.largeTitle)
                        .bold()
                }
                
                // Motivational Text Section
                VStack(spacing: 10) {
                    Text("将减重 9%！相信你可以 💪，我们会陪你一起加油！")
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
        } // NavigationStack

    }
}

#Preview {
    TargetWeightView(isShowing: .constant(true))
}
