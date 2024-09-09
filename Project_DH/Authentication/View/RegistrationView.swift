//
//  SignUpView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI
import AuthenticationServices


/// The major view for showing the registration page.
/// - Parameters:
///     - none
/// - Returns: none
struct RegistrationView: View {
    @StateObject var authViewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss

    
    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                VStack {
                    Image(.logo)
                        .resizable().scaledToFill()
                        .frame(width: 120, height: 120)
                        .padding(.vertical, 20)
                    
                    Text("get_started")
                        .font(.title2)
                        .padding(.bottom, 80)
                        .shadow(color: Color.black.opacity(0.1), radius: 2)
                    
                    // MARK: User Input Textfields
                    VStack{
                        HStack {
                            Image(systemName: "person")
                                .padding(.leading, 15)
                            TextField("username", text: $authViewModel.username)
                                .textInputAutocapitalization(.never)
                                .font(.subheadline)
                                .padding(12)
                        }
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 30)
                        .padding(.bottom, 10)
                        
                        HStack {
                            Image(systemName: "envelope")
                                .padding(.leading, 10)
                            TextField("email", text: $authViewModel.email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .font(.subheadline)
                                .padding(12)
                        }
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 30)
                        .padding(.bottom, 10)
                        
                        
                        HStack {
                            Image(systemName: "key.horizontal")
                                .padding(.leading, 10)
                            SecureFieldView(text: $authViewModel.password, placeholder: Text("password"))
                                .padding(12)
                        }
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 30)
                    }
                    
                    // MARK: ERROR MESSAGE
                    HStack {
                        authViewModel.alertItem?.message ?? Text(" ")
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundStyle(.brandRed)
                    .padding(.leading, 30)
                    .padding(.bottom, 5)
                    
                    HStack {
                        Image(systemName: "info.circle")
                        Text("password_requirement_length")
                            .font(.footnote)
                        Spacer()
                    }
                    .padding(.leading, 30)
                    
                    
                    //MARK: Privacy and Policy
                    VStack{
                        Toggle("privacy_policy_agreement", isOn: $authViewModel.privacy)
                            .toggleStyle(SwitchToggleStyle(tint: .brandDarkGreen))
                            .font(.custom("custom", size: 15))
                            .padding(.leading, 30)
                            .padding(.trailing, 40)
                        
                        Toggle("terms_agreement", isOn: $authViewModel.conditions)
                            .toggleStyle(SwitchToggleStyle(tint: .brandDarkGreen))
                            .font(.custom("custom", size: 15))
                            .padding(.leading, 30)
                            .padding(.trailing, 40)
                    }
                    .hidden()
                    
                    Spacer()
                    
                    // MARK: SIGN UP BUTTON
                    Button {
                        authViewModel.processingRegistration = true
                        Task{
                            defer {
                                authViewModel.processingRegistration = false
                            }
                            try await authViewModel.createUser()
                        }
                    }label: {
                        Text("sign_up")
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 310, height: 45)
                    .background(.brandDarkGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 30)
                    .shadow(radius: 3)
                    .disabled(authViewModel.processingRegistration)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .all)
            
            
        } // End of Navigation Stack
        .navigationBarBackButtonHidden()
        .dismissKeyboardOnTap()
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
    }
}

#Preview {
    RegistrationView()
}
