//
//  SportStatusView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/5/24.
//


//Sedentary (little or no exercise): BMR × 1.2
//Lightly active (light exercise/sports 1-3 days/week): BMR × 1.375
//Moderately active (moderate exercise/sports 3-5 days/week): BMR × 1.55
//Very active (hard exercise/sports 6-7 days a week): BMR × 1.725
//Super active (very hard exercise, physical job, or training twice a day): BMR × 1.9

import SwiftUI


struct ActivityLevelView: View {
    @EnvironmentObject var viewModel: InfoCollectionViewModel
//    @StateObject var viewModel = InfoCollectionViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("完成评测，为你生成专属方案")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Progress bar
                ProgressView(value: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .brandDarkGreen))
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                
                Text("Activity affects calorie expenditure. Choose the option that best describes your day.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                

                
                Spacer()
                
                VStack(spacing: 16) {
                    ActivityLevelOption(title: "Sedentary", subtitle: "Sitting, e.g. an office worker", isSelected: viewModel.activityLevel == "Sedentary") {
                        viewModel.activityLevel = "Sedentary"
                    }
                    ActivityLevelOption(title: "Slightly active", subtitle: "Standing and light movement, e.g. teacher", isSelected: viewModel.activityLevel == "Slightly active") {
                        viewModel.activityLevel = "Slightly active"
                        print(viewModel.activityLevel)
                    }
                    ActivityLevelOption(title: "Moderately active", subtitle: "Walking and light movement, e.g. conductor", isSelected: viewModel.activityLevel == "Moderately active") {
                        viewModel.activityLevel = "Moderately active"
                        print(viewModel.activityLevel)
                    }
                    ActivityLevelOption(title: "Very active", subtitle: "Physical labor or active job, e.g. construction worker", isSelected: viewModel.activityLevel == "Very active") {
                        viewModel.activityLevel = "Very active"
                        print(viewModel.activityLevel)
                    }
                    ActivityLevelOption(title: "Super active", subtitle: "Your daily life is based of exercise, Very hard physical job, or training three times a day", isSelected: viewModel.activityLevel == "Super active") {
                        viewModel.activityLevel = "Super active"
                        print(viewModel.activityLevel)
                    }
                }
                
                Spacer()

                NavigationLink(destination: CollectionDoneView(isShowing: $isShowing)) {
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
            } // VStack
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
        } // Navigation Stack
        
    }
}

struct ActivityLevelOption: View {
    var title: String
    var subtitle: String
    var isSelected: Bool
    var onSelect: () -> Void

    var body: some View {
        Button(action: {
            onSelect()
        }) {
            VStack(alignment: .center) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? .brandLightGreen : .white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal, 20)
            
            
        }
        .buttonStyle(PlainButtonStyle()) // To avoid default button styles
    }
}

#Preview {
    ActivityLevelView(isShowing: .constant(true))
}
