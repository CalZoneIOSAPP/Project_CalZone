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
    
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    Section {
                        ForEach(SettingsOptions.allCases){ option in
                            HStack {
                                Text(option.title)
                                Spacer()
                            }
                            .onTapGesture {
                                // Show each edit window
                                switch option {
                                case .changePassword:
                                    viewModel.showChangePassword = true
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
                                .foregroundColor(.green)
                                .imageScale(.large)
                        }
                    }
                }
                .fullScreenCover(isPresented: $viewModel.showChangePassword, content: {
                    ChangePasswordSetting()
                })
                
            } // End of NavigationStack
        } // ZSTACK
    }
}

#Preview {
    SettingsView()
}
