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
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

 
// ViewModifier to dismiss the keyboard on tap outside of interactive components
struct KeyboardDismissModifier: ViewModifier {
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
    func dismissKeyboardOnTap() -> some View {
        modifier(KeyboardDismissModifier())
    }
}
