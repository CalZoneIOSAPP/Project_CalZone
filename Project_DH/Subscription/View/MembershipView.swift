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
                
                // Feature Overview
                VStack(spacing: 26) {
                    Text("JOIN THE CALBITE MEMBERSHIP FOR UNLIMITED USE OF ALL FUNCTIONALITIES.")
                        .font(.body)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 5)
                        .padding(.top, 15)
                    
                    FeatureView(featureName: NSLocalizedString("AI Assistant", comment: ""), featureDescription: NSLocalizedString("Ask unlimited dietary and dining questions in a single day.", comment: ""), icon: "person.fill")
                    
                    FeatureView(featureName: NSLocalizedString("Calorie Estimation", comment: ""), featureDescription: NSLocalizedString("Take unlimited photos and get the calorie estimations in a single day.", comment: ""), icon: "camera.fill")
                        .padding(.bottom, 15)
                }
                .frame(minWidth: 350, maxHeight: 300)
                .background(LinearGradient(gradient: Gradient(colors: [Color.brandLightGreen, Color.brandTurquoise]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 3)
                .padding(.horizontal)
                
                
                
            }
            .padding(.bottom, 40)
            
            // Plans
            VStack(spacing: 26) {
                PlanView(subscriptionManager: subscriptionManager, user: $user, planName: "Yearly Plan (12 Months)", price: "$44.99", productId: "yearlyPlan", monthlyRate: "3.75/month")
                PlanView(subscriptionManager: subscriptionManager, user: $user, planName: "Quarterly Plan (3 Months)", price: "$13.99", productId: "quarterlyPlan", monthlyRate: "4.66/month")
                PlanView(subscriptionManager: subscriptionManager, user: $user, planName: "Monthly Plan (1 Month)", price: "$4.99", productId: "monthlyPlan", monthlyRate: " ~ a cup of coffee")
            }
            .disabled(subscriptionManager.purchaseState == .purchasing)
            .opacity(subscriptionManager.purchaseState == .purchased ? 0 : 1)
            
            // Agreement text
            AgreementText()

        }
        .scrollIndicators(.hidden)
        .padding()
        
    }
}


struct FeatureView: View {
    var featureName: String
    var featureDescription: String
    var icon: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.brandDarkGreen)
                
                Text(featureName)
                    .font(.body)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.bottom, 5)
            
            HStack {
                Text(featureDescription)
                    .font(.body)
                    .foregroundStyle(.gray)
                
                Spacer()
            }
            
        }
        .padding(.horizontal)
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



struct AgreementText: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack {
            Text("By proceeding you have read and agree to the ")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .padding(.top)
            
            HStack {
                Button(action: {
                    openURL(URL(string: "https://gentle-citrine-a19.notion.site/CalBite-Privacy-and-Policy-df6c8f6d3bc3443692242b7a9a6c3890?pvs=74")!)
                }) {
                    Text("Privacy Policy")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                        .underline()
                }
                
                Text("and")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                
                Button(action: {
                    openURL(URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                }) {
                    Text("Terms and Conditions")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                        .underline()
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MembershipView(showSubscription: .constant(true), user: .constant(User.MOCK_USER))
    }
}
