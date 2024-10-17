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
    private var selectedProductId: String? // Track which product is being purchased
    private let profileViewModel = ProfileViewModel() // Access the user's email


    enum PurchaseState {
        case purchasing, purchased, notPurchased
    }

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    /// Fetches available subscription products.
    func fetchProducts() {
        let productIdentifiers: Set<String> = ["monthlyPlan", "quarterlyPlan", "yearlyPlan"] // Replace with actual IDs
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
    func purchaseVIP(productId: String) {
        guard let product = products.first(where: { $0.productIdentifier == productId }) else {
            print("Product with ID \(productId) not found.")
            return
        }

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
                
                // Update the firebase here
                if let productId = selectedProductId {
                    updateSubscriptionInFirebase(for: productId)
                }
                
            case .failed:
                purchaseState = .notPurchased
                if let error = transaction.error {
                    print("Transaction failed: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                purchaseState = .purchased
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Purchase restored.")
            default:
                break
            }
        }
    }

    
    /// Update the user's subscription in Firebase.
    private func updateSubscriptionInFirebase(for productId: String) {
        guard let userEmail = profileViewModel.currentUser?.email else {
            print("User email not available.")
            return
        }

        let db = Firestore.firestore()
        let data: [String: Any] = [
            "email": userEmail,
            "isVIP": true,
            "type": productId,
            "startDate": Timestamp(date: Date()),
            "endDate": calculateEndDate(for: productId)
        ]

        db.collection("subscriptions").document(userEmail).setData(data, merge: true) { error in
            if let error = error {
                print("Failed to update subscription: \(error.localizedDescription)")
            } else {
                print("Subscription updated successfully.")
            }
        }
    }
    
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


