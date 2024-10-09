//
//  SubscriptionButton.swift
//  Project_DH
//
//  Created by mac on 2024/10/9.
//

import SwiftUI
import StoreKit

struct SubscriptionButton: View {
    @StateObject var subscriptionManager = SubscriptionManager()
    var user: User?

    var body: some View {
        Button(action: {
            // Start the subscription purchase process
            subscriptionManager.purchaseVIP(for: user)
        }) {
            Text("Upgrade to VIP")
                .font(.footnote)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .foregroundColor(.white)
                .background(Color.brandDarkGreen)
                .cornerRadius(8)
        }
        .disabled(subscriptionManager.purchaseState == .purchasing)
        .opacity(subscriptionManager.purchaseState == .purchased ? 0 : 1)
    }
}
#Preview {
    SubscriptionButton()
}
