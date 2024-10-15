//
//  SubscriptionManager.swift
//  Project_DH
//
//  Created by mac on 2024/10/9.
//

import StoreKit
import SwiftUI
import Combine

class SubscriptionManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var products: [SKProduct] = []
    @Published var purchaseState: PurchaseState = .notPurchased
    @Published var showSubscriptionPage: Bool = false

    private var productRequest: SKProductsRequest?

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
                // Uncomment and implement the backend update if needed:
                // updateVIPStatus(for: transaction)
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

    
    /// Updates the VIP status in Firebase or your backend after a successful purchase.
    /*
    private func updateVIPStatus(for transaction: SKPaymentTransaction) {
        // Ensure you have a way to update the user's status in your backend or database.
        // For example, if using Firebase:
        if let userId = user?.id {
            let db = Firestore.firestore()
            db.collection("users").document(userId).updateData(["isVIP": true]) { error in
                if let error = error {
                    print("Failed to update VIP status: \(error.localizedDescription)")
                } else {
                    print("User successfully upgraded to VIP!")
                }
            }
        }
    }
    */
    
    
    /// Restore purchases if the user reinstalls the app or changes devices.
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}


