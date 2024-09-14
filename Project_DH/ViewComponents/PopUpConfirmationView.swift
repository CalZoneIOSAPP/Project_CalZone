//
//  PopUpConfirmationView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/9/24.
//

import SwiftUI

struct PopUpConfirmationView: View {
    
    var messageTitle: String
    var message: String
    var actionButtonText: String
    @Binding var isPresented: Bool
    @Binding var actionBool: Bool
    
    var popupPositivity: popupPositivity = .informative
    
    var body: some View {
        VStack(spacing: 20) {
            // Success icon (green circle with checkmark)
            popupPositivity.icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(popupPositivity.colorIcon)
            
            // Title Text
            Text(messageTitle)
                .font(.title2)
                .fontWeight(.semibold)
            
            // Subtitle Text
            Text(message)
                .font(.body)
                .foregroundColor(.gray)
            
            HStack {
                Button(action: {
                    isPresented = false
                    actionBool = true
                    // Other actions
                }) {
                    Text(actionButtonText)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.brandLightGreen).opacity(0.6))
                        .foregroundStyle(Color(.brandDarkGreen))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.brandRed).opacity(0.3))
                        .foregroundStyle(Color(.brandRed))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
            }

        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
}


struct PopUpConfirmationView_Preview: PreviewProvider {
    
    @State static var isPresented = true
    
    static var previews: some View {
        PopUpConfirmationView(
            messageTitle: "Success!",
            message: "The displayed message will be here", 
            actionButtonText: "Delete",
            isPresented: $isPresented,
            actionBool: .constant(false)
        )
        .previewLayout(.sizeThatFits) // Adjust the preview size to fit the view
    }
    
}
