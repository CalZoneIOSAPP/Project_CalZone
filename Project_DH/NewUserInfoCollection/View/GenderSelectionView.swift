//
//  GenderSelectionView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/3/24.
//

import SwiftUI

struct GenderSelectionView: View {
    @EnvironmentObject var viewModel: InfoCollectionViewModel
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                // Description
                Text("完成评测，为你生成专属方案")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                // Progress bar
                ProgressView(value: 0.2)
                    .progressViewStyle(LinearProgressViewStyle(tint: .brandDarkGreen))
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                Spacer()
                
                // Question
                Text("你的性别是？")
                    .font(.title2)
                    .padding(.top, 20)
                
                Text("生理性别和激素会影响我们身体代谢食物的方式")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                
                Spacer()
                
                // Gender Selection
                HStack(spacing: 50) {
                    VStack {
                        Button(action: {
                            viewModel.gender = "female"
                        }) {
                            VStack {
                                Image("femaleIcon")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .padding()
                                    .background(.brandDarkGreen.opacity(viewModel.gender == "female" ? 0.5 : 0.2))
                                    .clipShape(Circle())
                                Text("女性")
                                    .font(.title3)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    
                    VStack {
                        Button(action: {
                            viewModel.gender = "male"
                        }) {
                            VStack {
                                Image("maleIcon")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .padding()
                                    .background(.brandDarkGreen.opacity(viewModel.gender == "male" ? 0.5 : 0.2))
                                    .clipShape(Circle())
                                Text("男性")
                                    .font(.title3)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
                
                Spacer()
                
                NavigationLink(destination: HeightSelectionView(isShowing: $isShowing)) {
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
        }// End of NavigationStack

    }
}
#Preview {
    GenderSelectionView(isShowing: .constant(true))
}
