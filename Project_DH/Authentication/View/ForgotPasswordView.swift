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
    @State private var refreshTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("password_reset_instructions")
                    .font(.subheadline)
                    .padding(.vertical, 60)
                    .padding(.horizontal, 20)
                
                Spacer()
                
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
                
                Spacer()
                
                
                if !TimeManager.sharedTimer.isButtonEnabled {
                    Text("remaining_seconds \(TimeManager.sharedTimer.timeRemaining)")
                        .onReceive(refreshTimer) { _ in
                            
                        }
                }
                
                Button(action: {
                    Task {try await authViewModel.resetPassword() }
                    TimeManager.sharedTimer.isButtonEnabled = false
                    TimeManager.sharedTimer.startTimer()
                }) {
                    Text("send_reset_link                                                     ")
                }
                .disabled(!TimeManager.sharedTimer.isButtonEnabled)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 310, height: 45)
                .background(.brandDarkGreen)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.vertical)
                
                Spacer()
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
