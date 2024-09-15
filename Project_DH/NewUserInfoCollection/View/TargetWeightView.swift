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
    
    @State private var config: WheelPicker.Config = .init(count: 180, steps: 10, spacing: 10, multiplier: 1, indicatorThickness: 4, indicatorLength: 40)

    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                // Subtitle
                Text("Complete the evaluation and generate a dedicated plan for you.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ProgressView(value: (4.0/6.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: .brandDarkGreen))
                    .padding(.horizontal)
                
                Spacer()
                
                
                Text("What is your target weight?")
                    .font(.title2)
                
                // Target Weight Input Section
                ZStack {
                    
                    Image("rulerEmpty") // replace with actual image if needed
                        .resizable()
                        .scaledToFill()
                        .rotationEffect(.degrees(90))
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .offset(y: 20)
                    
                    VStack {
                        HStack(alignment: .lastTextBaseline, spacing: 5, content: {
                            Text(verbatim: "\(viewModel.weightTarget)")
                                .font(.largeTitle)
                                .bold()
                                .contentTransition(.numericText(value: viewModel.weightTarget))
                            
                            Text(NSLocalizedString("Kg", comment: ""))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .textScale(.secondary)
                                .foregroundStyle(.gray)
                            
                        })
                        // Weight Slider
                        WheelPicker(config: config, value: $viewModel.weightTarget)
                            .frame(width: 320, height: 80)
                            .onChange(of: viewModel.weightTarget) { _, newValue in
                                viewModel.calculatePercentWeightChange()
                                viewModel.getPercentChangeString()
                            }
                            .offset(y: -20)
                    }
                    
                }
                
                // Target Date Selection
                VStack(spacing: 5) {
                    Text("When would you like to achieve your goal?")
                        .font(.title2)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Date Picker (year, month, day)
                    HStack(alignment: .center, spacing: 30) {
                        Spacer()
                        Text("Year")
                        Spacer()
                        Text("Month")
                        Spacer()
                        Text("Day")
                        Spacer()
                    }
                    .font(.headline)
                    .foregroundStyle(.gray)
                    
                    HStack {
                        Picker(selection: $viewModel.targetYear, label: Text("")) {
                            ForEach(DateTools().getTodayYearComponent()...DateTools().getTodayYearComponent()+100, id: \.self) { year in
                                Text("\(year)").tag(year)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Picker(selection: $viewModel.targetMonth, label: Text("")) {
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)").tag(month)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .clipped()
                        
                        Picker(selection: $viewModel.targetDay, label: Text("")) {
                            ForEach(1...31, id: \.self) { day in
                                Text("\(day)").tag(day)
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
                    .frame(minHeight: 80)
                    
                }
                .padding()
                
                // Motivational Text Section
                VStack(spacing: 10) {
                    Text(viewModel.percentChanged == 0 ? "\(viewModel.weightStatus)" : "You will \(viewModel.weightStatus) \(viewModel.percentChanged)%！We believe you can make it. 💪 We will assist you to to achieve it.")
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
    TargetWeightView(isShowing: .constant(true))
}
