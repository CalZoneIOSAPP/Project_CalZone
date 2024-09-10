//
//  LanguageSettingsView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/10/24.
//

import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject var languageSettings: LanguageSettingsViewModel
    @State var showRestartPopup = false
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(Language.allCases, id: \.self) { language in
                        HStack {
                            Text(language.displayName)
                            
                            Spacer()
                            
                            // Show checkmark if language is selected
                            if languageSettings.selectedLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.brandDarkGreen)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            languageSettings.selectedLanguage = language
                            print(languageSettings.selectedLanguage as Any)
                        }
                    }
                }
                .navigationBarTitle(NSLocalizedString("Language Settings", comment: ""), displayMode: .inline) // Set Language
                .navigationBarItems(
                    leading: 
                        Button(NSLocalizedString("Back", comment: ""), action: {
                        // Cancel action (dismiss view or reset)
                            dismiss()
                    }),
                    trailing: 
                        Button(action: {
                            if let language = languageSettings.selectedLanguage {
                                languageSettings.changeLanguage(to: language)
                                showRestartPopup = true
                            }
                        }) {
                            Text(NSLocalizedString("Save", comment: "")) // Done
                                .foregroundColor(languageSettings.selectedLanguage != nil ? .brandDarkGreen : .gray)
                            }
                            .disabled(languageSettings.selectedLanguage == nil) // Disable until a language is selected
                )
                
                
            }
            .blur(radius: showRestartPopup ? 5 : 0)
            
            if showRestartPopup {
                PopUpMessageView(messageTitle: NSLocalizedString("Language Changed", comment: ""), message: NSLocalizedString("Please restart the application to apply the language change.", comment: ""), popupPositivity: .positive, isPresented: $showRestartPopup)
                    .padding(.horizontal, 30)
                    .onDisappear {
                        exit(0)
                    }
            }
        }

    }
}

#Preview {
    LanguageSettingsView()
}
