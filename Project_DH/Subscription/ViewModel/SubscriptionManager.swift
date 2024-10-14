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
    private var currentProduct: SKProduct?

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

    /// Fetches available subscription products from App Store Connect.
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: ["com.yourapp.vip_subscription"]) // Replace with your product ID
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }

    /// Initiates a purchase for the given product.
    func purchaseVIP(for user: User?) {
        guard let product = products.first else {
            print("No products available for purchase.")
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
                // updateVIPStatus(for: transaction) TODO: Need to uncomment this when finish implementing the updateVIPStatus function
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

    /// Restores any previous purchases. This is useful if the user changes devices or reinstalls the app.
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
