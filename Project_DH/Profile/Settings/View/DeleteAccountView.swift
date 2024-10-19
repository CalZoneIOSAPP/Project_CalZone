//
//  DeleteAccountView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 10/17/24.
//

import SwiftUI

struct DeleteAccountView: View {
    @EnvironmentObject var control: ControllerModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = DeleteAccountViewModel()
    @State private var showLoading = false
    @State private var errorMessage: String?
    @State private var returnToSignIn = false
    @State private var showPopup: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    if showLoading {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack {
                                    Image("sadFace")
                                        .resizable()
                                        .frame(width: 260, height: 260)
                                        .clipShape(Circle())
                                        .opacity(0.5)
                                    ProgressView("Deleting your account...")
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    } else {
                        ZStack {
                            VStack {
                                Spacer()
                                
                                // Sad face image
                                Image("sadFace")
                                    .resizable()
                                    .frame(width: 180, height: 180)
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
                                .padding(.horizontal, 30)
                                .padding(.bottom, 30)
                                
                                VStack {
                                    Text("Enter your password to delete the account.")
                                        .font(.body)
                                        .bold()
                                        .foregroundStyle(.brandRed)
                                        .padding(.horizontal, 20)
                                    HStack {
                                        Image(systemName: "key.horizontal")
                                            .padding(.leading, 10)
                                        SecureFieldView(text: $viewModel.password, placeholder: Text("password"))
                                            .padding(12)
                                    }
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.horizontal, 30)
                                }
                                
                                
                                Spacer()
                                
                                // Buttons
                                VStack {
                                    Button(action: {
                                        control.deletingAccount = false
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
                                        control.deletingAccount = true
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
                            .disabled(showPopup)
                            .blur(radius: showPopup ? 3 : 0)
                            .alert(isPresented: $viewModel.showConfirmation) {
                                Alert(
                                    title: Text("Are you sure?"),
                                    message: Text("You are about to delete your account."),
                                    primaryButton: .destructive(Text("Delete"), action: {
                                        showLoading = true
                                        Task {
                                            if viewModel.password == "" {
                                                (errorMessage, showLoading, returnToSignIn) = try await AuthServices.sharedAuth.deleteAccount()
                                            } else {
                                                (errorMessage, showLoading, returnToSignIn) = try await AuthServices.sharedAuth.deleteAccount(password: viewModel.password)
                                            }
                                            if let msg = errorMessage, msg != ""{
                                                showPopup = true
                                            }
                                        }
                                    }),
                                    secondaryButton: .cancel()
                                )
                            }
                            .navigationDestination(isPresented: $returnToSignIn) {
                                SignInView()
                                    .onAppear {
                                        showLoading = false
                                    }
                            }
                            
                            if showPopup {
                                PopUpMessageView(messageTitle: "Apologies", message: errorMessage!, popupPositivity: .informative, isPresented: $showPopup)
                                    .padding(.horizontal, 30)
                            }
                            
                        }
                        
                    }
                } // End of ZStack
            }
            .dismissKeyboardOnTap()
            
        } // End of Navigation Stack
    }
    
}

#Preview {
    DeleteAccountView()
}
