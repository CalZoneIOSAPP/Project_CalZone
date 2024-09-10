//
//  FriendsView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/7/24.
//

import SwiftUI

struct FriendsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("You will soon be able to connect with your friends.")
                Image("friends")
                    .resizable()
                    .frame(width: 260, height: 260)
                    .clipShape(Circle())
                    .opacity(0.5)
            }
            .navigationTitle("Friends")
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
        } // End of NavigationStack
    }
}

#Preview {
    FriendsView()
}
