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
                Text("Complete the evaluation and generate a dedicated plan for you.")
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
                    ActivityLevelOption(
                        title: NSLocalizedString("Sedentary", comment: "Activity level description"),
                        subtitle: NSLocalizedString("Sitting, e.g. an office worker", comment: "Activity level details"),
                        isSelected: viewModel.activityLevel == NSLocalizedString("Sedentary", comment: "")
                    ) {
                        viewModel.activityLevel = NSLocalizedString("Sedentary", comment: "")
                    }
                    
                    ActivityLevelOption(
                        title: NSLocalizedString("Slightly Active", comment: "Activity level description"),
                        subtitle: NSLocalizedString("Standing and light movement, e.g. teacher", comment: "Activity level details"),
                        isSelected: viewModel.activityLevel == NSLocalizedString("Slightly Active", comment: "")
                    ) {
                        viewModel.activityLevel = NSLocalizedString("Slightly Active", comment: "")
                    }
                    
                    ActivityLevelOption(
                        title: NSLocalizedString("Moderately Active", comment: "Activity level description"),
                        subtitle: NSLocalizedString("Walking and light movement, e.g. conductor", comment: "Activity level details"),
                        isSelected: viewModel.activityLevel == NSLocalizedString("Moderately Active", comment: "")
                    ) {
                        viewModel.activityLevel = NSLocalizedString("Moderately Active", comment: "")
                    }
                    
                    ActivityLevelOption(
                        title: NSLocalizedString("Very Active", comment: "Activity level description"),
                        subtitle: NSLocalizedString("Physical labor or active job, e.g. construction worker", comment: "Activity level details"),
                        isSelected: viewModel.activityLevel == NSLocalizedString("Very Active", comment: "")
                    ) {
                        viewModel.activityLevel = NSLocalizedString("Very Active", comment: "")
                    }
                    
                    ActivityLevelOption(
                        title: NSLocalizedString("Super Active", comment: "Activity level description"),
                        subtitle: NSLocalizedString("Your daily life is based on exercise, very hard physical job, or training three times a day", comment: "Activity level details"),
                        isSelected: viewModel.activityLevel == NSLocalizedString("Super Active", comment: "")
                    ) {
                        viewModel.activityLevel = NSLocalizedString("Super Active", comment: "")
                    }
                }

                
                Spacer()

                NavigationLink(destination: CollectionDoneView(isShowing: $isShowing)) {
                    Text("Next Step")
                        .font(.headline)
                        .foregroundColor(.brandDarkGreen)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.brandLightGreen)
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)
                .padding(.horizontal)
                .disabled(viewModel.activityLevel == "")
                .opacity(viewModel.activityLevel == "" ? 0.7 : 1)
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
