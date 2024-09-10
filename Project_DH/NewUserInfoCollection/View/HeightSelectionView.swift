//
//  HeightSelectionView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/4/24.
//

import SwiftUI

struct HeightSelectionView: View {
    @EnvironmentObject var viewModel: InfoCollectionViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var isShowing: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Text("完成评测，为你生成专属方案")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Progress bar
                ProgressView(value: (2.0/6.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: .brandDarkGreen))
                    .padding(.horizontal)
                    .padding(.top, 10)

                Spacer()

                // Question text
                Text("你的身高是？")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                // Subtitle text
                Text("精准身高数据将用于计算你的BMI")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)

                // Ruler slider
                ZStack {
                    // Background ruler
                    Image("ruler") // replace with actual image if needed
                        .resizable()
                        .frame(width: 400, height: 300)
                    
                    // Interactive slider
                    Slider(value: $viewModel.height, in: 160...190, step: 1)
                        .tint(Color.brandDarkGreen)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 300, height: 80)
                        .padding(.trailing, 75)
                    
                    // Current height display
                    Text("\(Int(viewModel.height)) 厘米")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .offset(x: 110, y: 0)
                }
                .frame(height: 300)
                .padding(.bottom, 20)
                
                Spacer()

                NavigationLink(destination: WeightSelectionView(isShowing: $isShowing)) {
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
    HeightSelectionView(isShowing: .constant(true))
}
