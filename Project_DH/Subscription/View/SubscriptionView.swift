import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                
                ScrollView {
                    VStack(spacing: 20) {
                        Image("activatePlan") // Replace with custom image if needed
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .foregroundColor(.orange)
                        
                        // Header
                        VStack(spacing: 10) {
                            Text("Become a CalBite Foodie")
                                .font(.title)
                                .bold()
                            
                            Text("Unlock usage limits for all features.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical)
                        
                        
                        HStack{
                            Text("Unlimited use of following features")
                                .font(.title2)
                                .bold()
                                .padding(.leading, 20)
                            Spacer()
                        }
                        .padding(.top)
                        
                        // Features Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            FeatureItem(icon: "person.fill", title: "AI Assistant")
                            FeatureItem(icon: "chart.bar.fill", title: "Meal Analysis")
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Pricing")
                                .font(.title2)
                                .bold()
                                .padding(.leading, 20)
                            Spacer()
                        }
                        .padding(.top)
                        
                        
                        // Subscription Plans
                        VStack(spacing: 15) {
                            ForEach(subscriptionManager.subscriptions, id: \.id) { product in
                                PlanView(
                                    subscriptionManager: subscriptionManager,
                                    planName: product.displayName,
                                    price: product.displayPrice,
                                    productId: product.id,
                                    monthlyRate: product.monthlyRate,
                                    isCurrentPlan: subscriptionManager.currentSubscription?.id == product.id,
                                    closeMembershipView: {
                                        dismiss()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Current Subscription Status
                        if subscriptionManager.currentSubscription != nil {
                            Button("Manage Subscription") {
                                Task {
                                    await subscriptionManager.manageSubscriptions()
                                }
                            }
                            .buttonStyle(.bordered)
                            .padding(.top)
                        }
                        
                        // Terms and Privacy
                        VStack(spacing: 5) {
                            Text("By continuing, you agree to our")
                            HStack(spacing: 3) {
                                Text("Terms of Service")
                                    .underline()
                                Text("and")
                                Text("Privacy Policy")
                                    .underline()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.brandDarkGreen)
                .frame(width: 40, height: 40)
                .background(.brandBackgroundGreen)
                .clipShape(Circle())
            
            Text(title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PlanView: View {
    let subscriptionManager: SubscriptionManager
    let planName: String
    let price: String
    let productId: String
    let monthlyRate: String
    let isCurrentPlan: Bool
    let closeMembershipView: () -> Void
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text(planName)
                .font(.headline)
            
            Text(price)
                .font(.title)
                .bold()
            
            Text(monthlyRate)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if isCurrentPlan {
                Text("Current Plan")
                    .foregroundColor(.brandDarkGreen)
                    .padding(.top, 5)
            } else {
                Button(action: {
                    Task {
                        await purchaseSubscription()
                    }
                }) {
                    Text("Select Plan")
                        .font(.headline)
                        .foregroundColor(.brandDarkGreen)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.brandBackgroundGreen)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
                .opacity(isLoading ? 0.5 : 1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func purchaseSubscription() async {
        isLoading = true
        do {
            if let product = subscriptionManager.subscriptions.first(where: { $0.id == productId }) {
                if (try await subscriptionManager.purchase(product)) != nil {
                    // Only close if purchase was successful
                    closeMembershipView()
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}

// MARK: - Product Extensions

extension Product {
    var monthlyRate: String {
        switch subscriptionPlan {
        case .monthlyPlan:
            return "Billed monthly"
        case .quarterlyPlan:
            return "$4.66/month"
        case .yearlyPlan:
            return "$3.75/month"
        case .none:
            return ""
        }
    }
    
    var displayName: String {
        switch subscriptionPlan {
        case .monthlyPlan:
            return "Monthly Plan"
        case .quarterlyPlan:
            return "Quarterly Plan"
        case .yearlyPlan:
            return "Yearly Plan"
        case .none:
            return self.displayName
        }
    }
    
    var description: String {
        switch subscriptionPlan {
        case .monthlyPlan:
            return "Perfect for trying out premium features"
        case .quarterlyPlan:
            return "Save 15% with quarterly billing"
        case .yearlyPlan:
            return "Best value! Save 40% annually"
        case .none:
            return self.description
        }
    }
}


#Preview {
    SubscriptionView()
}
