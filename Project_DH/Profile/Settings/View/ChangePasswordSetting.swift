//
//  ChangePasswordSetting.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/7/24.
//

import SwiftUI

struct ChangePasswordSetting: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isOldPasswordVisible: Bool = false
    @State private var isNewPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var message: PopupMessage = PopupMessage(message: "", title: "")
    @State private var showPopup: Bool = false
    @State private var popupPositivity: popupPositivity = .informative
    @State private var processing: Bool = false
    
    @Binding var user: User?

    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    // Current Password
                    if let user = user, user.passwordSet ?? false {
                        Section(header: HStack{Text("Enter Current Password").font(.headline).foregroundStyle(.gray); Spacer()}) {
                            SecureInputView("Enter Current Password", text: $currentPassword, isPasswordVisible: $isOldPasswordVisible)
                        }
                    }
                    // New Password
                    Section(header: HStack{Text("Enter New Password").font(.headline).foregroundStyle(.gray); Spacer()}) {
                        SecureInputView("Enter New Password", text: $newPassword, isPasswordVisible: $isNewPasswordVisible)
                    }
                    
                    // Confirm New Password
                    SecureInputView("Re-enter New Password", text: $confirmPassword, isPasswordVisible: $isConfirmPasswordVisible)

                    // Password Hint
                    Text("Password must be at least 6 characters.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 5)

                    // Submit Button
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        processing = true
                        Task {
                            defer {
                                processing = false
                            }
                            if let user = user, user.passwordSet ?? false {
                                message = try await UserServices().changePassword(oldPassword: currentPassword, newPassword: newPassword, confirmPassword: confirmPassword)
                            } else {
                                message = try await UserServices().changePassword(oldPassword: nil, newPassword: newPassword, confirmPassword: confirmPassword)
                            }
                            showPopup = true
                            if message.title == "Success" {
                                popupPositivity = .positive
                                currentPassword = ""
                                newPassword = ""
                                confirmPassword = ""
                            } else {
                                popupPositivity = .negative
                            }
                        }
                    }) {
                        Text("Complete")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.brandLightGreen)
                            .foregroundColor(.brandDarkGreen)
                            .cornerRadius(8)
                            .padding(.top, 20)
                    }
                    .disabled(processing)
                    
                    Spacer()
                    
                }
                .padding()
                .dismissKeyboardOnTap()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.brandDarkGreen)
                                .imageScale(.large)
                        }
                    }
                }
            } // NavigationStack
            .blur(radius: showPopup ? 5 : 0)
            .disabled(showPopup)
            
            if showPopup {
                PopUpMessageView(messageTitle: message.title, message: message.message, popupPositivity: popupPositivity, isPresented: $showPopup)
            }
        } // ZStack
        
    }
}


struct SecureInputView: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isPasswordVisible: Bool

    init(_ placeholder: String, text: Binding<String>, isPasswordVisible: Binding<Bool>) {
        self.placeholder = placeholder
        self._text = text
        self._isPasswordVisible = isPasswordVisible
    }

    var body: some View {
        HStack {
            if isPasswordVisible {
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
            } else {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
            }

            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 5)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .padding(.vertical, 5)
    }
}



#Preview {
    ChangePasswordSetting(user: .constant(User.MOCK_USER))
}
