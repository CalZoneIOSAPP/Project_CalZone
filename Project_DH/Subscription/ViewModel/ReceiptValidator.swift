import Foundation
import StoreKit

enum ReceiptValidationError: Error {
    case missingReceipt
    case networkError
    case serverError(String)
    case sandboxReceiptInProduction
    case productionReceiptInSandbox
}

class ReceiptValidator {
    static let shared = ReceiptValidator()
    
    private let productionVerifyURL = "https://buy.itunes.apple.com/verifyReceipt"
    private let sandboxVerifyURL = "https://sandbox.itunes.apple.com/verifyReceipt"
    
    private init() {}
    
    func validateReceipt() async throws -> Bool {
        // Get the receipt data
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            throw ReceiptValidationError.missingReceipt
        }
        
        print("Receipt data fetched successfully. Size: \(receiptData.count) bytes")
        
        do {
            // Start with sandbox for development/testing
            return try await validateReceiptWithApple(receiptData: receiptData, urlString: sandboxVerifyURL, environment: "Sandbox")
        } catch ReceiptValidationError.productionReceiptInSandbox {
            // If we get production receipt error, try production environment
            print("Switching to PRODUCTION environment")
            return try await validateReceiptWithApple(receiptData: receiptData, urlString: productionVerifyURL, environment: "Production")
        }
    }
    
    private func validateReceiptWithApple(receiptData: Data, urlString: String, environment: String) async throws -> Bool {
        guard let verifyURL = URL(string: urlString) else {
            throw ReceiptValidationError.networkError
        }
        
        var request = URLRequest(url: verifyURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create a clean base64 string without line breaks or special characters
        let receiptString = receiptData.base64EncodedString()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("Receipt String Length: \(receiptString.count)")
        print("First 50 characters of receipt: \(String(receiptString.prefix(50)))...")
        
        // Verify receipt URL exists and is readable
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            print("Receipt URL exists: \(receiptURL)")
            if FileManager.default.fileExists(atPath: receiptURL.path) {
                print("Receipt file exists at path")
            } else {
                print("Receipt file does NOT exist at path")
            }
        }
        
        print("Validating receipt in \(environment) environment")
        
        // Prepare the request payload
        let requestContents: [String: Any] = [
            "receipt-data": receiptString,
            "password": "4a1c0c69bb0d4842b1432ff591642424",
            "exclude-old-transactions": true
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestContents) else {
            print("Failed to serialize request payload")
            throw ReceiptValidationError.serverError("Failed to create request")
        }
        
        print("Request payload size: \(jsonData.count) bytes")
        
        request.httpBody = jsonData
        
        // Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReceiptValidationError.networkError
        }
        
        print("Receipt validation HTTP status code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            throw ReceiptValidationError.serverError("Invalid HTTP status: \(httpResponse.statusCode)")
        }
        
        guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("Failed to parse response as JSON")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            throw ReceiptValidationError.serverError("Invalid JSON response")
        }
        
        print("Response status: \(jsonResponse["status"] as? Int ?? -1)")
        
        guard let status = jsonResponse["status"] as? Int else {
            throw ReceiptValidationError.serverError("Missing status in response")
        }
        
        switch status {
        case 0:     // Valid receipt
            print("Receipt validation successful")
            return true
            
        case 21007: // Sandbox receipt sent to production
            throw ReceiptValidationError.sandboxReceiptInProduction
            
        case 21002: // Malformed receipt data
            print("Error: Malformed receipt data")
            throw ReceiptValidationError.serverError("Malformed receipt data")
            
        case 21008: // Production receipt sent to sandbox
            throw ReceiptValidationError.productionReceiptInSandbox
            
        default:
            print("Receipt validation failed with status: \(status)")
            throw ReceiptValidationError.serverError("Receipt validation failed with status: \(status)")
        }
    }
}
