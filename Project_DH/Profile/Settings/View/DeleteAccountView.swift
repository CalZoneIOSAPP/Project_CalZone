//
//  DeleteAccountView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 10/17/24.
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("DELETE ACCOUNT")
            }
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
        }
    }
    
}

#Preview {
    DeleteAccountView()
}
