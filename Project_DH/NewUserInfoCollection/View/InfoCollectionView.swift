//
//  InfoCollectionView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/3/24.
//

import SwiftUI

struct InfoCollectionView: View {
    @EnvironmentObject var viewModel: InfoCollectionViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var isShowing: Bool
    
    
    var discriptionText: String = "To better setup your goals, we need to calculate the calorie number based on your personal information. You are always welcome to skip and add your personal information later."
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Setting Up Your Profile")
                    .font(.title2)
                    .padding(.vertical, 30)
                
                Spacer()
                
                Text(self.discriptionText.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                
                Spacer()
                
                Image("womanfood")
                    .resizable()
                    .frame(width: 260, height: 260)
                    .padding()
                
                Spacer()
                
                NavigationLink(destination: GenderSelectionView(isShowing: $isShowing)) {
                    Image(systemName: "arrow.right")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.brandDarkGreen)
                        .padding()
                        .background(.brandLightGreen).opacity(0.8)
                        .clipShape(Circle())
                }
                .padding(.bottom, 60)

            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowing = false
                        Task {
                            try await UserServices.sharedUser.updateFirstTimeLogin()
                        }
                    }) {
                        Text("Skip")
                            .foregroundColor(.brandDarkGreen)
                    }
                }
            }
        }
    }
}

#Preview {
    InfoCollectionView(isShowing: .constant(true))
}
