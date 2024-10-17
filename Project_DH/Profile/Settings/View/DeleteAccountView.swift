//
//  DeleteAccountView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 10/17/24.
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = DeleteAccountViewModel()
    @State private var showLoading = false
    @State private var errorMessage: String?
    @State private var returnToSignIn = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // Sad face image
                Image("sadFace")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .padding()
                
                // Sad message
                Text("We are sad to see you leave.")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                // Info text
                VStack(alignment: .leading, spacing: 10) {
                    Text("Be aware that:")
                    Text("1. Once your account is deleted, you will lose all your account information.")
                    Text("2. You can re-login with Google or Apple ID.")
                    Text("3. Account info is retrievable within 7 days for Google or Apple users.")
                    Text("4. For any assistance, contact us at: synapcompany@gmail.com")
                }
                .font(.body)
                .padding(.horizontal, 50)
                
                Spacer()
                
                // Buttons
                VStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("I DON’T WANT TO LEAVE")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.brandLightGreen)
                            .foregroundColor(.brandDarkGreen)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        viewModel.showConfirmation = true
                    }) {
                        Text("DELETE ACCOUNT")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.brandRed)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 10)
                
                Spacer()
            }
            .alert(isPresented: $viewModel.showConfirmation) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("You are about to delete your account."),
                    primaryButton: .destructive(Text("Delete"), action: {
                        (errorMessage, showLoading, returnToSignIn) = AuthServices.sharedAuth.deleteAccount()
                    }),
                    secondaryButton: .cancel()
                )
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(2)
                }
            }
            .navigationDestination(isPresented: $returnToSignIn) {
                
                SignInView()
            }
        }
    }
    
}

#Preview {
    DeleteAccountView()
}
