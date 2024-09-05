//
//  KeyboardDismissView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 8/16/24.
//

import Foundation
import SwiftUI
import UIKit

extension UIApplication {
    
    /// Hides the activated keyboard.
    /// - Parameters: none
    /// - Returns: none
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

 
// ViewModifier to dismiss the keyboard on tap outside of interactive components
struct KeyboardDismissModifier: ViewModifier {
    
    /// The modifier to hold the keyboard dismissal component.
    /// - Parameters: none
    /// - Returns: The view which holds the keyboard dismiss component.
    func body(content: Content) -> some View {
        content
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.hideKeyboard()
                    }
            )
    }
}


// Extension to easily apply the modifier
extension View {
    /// The wrapper for KeyboardDismissModifier.
    /// - Parameters: none
    /// - Returns: The view of keyboard dismiss component.
    func dismissKeyboardOnTap() -> some View {
        modifier(KeyboardDismissModifier())
    }
}
