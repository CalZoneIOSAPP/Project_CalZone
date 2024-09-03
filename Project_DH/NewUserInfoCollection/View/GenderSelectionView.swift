//
//  GenderSelectionView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/3/24.
//

import SwiftUI

struct GenderSelectionView: View {
    @State private var selectedGender: String? = nil
    
    var body: some View {
        VStack {
            // Title
            Text("评测")
                .font(.headline)
                .padding(.top)
            
            // Description
            Text("完成评测，为你生成专属方案")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 10)
            
            // Progress bar
            ProgressView(value: 0.2)
                .padding(.horizontal)
                .padding(.top, 10)
            
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
                        selectedGender = "female"
                    }) {
                        VStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .padding()
                                .background(Color.green.opacity(selectedGender == "female" ? 0.5 : 0.2))
                                .clipShape(Circle())
                            Text("女性")
                                .font(.title3)
                                .foregroundColor(.black)
                        }
                    }
                }
                
                VStack {
                    Button(action: {
                        selectedGender = "male"
                    }) {
                        VStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .padding()
                                .background(Color.green.opacity(selectedGender == "male" ? 0.5 : 0.2))
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
        }
        .background(Color(red: 0.89, green: 1.0, blue: 0.93))
        .ignoresSafeArea()
    }
}
#Preview {
    GenderSelectionView()
}
