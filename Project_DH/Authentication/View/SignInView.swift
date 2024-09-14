//
//  SignInView.swift
//  DH_App
//
//  Created by Yongxiang Jin on 3/10/24.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift


/// The major view for the sign in page.
/// - Parameters:
///     - none
/// - Returns: none
struct SignInView: View {
    @StateObject var authViewModel = SignInViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                VStack {
                    Image(.logo)
                        .resizable().scaledToFill()
                        .frame(width: 160, height: 160)
                        .padding(.vertical, 20)
                    
                    Text("welcome_back")
                        .font(.title2)
                        .foregroundStyle(.gray)
                        .shadow(color: Color.black.opacity(0.1), radius: 2)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "envelope")
                            .padding(.leading, 10)
                        TextField("email", text: $authViewModel.email)
                            .textContentType(.emailAddress)
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
//                        SecureField("password", text: $authViewModel.password)
//                            .textInputAutocapitalization(.never)
//                            .font(.subheadline)
//                            .padding(12)
                        SecureFieldView(text: $authViewModel.password, placeholder: Text("password"))
                            .padding(12)
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 30)
                    
                    
                    HStack { // ERROR MESSAGE
                        authViewModel.alertItem?.message ?? Text(" ")
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundStyle(.brandRed)
                    .padding(.leading, 30)
                    
                    
                    NavigationLink {
                        // TODO: Add a function to prompt user for an email if the password has been forgotten
                        ForgotPasswordView()
                    } label: {
                        Text("forgot_password")
                            .font(.footnote)
                            .foregroundStyle(.brandDarkGreen)
                            .fontWeight(.semibold)
                            .padding(.top)
                            .padding(.trailing, 28)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    // MARK: SIGN IN WITH EMAIL AND PASSWORD
                    Button {
                        authViewModel.processingSignIn = true
                        Task {
                            defer {
                                authViewModel.processingSignIn = false
                            }
                            try await authViewModel.login()
                        }
                    }label: {
                        Text("sign_in")
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 300, height: 45)
                    .background(.brandDarkGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.vertical)
                    .shadow(radius: 3)
                    .disabled(authViewModel.processingSignIn)
                    
                    dividerOr()
                    
                    // MARK: SIGN IN WITH APPLE
                    SignInWithAppleButton(.signIn) { request in
                        let nonce = authViewModel.randomNonceString()
                        authViewModel.nonce = nonce
                        request.requestedScopes = [.email, .fullName]
                        request.nonce = authViewModel.sha256(nonce)
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            Task {
                                authViewModel.processingSignIn = true
                                defer {
                                    authViewModel.processingSignIn = false
                                }
                                try await authViewModel.signInApple(authorization)
                            }
                        case .failure(let error):
                            print("FAILED SIGNING IN WITH APPLE \(error)")
                        }
                    }
                    .frame(width: 300, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 8)
                    .shadow(radius: 3)
                    .disabled(authViewModel.processingSignIn)
                    
                    // MARK: SIGN IN WITH GOOGLE
                    Button {
                        Task {
                            authViewModel.processingSignIn = true
                            defer {
                                authViewModel.processingSignIn = false
                            }
                            do {
                                try await authViewModel.signInGoogle()
                            } catch {
                                print(error)
                            }
                        }
                    }label: {
                        HStack(spacing: -5) {
                            Image(.googleLogo)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40)
                            Text("google_sign_in")
                                .font(.custom("googlefont", fixedSize: 17))
                                .foregroundStyle(Color(.systemGray))
                                
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 300, height: 45)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.bottom, 40)
                    .shadow(radius: 3)
                    .disabled(authViewModel.processingSignIn)

                    Spacer()
                    
                    Divider()
                    
                    HStack {
                        Text("no_account")
                        NavigationLink {
                            RegistrationView()
                        } label: {
                            Text("sign_up")
                                .foregroundStyle(.brandDarkGreen)
                        }
                    }
                    .font(.footnote)
                    .padding(.vertical)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .all)
            .dismissKeyboardOnTap()
        } // End of Navigation Stack
        .navigationBarBackButtonHidden()
    }
    
}

#Preview {
    SignInView()
}
