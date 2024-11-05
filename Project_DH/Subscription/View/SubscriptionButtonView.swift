//
//  SubscriptionButton.swift
//  Project_DH
//
//  Created by mac on 2024/10/9.
//

import SwiftUI
import StoreKit

struct SubscriptionButton: View {
    @Binding var showSubscribePage: Bool
    var user: User?
    var subscriptionType: String?

    var body: some View {
        Button(action: {
            showSubscribePage = true
            print("The subscriptionType for the button is: \(String(describing: subscriptionType))")
        }) {
            Text(subscriptionType == nil ? NSLocalizedString("Upgrade to VIP", comment: "") : NSLocalizedString("Manage Plan", comment: ""))
                .font(.footnote)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .foregroundColor(.white)
                .background(Color.brandDarkGreen)
                .cornerRadius(8)
        }
    }
}
#Preview {
    SubscriptionButton(showSubscribePage: .constant(false), subscriptionType: "MonthlyPlan")
}
