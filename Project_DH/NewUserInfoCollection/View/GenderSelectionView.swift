//
//  GenderSelectionView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/3/24.
//

import SwiftUI

struct GenderSelectionView: View {
    @EnvironmentObject var viewModel: InfoCollectionViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                // Description
                Text("Complete the evaluation and generate a dedicated plan for you.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                // Progress bar
                ProgressView(value: (1.0/6.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: .brandDarkGreen))
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                Spacer()
                
                // Question
                Text("What is your biological gender?")
                    .font(.title2)
                    .padding(.top, 20)
                
                Text("Biological gender can affect how our bodies metabolize.")
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
                            viewModel.gender = NSLocalizedString("female", comment: "")
                        }) {
                            VStack {
                                Image("femaleIcon")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .padding()
                                    .background(.brandDarkGreen.opacity(viewModel.gender == NSLocalizedString("female", comment: "") ? 0.5 : 0.2))
                                    .clipShape(Circle())
                                Text("Female")
                                    .font(.title3)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    
                    VStack {
                        Button(action: {
                            viewModel.gender = NSLocalizedString("male", comment: "")
                        }) {
                            VStack {
                                Image("maleIcon")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .padding()
                                    .background(.brandDarkGreen.opacity(viewModel.gender == NSLocalizedString("male", comment: "") ? 0.5 : 0.2))
                                    .clipShape(Circle())
                                Text("Male")
                                    .font(.title3)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
                
                Spacer()
                
                NavigationLink(destination: HeightSelectionView(isShowing: $isShowing)) {
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

        }// End of NavigationStack

    }
}
#Preview {
    GenderSelectionView(isShowing: .constant(true))
}
