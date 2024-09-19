//
//  ForgotPasswordView.swift
//  Project_Me
//
//  Created by Yongxiang Jin on 5/7/24.
//

import SwiftUI


/// The major view for showing the forgot password page.
/// - Parameters:
///     - none
/// - Returns: none
struct ForgotPasswordView: View {
    @StateObject var authViewModel = SignInViewModel()
    @ObservedObject private var timeManager = TimeManager.sharedTimer
//    @State private var refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage = " "
    
    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                VStack {
                    Text("password_reset_instructions")
                        .font(.subheadline)
                        .padding(.vertical, 60)
                        .padding(.horizontal, 20)
                    
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
                    
                    HStack { // ERROR MESSAGE
                        errorMessage != " " ? Text(errorMessage) : Text(" ")
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundStyle(.brandRed)
                    .padding(.leading, 30)
                    
                    Spacer()
                    
                    Image("resetPassword")
                        .resizable()
                        .frame(width: 260, height: 260)
                        .clipShape(Circle())
                        .opacity(0.5)
                    
                    
                    Spacer()
                    
                    if !timeManager.isButtonEnabled {
                        Text("remaining_seconds \(timeManager.timeRemaining)")
                            .font(.headline)
                            .foregroundStyle(.gray)
                            .onReceive(timeManager.$timeRemaining) { _ in
                                // This ensures the view listens for updates
                            }
                    }
                    
                    Button(action: {
                        Task {
                            if authViewModel.email.isValidEmailFormat {
                                try await authViewModel.resetPassword()
                                TimeManager.sharedTimer.isButtonEnabled = false
                                TimeManager.sharedTimer.startTimer()
                                errorMessage = " "
                            } else {
                                errorMessage = NSLocalizedString("Invalid email, please try again.", comment: "")
                            }
                        }
                    }) {
                        Text("send_reset_link                                                     ")
                    }
                    .disabled(!TimeManager.sharedTimer.isButtonEnabled)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 310, height: 45)
                    .background(Color(.brandDarkGreen).opacity(TimeManager.sharedTimer.isButtonEnabled ? 1 : 0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.vertical)
                    
                    Spacer()
                }
            }
            .ignoresSafeArea(.keyboard)
        }// End of Navigation Stack
        .navigationTitle("reset_password")
        .navigationBarTitleDisplayMode(.large)
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
        }
    }
}

#Preview {
    ForgotPasswordView()
}
