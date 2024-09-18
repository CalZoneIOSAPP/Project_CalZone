//
//  ChatViewModel.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 7/20/24.
//

import Foundation
import OpenAI
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import FirebaseFunctions



class ChatViewModel: ObservableObject {
    
    @Published var chat: AppChat?
    @Published var messages: [AppMessage] = []
    @Published var messageText: String = ""
    @Published var selectedModel: ChatModel = .gpt4 // default model
    @Published var scrollToBottom = false
    @Published var calories: String?
    @Published var isTyping: Bool = false
    
    let chatId: String
    let db = Firestore.firestore()
    let functions = Functions.functions()
    private var tokens: Int = 0
    
    init(chatId: String) {
        self.chatId = chatId
    }
    
    
    /// This function loads the configuration information from the config.plist.
    /// - Parameters: none
    /// - Returns: The configuration in the form of dictionary [String : Any].
    /// - Note: This is our way of getting the OpenAI API Key. This file is in gitignore.
    func loadConfig() -> [String: Any]? {
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let config = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any] {
            return config
        }
        return nil
    }
    
    
    /// This function fetches all chat messages.
    /// - Parameters: none
    /// - Returns: none
    func fetchData() {
        db.collection(Collection().chats).document(chatId).getDocument(as: AppChat.self) { result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self.chat = success
                }
            case .failure(_):
                print("ERROR: Failure case. \nSource: ChatViewModel/fetchData()")
            }
        }

        db.collection(Collection().chats).document(chatId).collection(Document().message).order(by: "createdAt").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, !documents.isEmpty else { return }
            
            self.messages = documents.compactMap({snapshot -> AppMessage? in
                do {
                    var message = try snapshot.data(as: AppMessage.self)
                    message.id = snapshot.documentID
                    self.scrollToBottom = true
                    return message
                } catch {
                   return nil
                }
            })
        }
        
    }
    
    
    /// This function sends the message to the OpenAI's AI model, and appends the new message received from the model to the message list.
    /// - Parameters: none
    /// - Returns: none
    @MainActor
    func sendMessage(userId: String) async throws {
        // Ensure the usage data is available
        let usageDocRef = db.collection("usages").document(userId)
        
        do {
            let document = try await usageDocRef.getDocument()
            var usage: Usage
            
            if document.exists {
                usage = try document.data(as: Usage.self)
            } else {
                usage = Usage(uid: userId, lastUsageTimestamp: Date(), maxCalorieAPIUsageNumRemaining: 10, maxAssistantTokenNumRemaining: 10000)
                try usageDocRef.setData(from: usage)
            }
            
            let currentTimestamp = Date()
            let lastUsageTimestamp = usage.lastUsageTimestamp ?? Date.distantPast
            
            let timeInterval = currentTimestamp.timeIntervalSince(lastUsageTimestamp)
            
            if timeInterval > 86400 {
                usage.resetUsage(with: currentTimestamp)
                try usageDocRef.setData(from: usage)
            }
            
            guard let remainingUses = usage.maxAssistantTokenNumRemaining, remainingUses > 0 else {
                let warningMessage = NSLocalizedString("Apologies, Cally is a bit tired today and will not be available to provide more advice for you. If you would like to hear more from me, join the CalBite membership!", comment: "")
                messages.append(AppMessage(id: UUID().uuidString, text: warningMessage, role: .assistant))
                return
            }
            
            var newMessage = AppMessage(id: UUID().uuidString, text: messageText, role: .user)
            
            do {
                let documentRef = try storeMessage(message: newMessage)
                newMessage.id = documentRef.documentID
            } catch {
                print("ERROR: Retrieving document reference \nSource: ChatViewModel/sendMessage() \n\(error.localizedDescription) ")
            }
            
            if messages.isEmpty {
                setupNewChat()
            } else {
                // do nothing at this point
            }
            
            await MainActor.run { [newMessage] in
                messages.append(newMessage)
                messageText = ""
            }
            
            do {
                // Attempt to generate a response
                try await generateResponse(for: newMessage)
                usage.maxAssistantTokenNumRemaining? -= tokens
                try usageDocRef.setData(from: usage)
            } catch {
                print("ERROR: Failed to generate response: \nSource: ChatViewModel/sendMessage() \n\(error.localizedDescription)")
                throw error
            }
        } catch {
            print("ERROR: Failed to send message: \nSource: ChatViewModel/sendMessage() \n\(error.localizedDescription)")
            throw error
        }
    }
    
    
    /// This function stores the message on the Firebase.
    /// - Parameters:
    ///     - message: The message to save.
    /// - Returns: The document reference.
    private func storeMessage(message: AppMessage) throws -> DocumentReference {
        return try db.collection(Collection().chats).document(chatId).collection(Document().message).addDocument(from: message)
    }
    
    
    /// This function will pair the chat instance with an AI model, and save that information on Firebase.
    /// - Parameters: none
    /// - Returns: none
    private func setupNewChat() {
        db.collection(Collection().chats).document(chatId).updateData([DataConst().model: selectedModel.rawValue])
        DispatchQueue.main.async { [weak self] in
            self?.chat?.model = self?.selectedModel
        }
    }
    
    
    /// This function calls the OpenAI API to get a response from the model.
    /// - Parameters:
    ///     - for: The message which the user inputs.
    /// - Returns: none
    @MainActor
    func generateResponse(for message: AppMessage) async throws {
        // Prepare messages to send to Firebase function
        let queryMessages = messages.map { appMessage in
            ["role": appMessage.role.rawValue, "content": appMessage.text]
        }
        
        let data: [String: Any] = [
            "messages": queryMessages,
            "model": chat?.model?.model.description ?? selectedModel.rawValue
        ]
        
        do {
            isTyping = true
            
            let result = try await functions.httpsCallable("generateResponse").call(data)
            
            if let responseData = result.data as? [String: Any], let content = responseData["content"] as? String, let tokensUsed = responseData["tokensUsed"] as? Int{
                await MainActor.run {
                    let newMessage = AppMessage(id: UUID().uuidString, text: content, role: .assistant)
                    messages.append(newMessage)
                }
                
                if let lastMessage = messages.last {
                    _ = try storeMessage(message: lastMessage)
                }
                tokens = tokensUsed
            }
        } catch {
            print("ERROR: Calling Firebase cloud function for response generation: \nSource: ChatViewModel/sendMessage() \n\(error.localizedDescription)")
            throw error
        }
        isTyping = false
    }
    
    
}


/// This is the struct of an message for GPT query
struct AppMessage: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var text: String
    let role: ChatQuery.ChatCompletionMessageParam.Role
    var createdAt: FirestoreDate = FirestoreDate()
}

