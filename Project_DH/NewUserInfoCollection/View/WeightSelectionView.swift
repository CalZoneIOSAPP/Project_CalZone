//
//  TargetSetupView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/4/24.
//

import SwiftUI

struct WeightSelectionView: View {
    @EnvironmentObject var viewModel: InfoCollectionViewModel
//    @StateObject var viewModel = InfoCollectionViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var isShowing: Bool
    
    @State private var config: WheelPicker.Config = .init(count: 180, steps: 10, spacing: 10, multiplier: 1)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Subtitle
                Text("Complete the evaluation and generate a dedicated plan for you.")
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
                    Text("What is your weight?")
                        .font(.title2)
                    
                    Text("Accurate height data will be used to calculate your BMI")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                        Text(verbatim: "\(viewModel.weight)")
                            .font(.largeTitle)
                            .bold()
                            .contentTransition(.numericText(value: viewModel.weight))
                            .animation(.snappy, value: viewModel.weight)
                        
                        Text(NSLocalizedString("Kg", comment: ""))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .textScale(.secondary)
                            .foregroundStyle(.gray)
                        
                    })
                    // Weight Slider
                    WheelPicker(config: config, value: $viewModel.weight)
                        .frame(height: 60)
                        .onChange(of: viewModel.weight) { _, newValue in
                            print(viewModel.weight)
                            viewModel.calculateBMI()
                        }
                    
                }
                .padding(.bottom, 30)
                
                // BMI Result Section
                VStack(spacing: 15) {
                    Text("Your BMI")
                        .font(.headline)
                    
                    // BMI Indicator
                    HStack {
                        Text("Thin")
                            .foregroundColor(viewModel.bmiLevel == NSLocalizedString("Thin", comment: "") ? .brandDarkGreen : .gray)
                        Spacer()
                        Text("Ideal")
                            .foregroundColor(viewModel.bmiLevel == NSLocalizedString("Ideal", comment: "") ? .brandDarkGreen : .gray)
                        Spacer()
                        Text("Overweight")
                            .foregroundColor(viewModel.bmiLevel == NSLocalizedString("Overweight", comment: "") ? .brandDarkGreen : .gray)
                        Spacer()
                        Text("Obese")
                            .foregroundColor(viewModel.bmiLevel == NSLocalizedString("Obese", comment: "") ? .brandDarkGreen : .gray)
                    }
                    .padding(.horizontal)
                    
                    // BMI Value
                    Text(LocalizedStringKey(String("\(viewModel.bmiValue) \(viewModel.bmiLevel)")))
                        .font(.title2)
                        .foregroundColor(viewModel.bmiLevel == NSLocalizedString("Thin", comment: "") ? .brandBlue :
                                         viewModel.bmiLevel == NSLocalizedString("Ideal", comment: "") ? .brandGreen:
                                         viewModel.bmiLevel == NSLocalizedString("Overweight", comment: "") ? .brandOrange : .brandRed)
                    
                    Text("For a standard weight, you should pay attention to improving metabolic levels. A 16:8 diet can be adopted in combination with exercise.")
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
    WeightSelectionView(isShowing: .constant(true))
}
