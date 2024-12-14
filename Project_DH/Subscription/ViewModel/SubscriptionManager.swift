//
//  SubscriptionManager.swift
//  Project_DH
//
//  Created by mac on 2024/10/9.
//

import Foundation
import StoreKit
import FirebaseFirestore
import FirebaseAuth

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var currentSubscription: Product?
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var isVIP: Bool = false
    
    private var updateListenerTask: Task<Void, Error>?
    private let db = Firestore.firestore()
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        do {
            subscriptions = try await Product.products(
                for: SubscriptionPlan.allCases.map { $0.rawValue }
            )
            
            // Sort in desired order: yearly, quarterly, monthly
            subscriptions.sort { product1, product2 in
                let order: [SubscriptionPlan] = [.yearlyPlan, .quarterlyPlan, .monthlyPlan]
                let plan1 = product1.subscriptionPlan
                let plan2 = product2.subscriptionPlan
                
                guard let index1 = plan1.flatMap({ plan in order.firstIndex(of: plan) }),
                      let index2 = plan2.flatMap({ plan in order.firstIndex(of: plan) }) else {
                    return false
                }
                
                return index1 < index2
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase Management
    
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            print("DEBUG(purchase): Purchase transaction details:")
            print("DEBUG(purchase): - Product ID: \(transaction.productID)")
            print("DEBUG(purchase): - Purchase Date: \(transaction.purchaseDate)")
            
            // Verify the product ID matches what we expect
            guard transaction.productID == product.id else {
                print("DEBUG(purchase): Error - Transaction product ID (\(transaction.productID)) doesn't match requested product (\(product.id))")
                return nil
            }
            
            // Calculate end date based on the subscription plan
            let plan = getSubscriptionPlan(from: product.id)
            print("DEBUG: Product ID: \(product.id)")
            print("DEBUG: Mapped to plan: \(String(describing: plan))")
            
            let endDate = calculateEndDate(for: plan, startingFrom: Date())
            print("DEBUG: Our calculated end date: \(endDate.dateValue())")
            
            if let storeKitExpiration = transaction.expirationDate {
                print("DEBUG(purchase): StoreKit's expiration date: \(storeKitExpiration)")
                print("DEBUG(purchase): Note: Currently using our calculated date instead of StoreKit's date")
            }
            
            // Update Firebase with our calculated end date
            await updateFirebaseSubscription(for: product, expirationDate: endDate.dateValue())
            
            // Update local state
            await MainActor.run {
                self.isVIP = true
                self.currentSubscription = product
            }
            
            await transaction.finish()
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Firebase Integration
    
    private func getSubscriptionPlan(from productId: String) -> SubscriptionPlan? {
        return SubscriptionPlan(rawValue: productId)
    }
    
    private func updateFirebaseSubscription(for product: Product, expirationDate: Date? = nil) async {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found")
            return
        }
        
        let startDate = Date()
        let endDate: Timestamp
        
        if let specificEndDate = expirationDate {
            endDate = Timestamp(date: specificEndDate)
        } else {
            let plan = getSubscriptionPlan(from: product.id)
            print("DEBUG: Product ID: \(product.id)")
            print("DEBUG: Mapped to plan: \(String(describing: plan))")
            endDate = calculateEndDate(for: plan, startingFrom: Date())
        }
        print("DEBUG: Final end date for Firebase: \(endDate.dateValue())")
        
        // Create Sendable dictionary
        let subscriptionData: [String: Any] = await withCheckedContinuation { continuation in
            Task { @MainActor in
                let data: [String: Any] = [
                    "email": user.email ?? "",
                    "endDate": endDate,
                    "isVIP": true,
                    "type": product.id,
                    "startDate": Timestamp(date: startDate),
                    "lastUpdated": Timestamp(date: startDate)
                ]
                print("DEBUG: Writing to Firebase - endDate: \(endDate.dateValue())")
                continuation.resume(returning: data)
            }
        }
        
        do {
            // Check if subscription document exists
            let querySnapshot = try await db.collection("subscriptions")
                .whereField("email", isEqualTo: user.email ?? "")
                .getDocuments()
            
            if let existingDoc = querySnapshot.documents.first {
                // Update existing subscription
                try await existingDoc.reference.updateData(subscriptionData)
                print("DEBUG: Updated existing document with end date: \(endDate.dateValue())")
            } else {
                // Create new subscription document
                _ = try await db.collection("subscriptions").addDocument(data: subscriptionData)
                print("DEBUG: Created new document with end date: \(endDate.dateValue())")
            }
            
            // Verify the write by reading it back
            let verifySnapshot = try await db.collection("subscriptions")
                .whereField("email", isEqualTo: user.email ?? "")
                .getDocuments()
            
            if let doc = verifySnapshot.documents.first,
               let verifyEndDate = (doc.data()["endDate"] as? Timestamp)?.dateValue() {
                print("DEBUG: Verified end date in Firebase: \(verifyEndDate)")
            }
            
            await MainActor.run {
                self.isVIP = true
            }
        } catch {
            print("Error updating Firebase subscription: \(error.localizedDescription)")
        }
    }
    
    private func calculateEndDate(for plan: SubscriptionPlan?, startingFrom date: Date) -> Timestamp {
        let calendar = Calendar.current
        print("DEBUG: Calculating end date for plan: \(String(describing: plan))")
        
        // Calculate subscription period based on plan
        let endDate: Date
        switch plan {
        case .monthlyPlan:
            endDate = calendar.date(byAdding: .month, value: 1, to: date) ?? date
            print("DEBUG: Monthly plan - adding 1 month")
        case .quarterlyPlan:
            endDate = calendar.date(byAdding: .month, value: 3, to: date) ?? date
            print("DEBUG: Quarterly plan - adding 3 months")
        case .yearlyPlan:
            endDate = calendar.date(byAdding: .year, value: 1, to: date) ?? date
            print("DEBUG: Yearly plan - adding 1 year")
        case .none:
            print("DEBUG: No plan found - defaulting to 1 month")
            endDate = calendar.date(byAdding: .month, value: 1, to: date) ?? date
        }
        
        // Set to end of day
        if let finalEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) {
            print("DEBUG: Final end date with time: \(finalEndDate)")
            return Timestamp(date: finalEndDate)
        }
        
        print("DEBUG: Fallback end date: \(endDate)")
        return Timestamp(date: endDate)
    }
    
    func checkSubscriptionStatus() async {
        guard Auth.auth().currentUser != nil else {
            print("No authenticated user found")
            return
        }
        
        print("DEBUG: Checking StoreKit subscription status...")
        
        // Collect all valid transactions
        var validTransactions: [(StoreKit.Transaction, Date)] = []
        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            if let transaction = try? verificationResult.payloadValue,
               let expirationDate = transaction.expirationDate {
                validTransactions.append((transaction, expirationDate))
            }
        }
        
        // Sort by expiration date, most recent first
        validTransactions.sort { $0.1 > $1.1 }
        
        print("DEBUG: Found \(validTransactions.count) valid transactions")
        
        // Use the most recent non-expired transaction
        let now = Date()
        for (transaction, expirationDate) in validTransactions {
            print("DEBUG: Transaction details:")
            print("DEBUG: - Product ID: \(transaction.productID)")
            print("DEBUG: - Expiration Date: \(expirationDate)")
            print("DEBUG: - Is expired: \(expirationDate <= now)")
            print("DEBUG: - Purchase Date: \(transaction.purchaseDate)")
            print("DEBUG: - Original Purchase Date: \(transaction.originalPurchaseDate)")
            
            if expirationDate > now {
                // Found a valid subscription
                await MainActor.run {
                    self.isVIP = true
                    if let product = subscriptions.first(where: { $0.id == transaction.productID }) {
                        self.currentSubscription = product
                    }
                }
                return
            }
        }
        
        // If we get here, no valid subscription was found
        await MainActor.run {
            self.isVIP = false
            self.currentSubscription = nil
        }
    }
    
    func cancelSubscription() async {
        guard let user = Auth.auth().currentUser else { return }
        
        do {
            let querySnapshot = try await db.collection("subscriptions")
                .whereField("email", isEqualTo: user.email ?? "")
                .getDocuments()
            
            if let document = querySnapshot.documents.first {
                let updateData: [String: Any] = await withCheckedContinuation { continuation in
                    Task { @MainActor in
                        continuation.resume(returning: [
                            "isVIP": false,
                            "cancelDate": Timestamp(date: Date())
                        ])
                    }
                }
                try await document.reference.updateData(updateData)
                
                await MainActor.run {
                    self.isVIP = false
                    self.currentSubscription = nil
                }
            }
        } catch {
            print("Error canceling subscription: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Subscription Status
    
    func updateSubscriptionStatus() async {
        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                    await MainActor.run {
                        self.currentSubscription = subscription
                        if !self.purchasedSubscriptions.contains(where: { $0.id == subscription.id }) {
                            self.purchasedSubscriptions.append(subscription)
                        }
                    }
                    await updateFirebaseSubscription(for: subscription)
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        // Check Firebase subscription status
        await checkSubscriptionStatus()
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Failed to verify transaction: \(error)")
                }
            }
        }
    }
    
    // MARK: - Subscription Management
    
    func manageSubscriptions() async {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            do {
                try await AppStore.showManageSubscriptions(in: windowScene)
            } catch {
                print("Failed to show subscription management: \(error)")
            }
        }
    }
}

// MARK: - Errors

enum StoreError: Error {
    case verificationFailed
}

// MARK: - Product Extensions

extension Product {
    var subscriptionPlan: SubscriptionPlan? {
        return SubscriptionPlan(rawValue: id)
    }
}
