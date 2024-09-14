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
                Text("Complete the evaluation and generate a dedicated plan for you.")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Progress bar
                ProgressView(value: (2.0/6.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: .brandDarkGreen))
                    .padding(.horizontal)
                    .padding(.top, 10)

                Spacer()

                // Question text
                Text("What is your height?")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                // Subtitle text
                Text("Accurate height data will be used to calculate your BMI")
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
                    Text("\(Int(viewModel.height)) CM")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .offset(x: 110, y: 0)
                }
                .frame(height: 300)
                .padding(.bottom, 20)
                
                Spacer()

                NavigationLink(destination: WeightSelectionView(isShowing: $isShowing)) {
                    Text("Next Step")
                        .font(.headline)
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
    HeightSelectionView(isShowing: .constant(true))
}
