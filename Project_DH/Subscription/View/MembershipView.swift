//
//  SubscriptionView.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 10/10/24.
//

import Foundation
import SwiftUI

struct MembershipView: View {
    @StateObject var subscriptionManager: SubscriptionManager
    @Binding var showSubscription: Bool
    @Binding var user: User?
    var currentPlan: String?
    
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
                PlanView(subscriptionManager: subscriptionManager, user: $user, planName: NSLocalizedString("Yearly Plan (12 Months)", comment: ""), price: "$44.99", productId: "yearlyPlan", monthlyRate: NSLocalizedString("$3.75/month", comment: ""), isCurrentPlan: currentPlan == "Yearlyplan", closeMembershipView: {
                    showSubscription = false
                })
                PlanView(subscriptionManager: subscriptionManager, user: $user, planName: NSLocalizedString("Quarterly Plan (3 Months)", comment: ""), price: "$13.99", productId: "quarterlyPlan", monthlyRate: NSLocalizedString("$4.66/month", comment: ""), isCurrentPlan: currentPlan == "Quarterlyplan", closeMembershipView: {
                    showSubscription = false })
                PlanView(subscriptionManager: subscriptionManager, user: $user, planName:  NSLocalizedString("Monthly Plan (1 Month)", comment: ""), price: "$4.99", productId: "monthlyPlan", monthlyRate: NSLocalizedString(" ~ a cup of coffee", comment: ""), isCurrentPlan: currentPlan == "Monthlyplan", closeMembershipView: {
                    showSubscription = false })
            }
            // .disabled(subscriptionManager.purchaseState == .purchasing)
            // .opacity(subscriptionManager.purchaseState == .purchased ? 0 : 1)
            
            // Display "Cancel Membership" button only if the user has a current plan
            if currentPlan != nil {
                Button(action: {
                    openSubscriptionManagement()
//                    subscriptionManager.cancelMembership {
//                        showSubscription = false // Close MembershipView on cancellation
//                    }
                }) {
                    Text(NSLocalizedString("Cancel Membership", comment: ""))
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            
            // Agreement text
            AgreementText()

        }
        .scrollIndicators(.hidden)
        .padding()
        
    }
    
    // Function to open App Store's subscription management page
    private func openSubscriptionManagement() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
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
    var isCurrentPlan: Bool
    var closeMembershipView: () -> Void
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(planName)
                .font(.headline)
                .foregroundColor(.gray)
            
            Button {
                if !isCurrentPlan {
                    subscriptionManager.purchaseVIP(productId: productId) {
                        closeMembershipView()
                    }
                }
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
                .background(isCurrentPlan ? Color.gray : Color.brandLightGreen)
                .cornerRadius(10)
            }
            .disabled(isCurrentPlan)
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
        MembershipView(subscriptionManager: SubscriptionManager(profileViewModel: ProfileViewModel()), showSubscription: .constant(true), user: .constant(User.MOCK_USER), currentPlan: "Monthly")
    }
}
