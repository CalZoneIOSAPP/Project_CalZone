//
//  PrivacyPolicyView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/1/24.
//

import SwiftUI


struct PrivacyPolicyView: View {
    @Environment(\.openURL) var openURL
    var onAgree: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("User Agreement and Privacy Policy")
                .font(.subheadline)
                .fontWeight(.bold)
            
            Text("We understand the importance of user privacy. By pressing [Agree] will indicate that you have read and understood the updated privacy policy and conditions. Please spend some time to find out about our terms.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .padding()
            
            HStack(spacing: 20) {
                Button(action: {
                    openURL(URL(string: "https://gentle-citrine-a19.notion.site/CalBite-Privacy-and-Policy-df6c8f6d3bc3443692242b7a9a6c3890?pvs=74")!)
                }) {
                    Text("Privacy Policy")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                        .underline()
                }
                
                Button(action: {
                    openURL(URL(string: "https://gentle-citrine-a19.notion.site/CalBite-Terms-and-Conditions-2a9532535d8d48bf8f88f0ddc20dcf34?pvs=74")!)
                }) {
                    Text("Terms and Conditions")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                        .underline()
                }
            }
            
            Button(action: {
                // User has agreed, mark as agreed and proceed to the app
                UserDefaults.standard.set(true, forKey: "hasAgreed")
                onAgree()
            }) {
                Text("Agree                             ")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(.brandDarkGreen))
                    .cornerRadius(10)
            }
            .padding(.bottom, -10)
            .padding(.top, 10)
            
            Button(action: {
                // Exit the application
                exit(0)
            }) {
                Text("Disagree                        ")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(.brandRed))
                    .cornerRadius(10)
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(40)
    }
}


extension View {
    /// This function presents the popup for privacy and policy.
    /// - Parameters:
    ///     - isPresented: whether the popup should be displayed.
    ///     - onDismiss: closure
    /// - Returns: popup view
    func popup(isPresented: Binding<Bool>, onDismiss: @escaping () -> Void) -> some View {
        self.overlay(
            Group {
                if isPresented.wrappedValue {
                    ZStack {
                        PrivacyPolicyView {
                            // Dismiss the popup and perform the onDismiss action
                            isPresented.wrappedValue = false
                            onDismiss()
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 1.0), value: 1)
                }
            }
        )
    }
}


#Preview {
    PrivacyPolicyView(onAgree: {
        // Provide a closure here for the onAgree action
        print("User agreed to the privacy policy")
    })
}
