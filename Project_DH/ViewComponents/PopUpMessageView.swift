//
//  PopUpMessageView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/27/24.
//

import SwiftUI


struct PopUpMessageView: View {
    
    var messageTitle: String
    var message: String
    var popupPositivity: popupPositivity
    @Binding var isPresented: Bool
    
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
            
            
            Button(action: {
                isPresented = false
            }) {
                Text("Close")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(popupPositivity.colorBackground)
                    .foregroundStyle(popupPositivity.colorForeground)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            // Button
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
}


struct PopUpMessageView_Previews: PreviewProvider {
    
    @State static var isPresented = true
    
    static var previews: some View {
        PopUpMessageView(
            messageTitle: "Success!",
            message: "The displayed message will be here",
            popupPositivity: .informative,
            isPresented: $isPresented
        )
        .previewLayout(.sizeThatFits) // Adjust the preview size to fit the view
    }
    
}
