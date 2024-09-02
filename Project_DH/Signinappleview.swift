//
//  signinappleview.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/2/24.
//

import SwiftUI
import _AuthenticationServices_SwiftUI
import AuthenticationServices

struct Signinappleview: View {
    @StateObject var authViewModel = SignInViewModel()
    
    var body: some View {
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
        .frame(width: 293, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.top, 8)
        .shadow(radius: 3)
        .disabled(authViewModel.processingSignIn)
    }
}

#Preview {
    Signinappleview()
}
