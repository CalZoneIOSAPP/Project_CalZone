//
//  HeightSelectionView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/4/24.
//

import SwiftUI

struct HeightSelectionView: View {
    @EnvironmentObject var viewModel: InfoCollectionViewModel
//    @StateObject var viewModel = InfoCollectionViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var isShowing: Bool
    
    @State private var config: WheelPicker.Config = .init(count: 40, steps: 5, spacing: 25, multiplier: 5, vertical: true, indicatorThickness: 4, indicatorLength: 75)

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
                
                Spacer()
                
                // Ruler slider
                ZStack {
                    Image("rulerEmpty") // replace with actual image if needed
                        .resizable()
                        .frame(width: 500, height: 400)
                        .offset(x:0)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                        Text(verbatim: "\(Int(viewModel.height))")
                            .font(.largeTitle)
                            .bold()
                            .contentTransition(.numericText(value: viewModel.height))
                            .animation(.snappy(duration: 0.1), value: viewModel.height)
                        
                        Text(NSLocalizedString("Cm", comment: ""))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .textScale(.secondary)
                            .foregroundStyle(.gray)
                        
                    })
                    .padding(.leading, 250)
                    // Weight Slider
                    WheelPicker(config: config, value: $viewModel.height)
                        .frame(width: 300, height: 250)
                }
                
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
