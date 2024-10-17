//
//  SettingsView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/7/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = SettingsViewModel()
    @StateObject var languageSettings = LanguageSettingsViewModel()
    
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    Section {
                        ForEach(SettingsOptions.allCases){ option in
                            HStack {
                                if option.title == NSLocalizedString("Change Password", comment: "") {
                                    if let passwordSet = viewModel.currentUser?.passwordSet, passwordSet == false {
                                        Text(NSLocalizedString("Set New Password", comment: ""))
                                    } else {
                                        Text(option.title)
                                    }
                                } else {
                                    Text(option.title)
                                }
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Show each edit window
                                switch option {
                                case .changePassword:
                                    viewModel.showChangePassword = true
                                case .changeLanguage:
                                    viewModel.showChangeLanguage = true
                                case .deleteAccount:
                                    viewModel.showDeleteAccount = true
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
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
                .fullScreenCover(isPresented: $viewModel.showChangePassword, content: {
                    ChangePasswordSetting(user: $viewModel.currentUser)
                })
                .fullScreenCover(isPresented: $viewModel.showChangeLanguage) {
                    LanguageSettingsView()
                        .environmentObject(languageSettings)
                }
                .fullScreenCover(isPresented: $viewModel.showDeleteAccount) {
                    DeleteAccountView()
                }
                
                
            } // End of NavigationStack
        } // ZSTACK
    }
}

#Preview {
    SettingsView()
}
