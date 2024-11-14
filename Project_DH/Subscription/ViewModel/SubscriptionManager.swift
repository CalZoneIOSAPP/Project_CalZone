//
//  SubscriptionManager.swift
//  Project_DH
//
//  Created by mac on 2024/10/9.
//

import StoreKit
import SwiftUI
import Combine
import Firebase

class SubscriptionManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var products: [SKProduct] = []
    @Published var purchaseState: PurchaseState = .notPurchased
    @Published var showSubscriptionPage: Bool = false
    
    private var productRequest: SKProductsRequest?
    private var selectedProductId: String?
    private let profileViewModel : ProfileViewModel
    private var purchaseCompletion: (() -> Void)?

    enum PurchaseState {
        case purchasing, purchased, notPurchased
    }
    

    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }

    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    

    /// Fetches available subscription products.
    func fetchProducts() {
        let productIdentifiers: Set<String> = ["monthlyPlan", "quarterlyPlan", "yearlyPlan"]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }

    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }

    
    /// Initiates a purchase for the given product ID.
    func purchaseVIP(productId: String, completion: @escaping () -> Void) {
        guard let product = products.first(where: { $0.productIdentifier == productId }) else {
            print("Product with ID \(productId) not found.")
            return
        }

        selectedProductId = productId
        purchaseCompletion = completion
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        purchaseState = .purchasing
        
    }

    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                purchaseState = .purchased
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Purchase successful for product: \(transaction.payment.productIdentifier)")
                
                if let productId = selectedProductId {
                    updateSubscriptionInFirebase(for: productId)
                }
                
                // Call the completion handler to notify of purchase completion
                purchaseCompletion?()
                purchaseCompletion = nil
                
                // Refetch user subscription after successful purchase
                Task {
                    try await profileViewModel.fetchUserSubscription() // Notify ProfileViewModel to refresh
                }

            case .failed:
                purchaseState = .notPurchased
                if let error = transaction.error {
                    print("Transaction failed: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                purchaseCompletion = nil

            case .restored:
                purchaseState = .purchased
                let productId = transaction.payment.productIdentifier // Direct assignment
                updateSubscriptionInFirebase(for: productId)
                SKPaymentQueue.default().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    
    // Cancels the current membership by updating Firebase
    func cancelMembership(completion: @escaping () -> Void) {
        guard let userEmail = profileViewModel.currentUser?.email else {
            print("User email not available.")
            return
        }
        
        let db = Firestore.firestore()
        
        let query = db.collection("subscriptions").whereField("email", isEqualTo: userEmail)
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Failed to fetch subscriptions: \(error.localizedDescription)")
                return
            }
            
            guard let document = snapshot?.documents.first else {
                print("No subscription found for user: \(userEmail)")
                return
            }
            
            document.reference.delete() { error in
                if let error = error{
                    print("Failed to delete subscription: \(error.localizedDescription)")
                    return
                } else {
                    print("Successfully deleted subscription.")
                    
                    DispatchQueue.main.async {
                        self.purchaseState = .notPurchased
                        self.profileViewModel.subscriptionType = nil
                        self.profileViewModel.isVIP = false
                        completion()
                    }
                }
            }
        }
        
    }

    
    private func updateSubscriptionInFirebase(for newProductId: String) {
        guard let userEmail = profileViewModel.currentUser?.email else {
            print("User email not available.")
            return
        }
        
        let db = Firestore.firestore()
        let subscriptionRef = db.collection("subscriptions")
        
        // Retrieve the current subscription
        subscriptionRef
            .whereField("email", isEqualTo: userEmail)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("ERROR: Error checking for subscription. \n\(error.localizedDescription)")
                    return
                }
                
                if let documents = querySnapshot?.documents, let document = documents.first {
                    // Existing subscription found
                    let currentProductId = document.get("type") as? String ?? ""
                    
                    if self.isUpgrade(currentPlan: currentProductId, newPlan: newProductId) {
                        // Upgrade: Apply new end date based on new plan immediately
                        let newEndDate = self.calculateEndDate(for: newProductId)
                        
                        let data: [String: Any] = [
                            "type": newProductId,
                            "startDate": Timestamp(date: Date()),
                            "endDate": newEndDate,
                            "isVIP": true // Adjust if needed based on plan type
                        ]
                        
                        document.reference.updateData(data) { error in
                            if let error = error {
                                print("ERROR: Failed to upgrade subscription: \(error.localizedDescription)")
                            } else {
                                print("NOTE: Subscription upgraded successfully.")
                            }
                        }
                        
                    } else {
                        // Downgrade: Maintain current end date, set downgrade to apply at period end
                        let currentEndDate = document.get("endDate") as? Timestamp ?? self.calculateEndDate(for: currentProductId)
                        
                        document.reference.updateData([
                            "nextType": newProductId,    // Schedule new plan type for next cycle
                            "nextEndDate": currentEndDate // Downgrade applied at end of current cycle
                        ]) { error in
                            if let error = error {
                                print("ERROR: Failed to schedule downgrade: \(error.localizedDescription)")
                            } else {
                                print("NOTE: Downgrade scheduled for end of current period.")
                            }
                        }
                    }
                    
                } else {
                    // No existing subscription, create new subscription entry
                    let data: [String: Any] = [
                        "email": userEmail,
                        "isVIP": true,
                        "type": newProductId,
                        "startDate": Timestamp(date: Date()),
                        "endDate": self.calculateEndDate(for: newProductId)
                    ]
                    
                    db.collection("subscriptions").addDocument(data: data) { error in
                        if let error = error {
                            print("ERROR: Failed to create subscription: \(error.localizedDescription)")
                        } else {
                            print("NOTE: Subscription created successfully.")
                        }
                    }
                }
            }
    }
    
    
    @MainActor
    func checkAndUpdateSubscription(for userEmail: String) async throws {
        let db = Firestore.firestore()
        let subscriptionRef = db.collection("subscriptions").whereField("email", isEqualTo: userEmail)
        
        // Fetch subscription document
        let querySnapshot = try await subscriptionRef.getDocuments()
        guard let document = querySnapshot.documents.first else {
            print("No subscription document found for this user.")
            return
        }
        
        let subscriptionData = document.data()
        let endDate = (subscriptionData["endDate"] as? Timestamp)?.dateValue() ?? Date()
        let now = Date()
        
        // Check if the subscription has expired
        if endDate <= now, let nextType = subscriptionData["nextType"] as? String {
            // Subscription expired, apply the scheduled next plan
            let newEndDate = calculateEndDate(for: nextType)
            
            // Define data outside MainActor
            let updateData: [String: Any] = [
                "type": nextType,
                "endDate": newEndDate,
                "nextType": FieldValue.delete(),
                "nextEndDate": FieldValue.delete()
            ]
            
            // Update Firestore with the new plan
            try await document.reference.updateData(updateData)
            
            print("Subscription updated to new plan successfully.")
        } else {
            print("Subscription is still active or no next plan scheduled.")
        }
    }


    
    // Helper function to determine if it's an upgrade or downgrade
    func isUpgrade(currentPlan: String, newPlan: String) -> Bool {
        let planOrder: [String: Int] = ["monthlyPlan": 1, "quarterlyPlan": 2, "yearlyPlan": 3]
        return planOrder[newPlan] ?? 0 > planOrder[currentPlan] ?? 0
    }

    // Calculate end date method remains unchanged


    
    /// Calculate the end date based on the subscription type.
    private func calculateEndDate(for productId: String) -> Timestamp {
        let calendar = Calendar.current
        var components = DateComponents()

        switch productId {
        case "monthlyPlan":
            components.month = 1
        case "quarterlyPlan":
            components.month = 3
        case "yearlyPlan":
            components.year = 1
        default:
            components.month = 1
        }

        let endDate = calendar.date(byAdding: components, to: Date()) ?? Date()
        return Timestamp(date: endDate)
    }

    
    /// Restore purchases if the user reinstalls the app or changes devices.
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
