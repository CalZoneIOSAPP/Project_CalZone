//
//  SubscriptionView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 10/10/24.
//

import Foundation
import SwiftUI

struct MembershipView: View {
    @StateObject var subscriptionManager = SubscriptionManager()
    @Binding var showSubscription: Bool
    @Binding var user: User?
    
    var body: some View {
        ScrollView {
            // Header with icon
            VStack(spacing: 26) {
                HStack {
                    Spacer()
                    Button {
                        showSubscription = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.brandDarkGreen)
                            .padding(.trailing, 15)
                    }
                }
                
                Image("activatePlan") // Replace with custom image if needed
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.orange)
                
                Text("WE HOPE THAT YOU LIKED OUR FEATURES!")
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("JOIN THE CALBITE MEMBERSHIP FOR UNLIMITED USE OF ALL FUNCTIONALITIES.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.brandDarkGreen)
                    .padding(.horizontal)
            }
            .padding(.bottom, 40)
            
            // Plans
            VStack(spacing: 26) {
                PlanView(subscriptionManager: subscriptionManager, user: $user, planName: "Yearly Plan", price: "$81", productId: "yearlyPlan", monthlyRate: "6.75/month")
                PlanView(subscriptionManager: subscriptionManager, user: $user, planName: "Quarterly Plan", price: "$24.3", productId: "quarterlyPlan", monthlyRate: "8.1/month")
                PlanView(subscriptionManager: subscriptionManager, user: $user, planName: "Monthly Plan", price: "$9", productId: "monthlyPlan", monthlyRate: " ~ a cup of coffee")
            }
            .disabled(subscriptionManager.purchaseState == .purchasing)
            .opacity(subscriptionManager.purchaseState == .purchased ? 0 : 1)

        }
        .scrollIndicators(.hidden)
        .padding()
        
    }
}

struct PlanView: View {
    @StateObject var subscriptionManager: SubscriptionManager
    @Binding var user: User?
    var planName: String
    var price: String
    var productId: String
    var monthlyRate: String?
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(planName)
                .font(.headline)
                .foregroundColor(.gray)
            
            Button {
                subscriptionManager.purchaseVIP(productId: productId) // add subscription type
            } label: {
                HStack {
                    Text(price)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    if let monthlyRate = monthlyRate {
                        Text("(\(monthlyRate))")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.brandLightGreen)
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MembershipView(showSubscription: .constant(true), user: .constant(User.MOCK_USER))
    }
}
